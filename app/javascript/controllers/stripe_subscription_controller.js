import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "errors", "submit"]
  static values = { 
    publishableKey: String,
    priceId: String,
    returnUrl: String
  }

  connect() {
    this.stripe = Stripe(this.publishableKeyValue)
    this.elements = this.stripe.elements()
    
    // Create card element with styling
    this.cardElement = this.elements.create('card', {
      style: {
        base: {
          fontSize: '16px',
          color: '#32325d',
          fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
          '::placeholder': {
            color: '#aab7c4'
          },
          padding: '12px'
        },
        invalid: {
          color: '#fa755a',
          iconColor: '#fa755a'
        }
      }
    })
    
    this.cardElement.mount(this.cardTarget)
    
    // Handle real-time validation errors
    this.cardElement.on('change', (event) => {
      if (event.error) {
        this.showError(event.error.message)
      } else {
        this.clearError()
      }
    })
  }

  disconnect() {
    if (this.cardElement) {
      this.cardElement.unmount()
    }
  }

  async submit(event) {
    event.preventDefault()
    
    this.setLoading(true)
    this.clearError()

    try {
      console.log('Starting payment process...')
      
      // Create payment method
      const { error, paymentMethod } = await this.stripe.createPaymentMethod({
        type: 'card',
        card: this.cardElement
      })

      console.log('Payment method created:', { error, paymentMethod })

      if (error) {
        console.error('Payment method error:', error)
        this.showError(error.message)
        this.setLoading(false)
        return
      }

      // Submit to backend
      console.log('Submitting to backend...')
      const response = await this.createSubscription(paymentMethod.id)
      
      console.log('Backend response:', response)
      
      if (response.success) {
        console.log('Subscription successful!')
        // Handle successful subscription
        if (response.requires_action) {
          console.log('Requires 3D Secure authentication')
          // Handle 3D Secure
          const { error: confirmError } = await this.stripe.confirmCardPayment(
            response.client_secret
          )
          
          if (confirmError) {
            console.error('3D Secure error:', confirmError)
            this.showError(confirmError.message)
            this.setLoading(false)
          } else {
            console.log('Redirecting to:', this.returnUrlValue)
            window.location.href = this.returnUrlValue
          }
        } else {
          console.log('Redirecting to:', this.returnUrlValue)
          window.location.href = this.returnUrlValue
        }
      } else {
        console.error('Backend error:', response.error)
        this.showError(response.error || 'An error occurred processing your payment')
        this.setLoading(false)
      }
    } catch (err) {
      console.error('Caught exception:', err)
      console.error('Stack trace:', err.stack)
      this.showError(`Error: ${err.message}`)
      this.setLoading(false)
    }
  }

  async createSubscription(paymentMethodId) {
    const formData = new FormData()
    formData.append('payment_method_id', paymentMethodId)
    formData.append('plan_type', 'seller_premium')

    try {
      const response = await fetch(this.element.action, {
        method: 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'application/json'
        }
      })

      if (!response.ok) {
        const errorText = await response.text()
        console.error('Server error:', response.status, errorText)
        throw new Error(`Server returned ${response.status}`)
      }

      const data = await response.json()
      console.log('Subscription response:', data)
      return data
    } catch (error) {
      console.error('Fetch error:', error)
      throw error
    }
  }

  showError(message) {
    if (this.hasErrorsTarget) {
      this.errorsTarget.textContent = message
      this.errorsTarget.classList.remove('hidden')
    }
  }

  clearError() {
    if (this.hasErrorsTarget) {
      this.errorsTarget.textContent = ''
      this.errorsTarget.classList.add('hidden')
    }
  }

  setLoading(isLoading) {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = isLoading
      this.submitTarget.textContent = isLoading 
        ? 'Processing...' 
        : 'Subscribe to Premium - €299/month'
    }
  }
}
