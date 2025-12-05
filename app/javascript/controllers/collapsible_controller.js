import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = {
    expanded: { type: Boolean, default: true }
  }

  toggle() {
    this.expandedValue = !this.expandedValue
    this.updateState()
  }

  updateState() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.toggle("collapsed", !this.expandedValue)
    }
    if (this.hasIconTarget) {
      this.iconTarget.classList.toggle("rotated", !this.expandedValue)
    }
  }

  connect() {
    this.updateState()
  }
}
