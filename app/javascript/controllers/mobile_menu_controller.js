import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-menu"
export default class extends Controller {
  static targets = ["menu", "openButton", "closeButton"]

  connect() {
    // Ensure menu is hidden on load
    this.menuTarget.classList.add("hidden")
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    this.openButtonTarget.classList.add("hidden")
    this.closeButtonTarget.classList.remove("hidden")
    // Prevent body scroll when menu is open
    document.body.style.overflow = "hidden"
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.openButtonTarget.classList.remove("hidden")
    this.closeButtonTarget.classList.add("hidden")
    // Restore body scroll
    document.body.style.overflow = ""
  }

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }
}
