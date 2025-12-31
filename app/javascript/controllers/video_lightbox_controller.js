import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "video"]
  static values = {
    src: String,
    type: String
  }

  connect() {
    // Create modal if it doesn't exist
    this.createModal()

    // Close on escape key
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  createModal() {
    // Check if modal already exists
    if (document.getElementById("video-lightbox-modal")) return

    const modal = document.createElement("div")
    modal.id = "video-lightbox-modal"
    modal.className = "video-lightbox-modal"
    modal.innerHTML = `
      <div class="video-lightbox-overlay"></div>
      <div class="video-lightbox-content">
        <button type="button" class="video-lightbox-close">
          <i class="fa-solid fa-xmark"></i>
        </button>
        <video id="video-lightbox-player" class="video-lightbox-player" controls playsinline></video>
      </div>
    `
    document.body.appendChild(modal)

    // Attach event listeners directly
    modal.querySelector(".video-lightbox-overlay").addEventListener("click", () => this.close())
    modal.querySelector(".video-lightbox-close").addEventListener("click", () => this.close())
  }

  open(event) {
    event.preventDefault()
    event.stopPropagation()

    const modal = document.getElementById("video-lightbox-modal")
    const player = document.getElementById("video-lightbox-player")

    if (!modal || !player) return

    // Pause all other media in the chat
    this.pauseAllMedia()

    // Get video source from the clicked element or its parent
    const videoElement = event.currentTarget.querySelector("video") || event.currentTarget
    const source = videoElement.querySelector("source")?.src || videoElement.src || this.srcValue

    player.src = source
    modal.classList.add("active")
    document.body.style.overflow = "hidden"

    // Auto-play the video
    player.play().catch(() => {
      // Auto-play blocked, user will need to tap play
    })
  }

  close() {
    const modal = document.getElementById("video-lightbox-modal")
    const player = document.getElementById("video-lightbox-player")

    if (modal) {
      modal.classList.remove("active")
      document.body.style.overflow = ""
    }

    if (player) {
      player.pause()
      player.src = ""
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  pauseAllMedia() {
    // Pause all audio and video elements on the page
    document.querySelectorAll("audio, video").forEach(media => {
      if (!media.paused) {
        media.pause()
      }
    })
  }
}
