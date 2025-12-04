import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown"]

  connect() {
    this.selectedIndex = -1
    this.mentionStart = -1
    this.isOpen = false
    this.users = []

    // Create dropdown element
    this.dropdown = document.createElement('div')
    this.dropdown.className = 'mention-dropdown'
    this.dropdown.style.display = 'none'
    this.element.style.position = 'relative'
    this.element.appendChild(this.dropdown)

    // Bind events
    this.inputTarget.addEventListener('input', this.onInput.bind(this))
    this.inputTarget.addEventListener('keydown', this.onKeydown.bind(this))
    document.addEventListener('click', this.onClickOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.onClickOutside.bind(this))
    this.dropdown?.remove()
  }

  onInput(event) {
    const value = this.inputTarget.value
    const cursorPos = this.inputTarget.selectionStart

    // Find if we're in a mention context
    const textBeforeCursor = value.substring(0, cursorPos)
    const mentionMatch = textBeforeCursor.match(/@(\w*)$/)

    if (mentionMatch) {
      this.mentionStart = cursorPos - mentionMatch[0].length
      const query = mentionMatch[1]
      this.searchUsers(query)
    } else {
      this.closeDropdown()
    }
  }

  async searchUsers(query) {
    if (query.length === 0) {
      // Show some default users when just @ is typed
      try {
        const response = await fetch(`/users/search?q=`)
        this.users = await response.json()
        this.showDropdown()
      } catch (e) {
        this.closeDropdown()
      }
      return
    }

    try {
      const response = await fetch(`/users/search?q=${encodeURIComponent(query)}`)
      this.users = await response.json()

      if (this.users.length > 0) {
        this.showDropdown()
      } else {
        this.closeDropdown()
      }
    } catch (e) {
      this.closeDropdown()
    }
  }

  showDropdown() {
    if (this.users.length === 0) {
      this.closeDropdown()
      return
    }

    this.selectedIndex = 0
    this.isOpen = true

    this.dropdown.innerHTML = this.users.map((user, index) => `
      <div class="mention-item ${index === 0 ? 'selected' : ''}" data-index="${index}" data-username="${user.username}">
        <span class="mention-username">@${user.username}</span>
      </div>
    `).join('')

    this.dropdown.style.display = 'block'

    // Add click handlers
    this.dropdown.querySelectorAll('.mention-item').forEach(item => {
      item.addEventListener('click', (e) => {
        const username = e.currentTarget.dataset.username
        this.selectUser(username)
      })
      item.addEventListener('mouseenter', (e) => {
        this.selectedIndex = parseInt(e.currentTarget.dataset.index)
        this.updateSelection()
      })
    })
  }

  closeDropdown() {
    this.isOpen = false
    this.selectedIndex = -1
    this.dropdown.style.display = 'none'
  }

  onKeydown(event) {
    if (!this.isOpen) return

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, this.users.length - 1)
        this.updateSelection()
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.updateSelection()
        break
      case 'Enter':
      case 'Tab':
        if (this.selectedIndex >= 0 && this.users[this.selectedIndex]) {
          event.preventDefault()
          this.selectUser(this.users[this.selectedIndex].username)
        }
        break
      case 'Escape':
        this.closeDropdown()
        break
    }
  }

  updateSelection() {
    this.dropdown.querySelectorAll('.mention-item').forEach((item, index) => {
      item.classList.toggle('selected', index === this.selectedIndex)
    })
  }

  selectUser(username) {
    const value = this.inputTarget.value
    const before = value.substring(0, this.mentionStart)
    const after = value.substring(this.inputTarget.selectionStart)

    this.inputTarget.value = `${before}@${username} ${after}`

    // Set cursor position after the mention
    const newCursorPos = this.mentionStart + username.length + 2
    this.inputTarget.focus()
    this.inputTarget.setSelectionRange(newCursorPos, newCursorPos)

    this.closeDropdown()
  }

  onClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.closeDropdown()
    }
  }
}
