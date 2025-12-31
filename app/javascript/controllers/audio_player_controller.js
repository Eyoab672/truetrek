import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["audio", "icon", "progress", "duration"]

  connect() {
    if (this.hasAudioTarget) {
      this.audioTarget.addEventListener("loadedmetadata", () => this.updateDuration())
      this.audioTarget.addEventListener("timeupdate", () => this.updateProgress())
      this.audioTarget.addEventListener("ended", () => this.onEnded())
    }
  }

  toggle() {
    if (!this.hasAudioTarget) return

    if (this.audioTarget.paused) {
      // Pause all other audio players first
      document.querySelectorAll("audio").forEach(audio => {
        if (audio !== this.audioTarget) {
          audio.pause()
          audio.currentTime = 0
        }
      })
      // Reset all other play buttons
      document.querySelectorAll(".voice-play-btn i").forEach(icon => {
        icon.classList.remove("fa-pause")
        icon.classList.add("fa-play")
      })

      this.audioTarget.play()
      if (this.hasIconTarget) {
        this.iconTarget.classList.remove("fa-play")
        this.iconTarget.classList.add("fa-pause")
      }
    } else {
      this.audioTarget.pause()
      if (this.hasIconTarget) {
        this.iconTarget.classList.remove("fa-pause")
        this.iconTarget.classList.add("fa-play")
      }
    }
  }

  updateDuration() {
    if (this.hasAudioTarget && this.hasDurationTarget) {
      const duration = this.audioTarget.duration
      if (!isNaN(duration)) {
        this.durationTarget.textContent = this.formatTime(duration)
      }
    }
  }

  updateProgress() {
    if (this.hasAudioTarget && this.hasProgressTarget) {
      const percent = (this.audioTarget.currentTime / this.audioTarget.duration) * 100
      this.progressTarget.style.width = `${percent}%`

      // Update duration display with current time while playing
      if (this.hasDurationTarget && !this.audioTarget.paused) {
        this.durationTarget.textContent = this.formatTime(this.audioTarget.currentTime)
      }
    }
  }

  onEnded() {
    if (this.hasIconTarget) {
      this.iconTarget.classList.remove("fa-pause")
      this.iconTarget.classList.add("fa-play")
    }
    if (this.hasProgressTarget) {
      this.progressTarget.style.width = "0%"
    }
    if (this.hasDurationTarget && this.hasAudioTarget) {
      this.durationTarget.textContent = this.formatTime(this.audioTarget.duration)
    }
  }

  formatTime(seconds) {
    if (isNaN(seconds)) return "0:00"
    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins}:${secs.toString().padStart(2, "0")}`
  }
}
