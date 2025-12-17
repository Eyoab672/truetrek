import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image"]

  open(event) {
    event.preventDefault()
    const imageUrl = event.currentTarget.dataset.imageUrl
    this.imageTarget.src = imageUrl
    this.modalTarget.classList.add("active")
    document.body.style.overflow = "hidden"
  }

  close(event) {
    if (event.target === this.modalTarget || event.target.classList.contains("lightbox-close")) {
      this.modalTarget.classList.remove("active")
      document.body.style.overflow = ""
    }
  }

  closeWithKey(event) {
    if (event.key === "Escape") {
      this.modalTarget.classList.remove("active")
      document.body.style.overflow = ""
    }
  }
}
