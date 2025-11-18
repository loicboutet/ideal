import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="listing-push"
export default class extends Controller {
  static targets = ["select", "submitButton"]
  static values = {
    baseUrl: String,
    hasCredits: Boolean
  }

  connect() {
    console.log('Listing push controller connected')
    this.updateButtonState()
  }

  updateFormAction(event) {
    const listingId = event.target.value
    const form = this.element
    
    if (listingId) {
      // Update form action to include the selected listing ID
      form.action = this.baseUrlValue.replace(':listing_id', listingId)
      this.updateButtonState()
    } else {
      this.submitButtonTarget.disabled = true
    }
  }

  updateButtonState() {
    const hasSelection = this.selectTarget.value !== ''
    const hasCredits = this.hasCreditsValue
    
    // Enable button only if user has credits and has selected a listing
    this.submitButtonTarget.disabled = !hasSelection || !hasCredits
  }
}
