import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "searchResults", "selectedMembers", "submitBtn"]

  selectedMembers = new Map()

  async search(event) {
    const query = event.target.value.trim()
    if (query.length < 2) {
      this.searchResultsTarget.innerHTML = ""
      this.searchResultsTarget.style.display = "none"
      return
    }

    try {
      const response = await fetch(`/users/search?q=${encodeURIComponent(query)}`)
      const users = await response.json()
      this.renderSearchResults(users)
    } catch (error) {
      console.error("Search failed:", error)
    }
  }

  renderSearchResults(users) {
    if (users.length === 0) {
      this.searchResultsTarget.innerHTML = '<div class="no-results">No users found</div>'
      this.searchResultsTarget.style.display = "block"
      return
    }

    this.searchResultsTarget.innerHTML = users.map(user => `
      <div class="search-result-item" data-user-id="${user.id}" data-username="${user.username}">
        <div class="result-avatar">
          ${user.avatar_url
            ? `<img src="${user.avatar_url}" class="avatar-img">`
            : `<div class="avatar-placeholder-sm">${user.username.charAt(0).toUpperCase()}</div>`
          }
        </div>
        <span class="result-name">${user.username}</span>
        ${this.selectedMembers.has(user.id) ? '<i class="fa-solid fa-check"></i>' : ''}
      </div>
    `).join("")

    this.searchResultsTarget.style.display = "block"

    // Add click handlers
    this.searchResultsTarget.querySelectorAll(".search-result-item").forEach(item => {
      item.addEventListener("click", () => {
        const userId = parseInt(item.dataset.userId)
        const username = item.dataset.username
        this.toggleMember(userId, username)
      })
    })
  }

  toggleMember(userId, username) {
    if (this.selectedMembers.has(userId)) {
      this.selectedMembers.delete(userId)
    } else {
      this.selectedMembers.set(userId, username)
    }
    this.renderSelectedMembers()
    this.updateSubmitButton()
  }

  renderSelectedMembers() {
    const html = Array.from(this.selectedMembers.entries()).map(([id, name]) => `
      <div class="selected-member-chip">
        <span>${name}</span>
        <input type="hidden" name="member_ids[]" value="${id}">
        <button type="button" class="remove-member" data-user-id="${id}">
          <i class="fa-solid fa-xmark"></i>
        </button>
      </div>
    `).join("")

    this.selectedMembersTarget.innerHTML = html

    // Add remove handlers
    this.selectedMembersTarget.querySelectorAll(".remove-member").forEach(btn => {
      btn.addEventListener("click", (e) => {
        e.preventDefault()
        const userId = parseInt(btn.dataset.userId)
        this.selectedMembers.delete(userId)
        this.renderSelectedMembers()
        this.updateSubmitButton()
      })
    })
  }

  updateSubmitButton() {
    this.submitBtnTarget.disabled = this.selectedMembers.size === 0
  }
}
