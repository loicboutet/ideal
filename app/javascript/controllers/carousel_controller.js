import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide"]
  static values = {
    interval: { type: Number, default: 2000 }
  }

  connect() {
    this.currentIndex = 0
    this.showSlide(this.currentIndex)
    this.startAutoRotate()
  }

  disconnect() {
    this.stopAutoRotate()
  }

  startAutoRotate() {
    this.autoRotateTimer = setInterval(() => {
      this.next()
    }, this.intervalValue)
  }

  stopAutoRotate() {
    if (this.autoRotateTimer) {
      clearInterval(this.autoRotateTimer)
    }
  }

  next() {
    this.currentIndex = (this.currentIndex + 1) % this.slideTargets.length
    this.showSlide(this.currentIndex)
  }

  previous() {
    this.currentIndex = (this.currentIndex - 1 + this.slideTargets.length) % this.slideTargets.length
    this.showSlide(this.currentIndex)
  }

  goToSlide(event) {
    this.currentIndex = parseInt(event.currentTarget.dataset.index)
    this.showSlide(this.currentIndex)
    this.stopAutoRotate()
    this.startAutoRotate()
  }

  showSlide(index) {
    this.slideTargets.forEach((slide, i) => {
      if (i === index) {
        slide.classList.remove("hidden", "opacity-0")
        slide.classList.add("opacity-100")
      } else {
        slide.classList.remove("opacity-100")
        slide.classList.add("opacity-0")
        setTimeout(() => {
          if (i !== this.currentIndex) {
            slide.classList.add("hidden")
          }
        }, 300)
      }
    })

    // Update dots
    const dots = this.element.querySelectorAll("[data-carousel-dot]")
    dots.forEach((dot, i) => {
      if (i === index) {
        dot.classList.remove("bg-white/50")
        dot.classList.add("bg-white")
      } else {
        dot.classList.remove("bg-white")
        dot.classList.add("bg-white/50")
      }
    })
  }
}
