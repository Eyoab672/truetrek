import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["recordBtn", "stopBtn", "timer", "waveform", "preview", "audioPlayer", "fileInput", "cancelBtn", "recordingState", "idleState", "previewState", "messageInput", "micBtn", "sendBtn"]
  static values = {
    maxDuration: { type: Number, default: 300 } // 5 minutes in seconds
  }

  connect() {
    this.mediaRecorder = null
    this.audioChunks = []
    this.timerInterval = null
    this.seconds = 0
    this.audioBlob = null

    // Check input on connect to set initial button state
    this.checkInput()
  }

  checkInput() {
    // Toggle between mic and send button based on input content
    if (this.hasMessageInputTarget && this.hasMicBtnTarget && this.hasSendBtnTarget) {
      const hasText = this.messageInputTarget.value.trim().length > 0
      if (hasText) {
        this.micBtnTarget.classList.add("hidden")
        this.sendBtnTarget.classList.remove("hidden")
      } else {
        this.micBtnTarget.classList.remove("hidden")
        this.sendBtnTarget.classList.add("hidden")
      }
    }
  }

  async startRecording() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          sampleRate: 44100
        }
      })

      this.stream = stream

      // Determine supported mime type
      const mimeType = this.getSupportedMimeType()
      console.log("Using mime type:", mimeType)

      const options = mimeType ? { mimeType } : {}
      this.mediaRecorder = new MediaRecorder(stream, options)
      this.audioChunks = []

      this.mediaRecorder.ondataavailable = (event) => {
        console.log("Data available:", event.data.size, "bytes")
        if (event.data.size > 0) {
          this.audioChunks.push(event.data)
        }
      }

      this.mediaRecorder.onstop = () => {
        console.log("Recording stopped, chunks:", this.audioChunks.length)
        const actualMimeType = this.mediaRecorder.mimeType || mimeType || "audio/webm"
        this.audioBlob = new Blob(this.audioChunks, { type: actualMimeType })
        console.log("Created blob:", this.audioBlob.size, "bytes")

        if (this.audioBlob.size > 0) {
          this.showPreview()
        } else {
          console.error("No audio data recorded")
          alert("No audio was recorded. Please try again.")
          this.showIdleState()
        }

        // Stop all tracks
        this.stream.getTracks().forEach(track => track.stop())
      }

      this.mediaRecorder.onerror = (event) => {
        console.error("MediaRecorder error:", event.error)
        alert("Recording error: " + event.error.message)
        this.showIdleState()
      }

      // Start recording - collect data every second for reliability
      this.mediaRecorder.start(1000)
      this.showRecordingState()
      this.startTimer()

    } catch (error) {
      console.error("Error accessing microphone:", error)
      alert("Could not access microphone. Please check permissions.")
    }
  }

  stopRecording() {
    if (this.mediaRecorder && this.mediaRecorder.state === "recording") {
      // Request any pending data before stopping
      this.mediaRecorder.requestData()
      this.mediaRecorder.stop()
      this.stopTimer()
    }
  }

  cancelRecording() {
    this.stopRecording()
    this.audioBlob = null
    this.audioChunks = []
    this.seconds = 0
    this.showIdleState()

    // Clear the file input
    if (this.hasFileInputTarget) {
      this.fileInputTarget.value = ""
    }
  }

  showRecordingState() {
    if (this.hasIdleStateTarget) this.idleStateTarget.classList.add("hidden")
    if (this.hasRecordingStateTarget) this.recordingStateTarget.classList.remove("hidden")
    if (this.hasPreviewStateTarget) this.previewStateTarget.classList.add("hidden")

    // Hide attachment button during recording
    const attachDropdown = this.element.querySelector(".media-upload-dropdown")
    if (attachDropdown) attachDropdown.classList.add("hidden")
  }

  showPreview() {
    if (this.hasIdleStateTarget) this.idleStateTarget.classList.add("hidden")
    if (this.hasRecordingStateTarget) this.recordingStateTarget.classList.add("hidden")
    if (this.hasPreviewStateTarget) this.previewStateTarget.classList.remove("hidden")

    // Set audio player source
    if (this.hasAudioPlayerTarget && this.audioBlob) {
      const audioUrl = URL.createObjectURL(this.audioBlob)
      this.audioPlayerTarget.src = audioUrl
    }

    // Attach blob to file input
    this.attachBlobToInput()

    // Keep attachment button hidden during preview
    const attachDropdown = this.element.querySelector(".media-upload-dropdown")
    if (attachDropdown) attachDropdown.classList.add("hidden")
  }

  showIdleState() {
    if (this.hasIdleStateTarget) this.idleStateTarget.classList.remove("hidden")
    if (this.hasRecordingStateTarget) this.recordingStateTarget.classList.add("hidden")
    if (this.hasPreviewStateTarget) this.previewStateTarget.classList.add("hidden")

    if (this.hasTimerTarget) {
      this.timerTarget.textContent = "0:00"
    }

    // Show attachment button again
    const attachDropdown = this.element.querySelector(".media-upload-dropdown")
    if (attachDropdown) attachDropdown.classList.remove("hidden")

    // Reset mic/send button state
    this.checkInput()
  }

  startTimer() {
    this.seconds = 0
    this.updateTimerDisplay()

    this.timerInterval = setInterval(() => {
      this.seconds++
      this.updateTimerDisplay()

      // Auto-stop at max duration
      if (this.seconds >= this.maxDurationValue) {
        this.stopRecording()
      }
    }, 1000)
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
  }

  updateTimerDisplay() {
    if (this.hasTimerTarget) {
      const minutes = Math.floor(this.seconds / 60)
      const secs = this.seconds % 60
      this.timerTarget.textContent = `${minutes}:${secs.toString().padStart(2, "0")}`
    }
  }

  attachBlobToInput() {
    if (!this.hasFileInputTarget || !this.audioBlob) return

    // Create a File from the Blob
    const mimeType = this.audioBlob.type
    const extension = mimeType.includes("webm") ? "webm" : "mp4"
    const file = new File([this.audioBlob], `voice_message.${extension}`, { type: mimeType })

    // Create a DataTransfer to set files on input
    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    this.fileInputTarget.files = dataTransfer.files
  }

  getSupportedMimeType() {
    const types = [
      "audio/webm;codecs=opus",
      "audio/webm",
      "audio/mp4",
      "audio/ogg;codecs=opus",
      "audio/ogg"
    ]

    for (const type of types) {
      if (MediaRecorder.isTypeSupported(type)) {
        return type
      }
    }

    return "audio/webm" // Fallback
  }

  disconnect() {
    this.stopTimer()
    if (this.mediaRecorder && this.mediaRecorder.state === "recording") {
      this.mediaRecorder.stop()
    }
  }
}
