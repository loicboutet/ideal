import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="message-type"
export default class extends Controller {
  static targets = ["option"]

  connect() {
    // Initialize on page load
    this.updateSelection()
  }

  select(event) {
    // Update visual state when a radio button is clicked
    this.updateSelection()
  }

  updateSelection() {
    this.optionTargets.forEach(option => {
      const radio = option.querySelector('input[type="radio"]')
      if (radio && radio.checked) {
        // Selected state
        option.classList.remove('border-gray-200')
        option.classList.add('border-admin-600', 'bg-admin-50')
      } else {
        // Unselected state
        option.classList.remove('border-admin-600', 'bg-admin-50')
        option.classList.add('border-gray-200')
      }
    })
  }
}
