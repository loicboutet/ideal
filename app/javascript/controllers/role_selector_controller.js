import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="role-selector"
export default class extends Controller {
  static targets = ["buyerFields", "partnerFields", "roleSelect"]

  connect() {
    this.toggleFields()
  }

  toggleFields() {
    // Only proceed if we have the required targets
    if (!this.hasRoleSelectTarget) {
      return
    }

    const selectedRole = this.roleSelectTarget.value

    // Hide all role-specific fields by default (only if they exist)
    if (this.hasBuyerFieldsTarget) {
      this.buyerFieldsTarget.classList.add('hidden')
    }
    if (this.hasPartnerFieldsTarget) {
      this.partnerFieldsTarget.classList.add('hidden')
    }

    // Show relevant fields based on selection
    if (selectedRole === 'buyer' && this.hasBuyerFieldsTarget) {
      this.buyerFieldsTarget.classList.remove('hidden')
    } else if (selectedRole === 'partner' && this.hasPartnerFieldsTarget) {
      this.partnerFieldsTarget.classList.remove('hidden')
    }
  }

  // Alias for the method called in the form
  updateProfile() {
    this.toggleFields()
  }
}
