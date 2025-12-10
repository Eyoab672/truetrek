import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "button"]
  static values = { itemsPerPage: { type: Number, default: 3 } }

  connect() {
    this.currentlyShown = this.itemsPerPageValue
  }

  loadMore() {
    const items = this.itemTargets
    const nextBatch = items.slice(this.currentlyShown, this.currentlyShown + this.itemsPerPageValue)

    nextBatch.forEach(item => {
      item.style.display = ""
    })

    this.currentlyShown += this.itemsPerPageValue

    // Hide button if all items are shown
    if (this.currentlyShown >= items.length) {
      this.buttonTarget.style.display = "none"
    }
  }
}
