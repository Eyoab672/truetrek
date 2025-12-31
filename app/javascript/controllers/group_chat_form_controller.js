import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "dmTab", "groupTab", "dmForm", "groupForm",
    "searchInput", "searchResults", "recipientId", "selectedUser", "dmSubmit",
    "groupSearchInput", "groupSearchResults", "selectedMembers", "groupSubmit",
    "checkmark"
  ]

  selectedMembers = new Map()
  isGroupMode = false

  connect() {
    this.hideAllResults()
  }

  showDM() {
    this.isGroupMode = false
    this.dmTabTarget.classList.add("active")
    this.groupTabTarget.classList.remove("active")
    this.dmFormTarget.style.display = "block"
    this.groupFormTarget.style.display = "none"
    this.updateCheckmarks()
  }

  showGroup() {
    this.isGroupMode = true
    this.groupTabTarget.classList.add("active")
    this.dmTabTarget.classList.remove("active")
    this.groupFormTarget.style.display = "block"
    this.dmFormTarget.style.display = "none"
    this.updateCheckmarks()
  }

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
      this.renderSearchResults(users, this.searchResultsTarget, false)
    } catch (error) {
      console.error("Search failed:", error)
    }
  }

  async searchGroup(event) {
    const query = event.target.value.trim()
    if (query.length < 2) {
      this.groupSearchResultsTarget.innerHTML = ""
      this.groupSearchResultsTarget.style.display = "none"
      return
    }

    try {
      const response = await fetch(`/users/search?q=${encodeURIComponent(query)}`)
      const users = await response.json()
      this.renderSearchResults(users, this.groupSearchResultsTarget, true)
    } catch (error) {
      console.error("Search failed:", error)
    }
  }

  renderSearchResults(users, container, isGroup) {
    if (users.length === 0) {
      container.innerHTML = '<div class="no-results">No users found</div>'
      container.style.display = "block"
      return
    }

    container.innerHTML = users.map(user => `
      <div class="search-result-item" data-user-id="${user.id}" data-username="${user.username}">
        <div class="result-avatar">
          ${user.avatar_url
            ? `<img src="${user.avatar_url}" class="avatar-img">`
            : `<div class="avatar-placeholder-sm">${user.username.charAt(0).toUpperCase()}</div>`
          }
        </div>
        <span class="result-name">${user.username}</span>
        ${isGroup && this.selectedMembers.has(user.id) ? '<i class="fa-solid fa-check"></i>' : ''}
      </div>
    `).join("")

    container.style.display = "block"

    // Add click handlers
    container.querySelectorAll(".search-result-item").forEach(item => {
      item.addEventListener("click", () => {
        const userId = parseInt(item.dataset.userId)
        const username = item.dataset.username
        if (isGroup) {
          this.toggleMember(userId, username)
        } else {
          this.selectRecipient(userId, username)
        }
        container.style.display = "none"
      })
    })
  }

  selectRecipient(userId, username) {
    this.recipientIdTarget.value = userId
    this.searchInputTarget.value = ""
    this.selectedUserTarget.style.display = "flex"
    this.selectedUserTarget.querySelector(".selected-user-name").textContent = username
    this.dmSubmitTarget.disabled = false
  }

  removeSelected() {
    this.recipientIdTarget.value = ""
    this.selectedUserTarget.style.display = "none"
    this.dmSubmitTarget.disabled = true
  }

  toggleMember(userId, username) {
    if (this.selectedMembers.has(userId)) {
      this.selectedMembers.delete(userId)
    } else {
      this.selectedMembers.set(userId, username)
    }
    this.renderSelectedMembers()
    this.updateGroupSubmit()
    this.updateCheckmarks()
  }

  selectFromList(event) {
    const item = event.currentTarget
    const userId = parseInt(item.dataset.userId)
    const username = item.dataset.username

    if (this.isGroupMode) {
      this.toggleMember(userId, username)
    } else {
      this.selectRecipient(userId, username)
    }
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
        this.updateGroupSubmit()
        this.updateCheckmarks()
      })
    })
  }

  updateGroupSubmit() {
    this.groupSubmitTarget.disabled = this.selectedMembers.size < 2
  }

  updateCheckmarks() {
    this.checkmarkTargets.forEach(checkmark => {
      const userId = parseInt(checkmark.dataset.userId)
      if (this.isGroupMode && this.selectedMembers.has(userId)) {
        checkmark.classList.add("visible")
      } else {
        checkmark.classList.remove("visible")
      }
    })
  }

  hideAllResults() {
    if (this.hasSearchResultsTarget) this.searchResultsTarget.style.display = "none"
    if (this.hasGroupSearchResultsTarget) this.groupSearchResultsTarget.style.display = "none"
  }
}
