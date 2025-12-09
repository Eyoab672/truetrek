import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  toggle(event) {
    const isChecked = event.target.checked
    this.inputTargets.forEach(input => {
      input.type = isChecked ? "text" : "password"
    })
  }
}
