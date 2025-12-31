import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "video", "canvas", "preview", "previewImage", "captureBtn", "confirmBtn", "retakeBtn", "closeBtn", "rotateBtn", "recordBtn", "stopBtn", "timer", "actionRow"]
  static values = {
    mode: { type: String, default: "photo" } // "photo" or "video"
  }

  connect() {
    this.stream = null
    this.mediaRecorder = null
    this.recordedChunks = []
    this.facingMode = "user" // Start with front camera for desktop
    this.capturedBlob = null
    this.recordingInterval = null
    this.recordingSeconds = 0
    this.photoInput = document.getElementById("message_photos_camera")
    this.videoInput = document.getElementById("message_videos_camera")
  }

  disconnect() {
    this.stopCamera()
  }

  // Check if we're on a mobile device
  isMobile() {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
  }

  // Open modal for photo capture
  openPhoto(event) {
    // On mobile, let the native capture work
    if (this.isMobile()) return

    event.preventDefault()
    event.stopPropagation()
    this.modeValue = "photo"
    this.openModal()
  }

  // Open modal for video capture
  openVideo(event) {
    // On mobile, let the native capture work
    if (this.isMobile()) return

    event.preventDefault()
    event.stopPropagation()
    this.modeValue = "video"
    this.openModal()
  }

  openModal() {
    this.modalTarget.classList.add("active")
    document.body.style.overflow = "hidden"
    this.startCamera()
    this.showCaptureState()
  }

  close() {
    this.stopCamera()
    this.stopRecording()
    this.modalTarget.classList.remove("active")
    document.body.style.overflow = ""
    this.capturedBlob = null
    this.recordedChunks = []
  }

  async startCamera() {
    try {
      const constraints = {
        video: {
          facingMode: this.facingMode,
          width: { ideal: 1920 },
          height: { ideal: 1080 }
        },
        audio: this.modeValue === "video"
      }

      this.stream = await navigator.mediaDevices.getUserMedia(constraints)
      this.videoTarget.srcObject = this.stream
      this.videoTarget.play()
    } catch (err) {
      console.error("Error accessing camera:", err)
      alert("Could not access camera. Please check permissions.")
      this.close()
    }
  }

  stopCamera() {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
      this.stream = null
    }
  }

  rotateCamera() {
    this.facingMode = this.facingMode === "user" ? "environment" : "user"
    this.stopCamera()
    this.startCamera()
  }

  // Photo capture
  capturePhoto() {
    const video = this.videoTarget
    const canvas = this.canvasTarget

    canvas.width = video.videoWidth
    canvas.height = video.videoHeight

    const ctx = canvas.getContext("2d")

    // Mirror if using front camera
    if (this.facingMode === "user") {
      ctx.translate(canvas.width, 0)
      ctx.scale(-1, 1)
    }

    ctx.drawImage(video, 0, 0, canvas.width, canvas.height)

    canvas.toBlob((blob) => {
      this.capturedBlob = blob
      this.previewImageTarget.src = URL.createObjectURL(blob)
      this.showPreviewState()
      this.stopCamera()
    }, "image/jpeg", 0.95)
  }

  // Video recording
  startRecording() {
    this.recordedChunks = []
    this.recordingSeconds = 0

    const mimeType = this.getSupportedMimeType()
    this.mediaRecorder = new MediaRecorder(this.stream, { mimeType })

    this.mediaRecorder.ondataavailable = (event) => {
      if (event.data.size > 0) {
        this.recordedChunks.push(event.data)
      }
    }

    this.mediaRecorder.onstop = () => {
      const blob = new Blob(this.recordedChunks, { type: mimeType })
      this.capturedBlob = blob
      this.previewImageTarget.src = URL.createObjectURL(blob)
      this.previewImageTarget.style.display = "none"

      // Create video preview
      const videoPreview = document.createElement("video")
      videoPreview.src = URL.createObjectURL(blob)
      videoPreview.controls = true
      videoPreview.className = "webcam-preview-video"
      this.previewTarget.appendChild(videoPreview)

      this.showPreviewState()
      this.stopCamera()
    }

    this.mediaRecorder.start(100)
    this.startTimer()
    this.showRecordingState()
  }

  stopRecording() {
    if (this.mediaRecorder && this.mediaRecorder.state === "recording") {
      this.mediaRecorder.stop()
    }
    this.stopTimer()
  }

  startTimer() {
    this.recordingSeconds = 0
    this.updateTimerDisplay()
    this.recordingInterval = setInterval(() => {
      this.recordingSeconds++
      this.updateTimerDisplay()
      // Max 5 minutes
      if (this.recordingSeconds >= 300) {
        this.stopRecording()
      }
    }, 1000)
  }

  stopTimer() {
    if (this.recordingInterval) {
      clearInterval(this.recordingInterval)
      this.recordingInterval = null
    }
  }

  updateTimerDisplay() {
    if (this.hasTimerTarget) {
      const mins = Math.floor(this.recordingSeconds / 60)
      const secs = this.recordingSeconds % 60
      this.timerTarget.textContent = `${mins}:${secs.toString().padStart(2, "0")}`
    }
  }

  getSupportedMimeType() {
    const types = ["video/webm;codecs=vp9", "video/webm;codecs=vp8", "video/webm", "video/mp4"]
    for (const type of types) {
      if (MediaRecorder.isTypeSupported(type)) return type
    }
    return "video/webm"
  }

  // Confirm and attach to form
  confirm() {
    if (!this.capturedBlob) return

    const fileInput = this.modeValue === "photo" ? this.photoInput : this.videoInput
    if (!fileInput) return

    const extension = this.modeValue === "photo" ? "jpg" : "webm"
    const filename = `capture_${Date.now()}.${extension}`

    const file = new File([this.capturedBlob], filename, { type: this.capturedBlob.type })
    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    fileInput.files = dataTransfer.files

    // Trigger change event for preview
    fileInput.dispatchEvent(new Event("change", { bubbles: true }))

    // Close the dropdown menu
    document.querySelectorAll('.media-upload-menu.show').forEach(m => m.classList.remove('show'))

    this.close()
  }

  retake() {
    this.capturedBlob = null
    this.recordedChunks = []

    // Remove video preview if exists
    const videoPreview = this.previewTarget.querySelector(".webcam-preview-video")
    if (videoPreview) videoPreview.remove()

    this.previewImageTarget.style.display = ""
    this.showCaptureState()
    this.startCamera()
  }

  // UI States
  showCaptureState() {
    this.videoTarget.style.display = "block"
    this.previewTarget.classList.add("hidden")

    // Show control row, hide action row
    const controlsRow = this.element.querySelector(".webcam-controls-row")
    if (controlsRow) controlsRow.classList.remove("hidden")
    if (this.hasActionRowTarget) this.actionRowTarget.classList.add("hidden")

    if (this.hasCaptureBtnTarget) this.captureBtnTarget.classList.remove("hidden")
    if (this.hasRecordBtnTarget) this.recordBtnTarget.classList.remove("hidden")
    if (this.hasStopBtnTarget) this.stopBtnTarget.classList.add("hidden")
    if (this.hasTimerTarget) this.timerTarget.classList.add("hidden")
    if (this.hasRotateBtnTarget) this.rotateBtnTarget.classList.remove("hidden")

    // Show appropriate button based on mode
    if (this.modeValue === "photo") {
      if (this.hasCaptureBtnTarget) this.captureBtnTarget.classList.remove("hidden")
      if (this.hasRecordBtnTarget) this.recordBtnTarget.classList.add("hidden")
    } else {
      if (this.hasCaptureBtnTarget) this.captureBtnTarget.classList.add("hidden")
      if (this.hasRecordBtnTarget) this.recordBtnTarget.classList.remove("hidden")
    }
  }

  showRecordingState() {
    if (this.hasRecordBtnTarget) this.recordBtnTarget.classList.add("hidden")
    if (this.hasStopBtnTarget) this.stopBtnTarget.classList.remove("hidden")
    if (this.hasTimerTarget) this.timerTarget.classList.remove("hidden")
    if (this.hasRotateBtnTarget) this.rotateBtnTarget.classList.add("hidden")
  }

  showPreviewState() {
    this.videoTarget.style.display = "none"
    this.previewTarget.classList.remove("hidden")

    // Hide control row, show action row
    const controlsRow = this.element.querySelector(".webcam-controls-row")
    if (controlsRow) controlsRow.classList.add("hidden")
    if (this.hasActionRowTarget) this.actionRowTarget.classList.remove("hidden")

    if (this.hasTimerTarget) this.timerTarget.classList.add("hidden")
  }
}
