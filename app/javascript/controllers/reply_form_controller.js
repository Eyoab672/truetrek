import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  cancel() {
    // Remove the form container
    this.element.closest('turbo-frame')?.remove()
  }
}
