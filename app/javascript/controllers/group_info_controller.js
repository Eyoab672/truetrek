import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editForm", "addMembersForm"]

  toggleEdit() {
    if (this.hasEditFormTarget) {
      const isVisible = this.editFormTarget.style.display !== "none"
      this.editFormTarget.style.display = isVisible ? "none" : "block"
    }
  }

  toggleAddMembers() {
    if (this.hasAddMembersFormTarget) {
      const isVisible = this.addMembersFormTarget.style.display !== "none"
      this.addMembersFormTarget.style.display = isVisible ? "none" : "block"
    }
  }
}
