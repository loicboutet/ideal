import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter"]
  static values = {
    max: Number
  }

  connect() {
    this.updateCounter()
  }

  updateCounter() {
    const input = this.inputTarget
    const counter = this.counterTarget
    const currentLength = input.value.length
    const maxLength = this.maxValue || input.maxLength
    
    if (maxLength && maxLength > 0) {
      counter.textContent = `${currentLength} / ${maxLength} caractères`
    }
  }

  input() {
    this.updateCounter()
  }
}
