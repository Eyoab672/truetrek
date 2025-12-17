import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "replyIcon", "contextMenu"]
  static values = {
    messageId: Number,
    messageBody: String,
    senderName: String
  }

  connect() {
    this.startX = 0
    this.currentX = 0
    this.isDragging = false
    this.longPressTimer = null
    this.longPressTriggered = false
    this.swipeThreshold = 80

    // Touch events for mobile
    this.element.addEventListener('touchstart', this.handleTouchStart.bind(this), { passive: true })
    this.element.addEventListener('touchmove', this.handleTouchMove.bind(this), { passive: false })
    this.element.addEventListener('touchend', this.handleTouchEnd.bind(this))
  }

  disconnect() {
    this.clearLongPress()
  }

  handleTouchStart(event) {
    this.startX = event.touches[0].clientX
    this.startY = event.touches[0].clientY
    this.isDragging = false
    this.longPressTriggered = false

    // Start long press timer
    this.longPressTimer = setTimeout(() => {
      this.longPressTriggered = true
      this.showContextMenu(event)
    }, 500)
  }

  handleTouchMove(event) {
    if (this.longPressTriggered) return

    const currentX = event.touches[0].clientX
    const currentY = event.touches[0].clientY
    const diffX = currentX - this.startX
    const diffY = Math.abs(currentY - this.startY)

    // If vertical movement is greater, it's a scroll - cancel swipe
    if (diffY > 10 && !this.isDragging) {
      this.clearLongPress()
      return
    }

    // Only allow right swipe (positive diffX)
    if (diffX > 10) {
      this.clearLongPress()
      this.isDragging = true
      event.preventDefault()

      // Limit the swipe distance
      const translateX = Math.min(diffX, 100)
      this.element.style.transform = `translateX(${translateX}px)`
      this.element.style.transition = 'none'

      // Show reply icon based on swipe distance
      if (this.hasReplyIconTarget) {
        const opacity = Math.min(diffX / this.swipeThreshold, 1)
        this.replyIconTarget.style.opacity = opacity
        this.replyIconTarget.style.transform = `scale(${0.5 + opacity * 0.5})`
      }
    }
  }

  handleTouchEnd(event) {
    this.clearLongPress()

    if (this.longPressTriggered) {
      return
    }

    if (this.isDragging) {
      const diffX = parseFloat(this.element.style.transform.replace('translateX(', '').replace('px)', '')) || 0

      // Reset position with animation
      this.element.style.transition = 'transform 0.2s ease'
      this.element.style.transform = 'translateX(0)'

      if (this.hasReplyIconTarget) {
        this.replyIconTarget.style.opacity = '0'
        this.replyIconTarget.style.transform = 'scale(0.5)'
      }

      // Trigger reply if swiped enough
      if (diffX >= this.swipeThreshold) {
        this.triggerReply()
      }

      this.isDragging = false
    }
  }

  clearLongPress() {
    if (this.longPressTimer) {
      clearTimeout(this.longPressTimer)
      this.longPressTimer = null
    }
  }

  showContextMenu(event) {
    // Dispatch custom event to show context menu
    const menuEvent = new CustomEvent('message:showMenu', {
      bubbles: true,
      detail: {
        messageId: this.messageIdValue,
        messageBody: this.messageBodyValue,
        senderName: this.senderNameValue,
        x: event.touches ? event.touches[0].clientX : event.clientX,
        y: event.touches ? event.touches[0].clientY : event.clientY
      }
    })
    this.element.dispatchEvent(menuEvent)

    // Add haptic feedback if available
    if (navigator.vibrate) {
      navigator.vibrate(50)
    }
  }

  triggerReply() {
    const replyEvent = new CustomEvent('message:reply', {
      bubbles: true,
      detail: {
        messageId: this.messageIdValue,
        messageBody: this.messageBodyValue,
        senderName: this.senderNameValue
      }
    })
    this.element.dispatchEvent(replyEvent)

    // Add haptic feedback
    if (navigator.vibrate) {
      navigator.vibrate(30)
    }
  }
}
