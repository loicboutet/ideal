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
      // Create payment method
      const { error, paymentMethod } = await this.stripe.createPaymentMethod({
        type: 'card',
        card: this.cardElement
      })

      if (error) {
        this.showError(error.message)
        this.setLoading(false)
        return
      }

      // Submit to backend
      const response = await this.createSubscription(paymentMethod.id)
      
      if (response.success) {
        // Handle successful subscription
        if (response.requiresAction) {
          // Handle 3D Secure
          const { error: confirmError } = await this.stripe.confirmCardPayment(
            response.clientSecret
          )
          
          if (confirmError) {
            this.showError(confirmError.message)
            this.setLoading(false)
          } else {
            window.location.href = this.returnUrlValue
          }
        } else {
          window.location.href = this.returnUrlValue
        }
      } else {
        this.showError(response.error || 'An error occurred processing your payment')
        this.setLoading(false)
      }
    } catch (err) {
      this.showError('An unexpected error occurred. Please try again.')
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
