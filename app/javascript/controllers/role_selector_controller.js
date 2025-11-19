import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="role-selector"
export default class extends Controller {
  static targets = ["buyerFields", "partnerFields", "roleSelect"]

  connect() {
    this.toggleFields()
  }

  toggleFields() {
    const selectedRole = this.roleSelectTarget.value

    // Hide all role-specific fields by default
    this.buyerFieldsTarget.classList.add('hidden')
    this.partnerFieldsTarget.classList.add('hidden')

    // Show relevant fields based on selection
    if (selectedRole === 'buyer') {
      this.buyerFieldsTarget.classList.remove('hidden')
    } else if (selectedRole === 'partner') {
      this.partnerFieldsTarget.classList.remove('hidden')
    }
  }
}
