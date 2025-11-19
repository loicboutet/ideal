import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="date-range"
export default class extends Controller {
  updateRange(event) {
    const selectedRange = event.target.value
    const url = new URL(window.location)
    url.searchParams.set('date_range', selectedRange)
    window.location.href = url.toString()
  }
}
