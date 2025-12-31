import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close dropdown when clicking outside
    this.handleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
  }

  toggle(event) {
    event.stopPropagation()

    // Close all other dropdowns first
    document.querySelectorAll(".chat-dropdown-menu.show").forEach(menu => {
      if (menu !== this.menuTarget) {
        menu.classList.remove("show")
      }
    })

    this.menuTarget.classList.toggle("show")
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.remove("show")
    }
  }
}
