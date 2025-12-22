import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "checkbox", "headerActions", "selectedCount", "pinBtn", "deleteBtn"]
  static values = {
    selectMode: { type: Boolean, default: false }
  }

  connect() {
    this.selectedIds = new Set()
    this.longPressTimer = null
    this.longPressDuration = 500 // ms
  }

  // Long press detection
  startPress(event) {
    // Don't trigger on right-click
    if (event.button && event.button !== 0) return

    const item = event.currentTarget

    this.longPressTimer = setTimeout(() => {
      this.enterSelectMode(item)
    }, this.longPressDuration)
  }

  endPress(event) {
    if (this.longPressTimer) {
      clearTimeout(this.longPressTimer)
      this.longPressTimer = null
    }
  }

  cancelPress(event) {
    if (this.longPressTimer) {
      clearTimeout(this.longPressTimer)
      this.longPressTimer = null
    }
  }

  enterSelectMode(initialItem) {
    this.selectModeValue = true
    this.element.classList.add("select-mode")

    // Select the initial item
    if (initialItem) {
      this.selectItem(initialItem)
    }

    this.updateUI()
  }

  exitSelectMode() {
    this.selectModeValue = false
    this.selectedIds.clear()

    this.checkboxTargets.forEach(cb => cb.checked = false)
    this.itemTargets.forEach(item => item.classList.remove("selected"))
    this.element.classList.remove("select-mode")

    this.updateUI()
  }

  toggleItem(event) {
    if (!this.selectModeValue) return

    event.preventDefault()
    event.stopPropagation()

    const item = event.currentTarget.closest('[data-travel-book-select-target="item"]')
    if (!item) return

    const id = item.dataset.travelBookPlaceId

    if (this.selectedIds.has(id)) {
      this.deselectItem(item)
    } else {
      this.selectItem(item)
    }

    // Exit select mode if nothing selected
    if (this.selectedIds.size === 0) {
      this.exitSelectMode()
    }

    this.updateUI()
  }

  selectItem(item) {
    const id = item.dataset.travelBookPlaceId
    const checkbox = item.querySelector('[data-travel-book-select-target="checkbox"]')

    this.selectedIds.add(id)
    item.classList.add("selected")
    if (checkbox) checkbox.checked = true
  }

  deselectItem(item) {
    const id = item.dataset.travelBookPlaceId
    const checkbox = item.querySelector('[data-travel-book-select-target="checkbox"]')

    this.selectedIds.delete(id)
    item.classList.remove("selected")
    if (checkbox) checkbox.checked = false
  }

  updateUI() {
    const count = this.selectedIds.size

    // Update header actions visibility
    if (this.hasHeaderActionsTarget) {
      this.headerActionsTarget.classList.toggle("visible", this.selectModeValue && count > 0)
    }

    // Update selected count
    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = count
    }

    // Show pin button only when exactly 1 item is selected
    if (this.hasPinBtnTarget) {
      this.pinBtnTarget.classList.toggle("hidden", count !== 1)
    }
  }

  async deleteSelected() {
    if (this.selectedIds.size === 0) return

    const confirmed = confirm(`Remove ${this.selectedIds.size} place(s) from your Travel Book?`)
    if (!confirmed) return

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    try {
      const response = await fetch('/travel_book_places/bulk_destroy', {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({ ids: Array.from(this.selectedIds) })
      })

      if (response.ok) {
        window.location.reload()
      }
    } catch (error) {
      console.error('Error removing places:', error)
      alert('Failed to remove places. Please try again.')
    }
  }

  async pinSelected() {
    if (this.selectedIds.size !== 1) return

    const id = Array.from(this.selectedIds)[0]
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    try {
      const response = await fetch(`/travel_book_places/${id}/toggle_pin`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': csrfToken
        }
      })

      if (response.ok) {
        window.location.reload()
      } else {
        const data = await response.json()
        alert(data.error || 'Failed to pin place.')
      }
    } catch (error) {
      console.error('Error pinning place:', error)
      alert('Failed to pin place. Please try again.')
    }
  }
}
