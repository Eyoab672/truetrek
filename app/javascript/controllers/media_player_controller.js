import { Controller } from "@hotwired/stimulus"

// This controller manages all media playback in the messages container
// It ensures only one media element plays at a time (mutual exclusion)
export default class extends Controller {
  static targets = ["media"]

  connect() {
    // Listen for play events on all audio/video elements
    this.element.addEventListener("play", this.handlePlay.bind(this), true)
  }

  disconnect() {
    this.element.removeEventListener("play", this.handlePlay.bind(this), true)
  }

  handlePlay(event) {
    const playingElement = event.target

    // Only handle audio and video elements
    if (playingElement.tagName !== "AUDIO" && playingElement.tagName !== "VIDEO") {
      return
    }

    // Pause all other media elements
    this.pauseAllExcept(playingElement)
  }

  pauseAllExcept(currentElement) {
    // Find all audio and video elements in the container
    const allMedia = this.element.querySelectorAll("audio, video")

    allMedia.forEach(media => {
      if (media !== currentElement && !media.paused) {
        media.pause()
      }
    })
  }

  // Called when opening video in fullscreen - pause everything
  pauseAll() {
    const allMedia = this.element.querySelectorAll("audio, video")
    allMedia.forEach(media => media.pause())
  }
}
