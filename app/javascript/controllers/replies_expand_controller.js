import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    commentId: Number
  }

  toggle() {
    const wrapper = document.getElementById(`replies_wrapper_${this.commentIdValue}`)
    if (!wrapper) return

    const isExpanded = wrapper.dataset.expanded === "true"
    const icon = this.element.querySelector('.toggle-icon')
    const text = this.element.querySelector('.toggle-text')

    if (isExpanded) {
      // Collapse
      wrapper.dataset.expanded = "false"
      wrapper.classList.remove('expanded')
      if (icon) icon.classList.remove('rotated')
      if (text) text.textContent = `See ${wrapper.querySelectorAll('.reply-card').length} replies`
    } else {
      // Expand
      wrapper.dataset.expanded = "true"
      wrapper.classList.add('expanded')
      if (icon) icon.classList.add('rotated')
      if (text) text.textContent = 'Hide replies'
    }
  }
}
