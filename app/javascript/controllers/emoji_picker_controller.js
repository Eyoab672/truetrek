import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["picker", "input"]

  // Common emojis organized by category
  emojis = {
    "Smileys": ["😀", "😃", "😄", "😁", "😅", "😂", "🤣", "😊", "😇", "🙂", "😉", "😍", "🥰", "😘", "😋", "😛", "😜", "🤪", "😎", "🤩", "🥳", "😏", "😒", "😞", "😔", "😟", "😕", "🙁", "😣", "😖", "😫", "😩", "🥺", "😢", "😭", "😤", "😠", "😡", "🤬", "😈", "👿", "💀", "💩", "🤡", "👻", "👽", "🤖"],
    "Gestures": ["👋", "🤚", "🖐️", "✋", "🖖", "👌", "🤌", "🤏", "✌️", "🤞", "🤟", "🤘", "🤙", "👈", "👉", "👆", "👇", "☝️", "👍", "👎", "✊", "👊", "🤛", "🤜", "👏", "🙌", "👐", "🤲", "🤝", "🙏", "💪", "🦾"],
    "Hearts": ["❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💔", "❤️‍🔥", "❤️‍🩹", "💕", "💞", "💓", "💗", "💖", "💘", "💝", "💟"],
    "Animals": ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🦅", "🦆", "🦉", "🐴", "🦄", "🐝", "🦋", "🐌", "🐞"],
    "Food": ["🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🥑", "🍔", "🍟", "🍕", "🌭", "🍿", "🧁", "🍩", "🍪", "🎂", "🍰", "☕", "🍵", "🧃"],
    "Activities": ["⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱", "🏓", "🏸", "🥅", "⛳", "🎯", "🎮", "🎲", "🎭", "🎨", "🎬", "🎤", "🎧", "🎸", "🎹", "🎺", "🎻"],
    "Travel": ["🚗", "🚕", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "✈️", "🚀", "🛸", "🚁", "⛵", "🚢", "🏠", "🏢", "🏰", "🗼", "🗽", "⛰️", "🏔️", "🌋", "🏕️", "🏖️", "🌅", "🌄"],
    "Objects": ["⌚", "📱", "💻", "⌨️", "🖥️", "🖨️", "🖱️", "💾", "📷", "📹", "🎥", "📺", "📻", "🎙️", "⏰", "🔋", "💡", "🔦", "💎", "💰", "💳", "✉️", "📦", "📝", "📚", "🔑", "🔒"],
    "Symbols": ["✅", "❌", "❓", "❗", "💯", "🔥", "⭐", "🌟", "✨", "💫", "💥", "💢", "💦", "💨", "🕳️", "💬", "👁️‍🗨️", "🗨️", "🗯️", "💭", "🔔", "🎵", "🎶", "➕", "➖", "➗", "✖️", "♾️", "💲", "©️", "®️", "™️"]
  }

  connect() {
    this.isOpen = false
    this.currentCategory = "Smileys"
    this.buildPicker()
  }

  buildPicker() {
    if (!this.hasPickerTarget) return

    const picker = this.pickerTarget

    // Build category tabs
    const tabs = document.createElement("div")
    tabs.className = "emoji-tabs"

    Object.keys(this.emojis).forEach((category, index) => {
      const tab = document.createElement("button")
      tab.type = "button"
      tab.className = `emoji-tab ${index === 0 ? "active" : ""}`
      tab.textContent = this.getCategoryIcon(category)
      tab.dataset.category = category
      tab.addEventListener("click", (e) => this.switchCategory(e, category))
      tabs.appendChild(tab)
    })

    // Build emoji grid
    const grid = document.createElement("div")
    grid.className = "emoji-grid"
    grid.dataset.emojiPickerTarget = "grid"
    this.renderEmojis(grid, "Smileys")

    picker.appendChild(tabs)
    picker.appendChild(grid)
  }

  getCategoryIcon(category) {
    const icons = {
      "Smileys": "😀",
      "Gestures": "👋",
      "Hearts": "❤️",
      "Animals": "🐶",
      "Food": "🍎",
      "Activities": "⚽",
      "Travel": "✈️",
      "Objects": "📱",
      "Symbols": "⭐"
    }
    return icons[category] || "😀"
  }

  renderEmojis(grid, category) {
    grid.innerHTML = ""
    this.emojis[category].forEach(emoji => {
      const btn = document.createElement("button")
      btn.type = "button"
      btn.className = "emoji-btn"
      btn.textContent = emoji
      btn.addEventListener("click", () => this.selectEmoji(emoji))
      grid.appendChild(btn)
    })
  }

  switchCategory(event, category) {
    event.preventDefault()
    this.currentCategory = category

    // Update active tab
    this.pickerTarget.querySelectorAll(".emoji-tab").forEach(tab => {
      tab.classList.toggle("active", tab.dataset.category === category)
    })

    // Render emojis for this category
    const grid = this.pickerTarget.querySelector(".emoji-grid")
    this.renderEmojis(grid, category)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    this.isOpen = !this.isOpen
    this.pickerTarget.classList.toggle("show", this.isOpen)

    if (this.isOpen) {
      // Close picker when clicking outside
      setTimeout(() => {
        document.addEventListener("click", this.closeOnClickOutside)
      }, 0)
    }
  }

  closeOnClickOutside = (event) => {
    if (!this.pickerTarget.contains(event.target) && !event.target.closest(".emoji-toggle-btn")) {
      this.close()
    }
  }

  close() {
    this.isOpen = false
    this.pickerTarget.classList.remove("show")
    document.removeEventListener("click", this.closeOnClickOutside)
  }

  selectEmoji(emoji) {
    if (!this.hasInputTarget) return

    const input = this.inputTarget
    const start = input.selectionStart
    const end = input.selectionEnd
    const text = input.value

    // Insert emoji at cursor position
    input.value = text.substring(0, start) + emoji + text.substring(end)

    // Move cursor after emoji
    const newPos = start + emoji.length
    input.setSelectionRange(newPos, newPos)
    input.focus()

    // Trigger input event for any listeners (like the mic/send toggle)
    input.dispatchEvent(new Event("input", { bubbles: true }))
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnClickOutside)
  }
}
