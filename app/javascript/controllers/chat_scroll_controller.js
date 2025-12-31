import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Scroll to bottom after a small delay to ensure content is rendered
    requestAnimationFrame(() => {
      this.scrollToBottom()
    })

    // Also scroll after images/media load
    setTimeout(() => this.scrollToBottom(), 300)

    // Listen for turbo stream events
    document.addEventListener('turbo:before-stream-render', this.handleStreamRender.bind(this))
  }

  disconnect() {
    document.removeEventListener('turbo:before-stream-render', this.handleStreamRender.bind(this))
  }

  handleStreamRender(event) {
    if (event.target.querySelector('[data-message-id]')) {
      setTimeout(() => this.scrollToBottom(), 100)
    }
  }

  scrollToBottom() {
    const container = document.getElementById('messages_container')
    if (container) {
      container.scrollTop = container.scrollHeight
    }
  }

  scrollToDate(event) {
    event.preventDefault()
    const targetId = event.currentTarget.getAttribute('href').substring(1)
    const targetElement = document.getElementById(targetId)

    if (targetElement) {
      const container = document.getElementById('messages_container')
      if (container) {
        targetElement.scrollIntoView({ behavior: 'smooth', block: 'start' })
      }
    }
  }
}
