import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["contextMenu", "replyPreview", "replyName", "replyText", "replyInput", "messageInput"]

  connect() {
    this.replyingToMessageId = null

    // Listen for message events
    this.element.addEventListener('message:reply', this.handleReply.bind(this))
    this.element.addEventListener('message:showMenu', this.showContextMenu.bind(this))

    // Close context menu on outside click
    document.addEventListener('click', this.closeContextMenu.bind(this))
    document.addEventListener('touchstart', this.closeContextMenu.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.closeContextMenu.bind(this))
    document.removeEventListener('touchstart', this.closeContextMenu.bind(this))
  }

  handleReply(event) {
    const { messageId, messageBody, senderName } = event.detail
    this.setReplyMode(messageId, messageBody, senderName)
  }

  showContextMenu(event) {
    event.stopPropagation()
    const { messageId, messageBody, senderName, x, y } = event.detail

    if (this.hasContextMenuTarget) {
      this.contextMenuTarget.dataset.messageId = messageId
      this.contextMenuTarget.dataset.messageBody = messageBody
      this.contextMenuTarget.dataset.senderName = senderName

      // Position the menu
      const menuWidth = 200
      const menuHeight = 100
      const viewportWidth = window.innerWidth
      const viewportHeight = window.innerHeight

      let posX = x - menuWidth / 2
      let posY = y - menuHeight - 20

      // Keep within viewport
      posX = Math.max(10, Math.min(posX, viewportWidth - menuWidth - 10))
      posY = Math.max(10, posY)

      // If not enough space above, show below
      if (posY < 10) {
        posY = y + 20
      }

      this.contextMenuTarget.style.left = `${posX}px`
      this.contextMenuTarget.style.top = `${posY}px`
      this.contextMenuTarget.classList.add('active')
    }
  }

  closeContextMenu(event) {
    if (this.hasContextMenuTarget && !this.contextMenuTarget.contains(event.target)) {
      this.contextMenuTarget.classList.remove('active')
    }
  }

  replyFromMenu(event) {
    event.preventDefault()
    const menu = this.contextMenuTarget
    const messageId = menu.dataset.messageId
    const messageBody = menu.dataset.messageBody
    const senderName = menu.dataset.senderName

    this.setReplyMode(messageId, messageBody, senderName)
    this.closeContextMenu({ target: document.body })
  }

  deleteFromMenu(event) {
    event.preventDefault()
    const menu = this.contextMenuTarget
    const messageId = menu.dataset.messageId

    if (confirm('Unsend this message?')) {
      // Find and click the delete form for this message
      const deleteForm = document.querySelector(`#message_${messageId} .unsend-btn`)
      if (deleteForm) {
        deleteForm.click()
      }
    }
    this.closeContextMenu({ target: document.body })
  }

  setReplyMode(messageId, messageBody, senderName) {
    this.replyingToMessageId = messageId

    if (this.hasReplyPreviewTarget) {
      this.replyPreviewTarget.classList.add('active')
    }
    if (this.hasReplyNameTarget) {
      this.replyNameTarget.textContent = senderName
    }
    if (this.hasReplyTextTarget) {
      this.replyTextTarget.textContent = messageBody || 'Photo'
    }
    if (this.hasReplyInputTarget) {
      this.replyInputTarget.value = messageId
    }
    if (this.hasMessageInputTarget) {
      this.messageInputTarget.focus()
    }
  }

  cancelReply(event) {
    event.preventDefault()
    this.replyingToMessageId = null

    if (this.hasReplyPreviewTarget) {
      this.replyPreviewTarget.classList.remove('active')
    }
    if (this.hasReplyInputTarget) {
      this.replyInputTarget.value = ''
    }
  }
}
