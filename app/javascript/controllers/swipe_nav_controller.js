import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    leftUrl: String,
    rightUrl: String
  }

  connect() {
    this.startX = 0
    this.startY = 0
    this.threshold = 100

    this.element.addEventListener('touchstart', this.handleTouchStart.bind(this), { passive: true })
    this.element.addEventListener('touchend', this.handleTouchEnd.bind(this), { passive: true })
  }

  handleTouchStart(event) {
    this.startX = event.touches[0].clientX
    this.startY = event.touches[0].clientY
  }

  handleTouchEnd(event) {
    const endX = event.changedTouches[0].clientX
    const endY = event.changedTouches[0].clientY

    const diffX = endX - this.startX
    const diffY = Math.abs(endY - this.startY)

    // Only trigger if horizontal swipe is greater than vertical
    if (Math.abs(diffX) > diffY && Math.abs(diffX) > this.threshold) {
      if (diffX > 0 && this.hasLeftUrlValue) {
        // Swipe right - go to left page
        Turbo.visit(this.leftUrlValue)
      } else if (diffX < 0 && this.hasRightUrlValue) {
        // Swipe left - go to right page
        Turbo.visit(this.rightUrlValue)
      }
    }
  }
}
