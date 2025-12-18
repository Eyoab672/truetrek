import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    steps: Array,
    completeUrl: String
  }

  static targets = ["overlay", "tooltip", "content", "stepIndicator", "prevBtn", "nextBtn"]

  connect() {
    this.currentStep = 0
    this.showTour()
  }

  showTour() {
    this.overlayTarget.classList.remove("d-none")
    this.showStep(0)
  }

  showStep(index) {
    if (index < 0 || index >= this.stepsValue.length) return

    this.currentStep = index
    const step = this.stepsValue[index]

    // Update content
    this.contentTarget.innerHTML = `
      <h4 class="tour-title">${step.title}</h4>
      <p class="tour-description">${step.description}</p>
    `

    // Update step indicator
    this.stepIndicatorTarget.textContent = `${index + 1} / ${this.stepsValue.length}`

    // Update buttons
    this.prevBtnTarget.style.visibility = index === 0 ? "hidden" : "visible"
    this.nextBtnTarget.textContent = index === this.stepsValue.length - 1 ? "Get Started!" : "Next"

    // Position tooltip near target element if specified
    if (step.target) {
      const targetEl = document.querySelector(step.target)
      if (targetEl) {
        this.highlightElement(targetEl, step.position || "bottom")
      } else {
        this.centerTooltip()
      }
    } else {
      this.centerTooltip()
    }
  }

  highlightElement(element, position) {
    // Remove previous spotlight
    const oldSpotlight = document.querySelector(".tour-spotlight")
    if (oldSpotlight) oldSpotlight.remove()

    // Create spotlight around element
    const rect = element.getBoundingClientRect()
    const spotlight = document.createElement("div")
    spotlight.className = "tour-spotlight"
    spotlight.style.cssText = `
      position: fixed;
      top: ${rect.top - 8}px;
      left: ${rect.left - 8}px;
      width: ${rect.width + 16}px;
      height: ${rect.height + 16}px;
      border-radius: 12px;
      box-shadow: 0 0 0 9999px rgba(0, 0, 0, 0.75);
      z-index: 10000;
      pointer-events: none;
    `
    document.body.appendChild(spotlight)

    // Position tooltip
    const tooltip = this.tooltipTarget
    const tooltipRect = tooltip.getBoundingClientRect()

    let top, left

    switch (position) {
      case "top":
        top = rect.top - tooltipRect.height - 20
        left = rect.left + (rect.width - tooltipRect.width) / 2
        break
      case "bottom":
        top = rect.bottom + 20
        left = rect.left + (rect.width - tooltipRect.width) / 2
        break
      case "left":
        top = rect.top + (rect.height - tooltipRect.height) / 2
        left = rect.left - tooltipRect.width - 20
        break
      case "right":
        top = rect.top + (rect.height - tooltipRect.height) / 2
        left = rect.right + 20
        break
      default:
        top = rect.bottom + 20
        left = rect.left + (rect.width - tooltipRect.width) / 2
    }

    // Keep tooltip in viewport
    const padding = 20
    top = Math.max(padding, Math.min(top, window.innerHeight - tooltipRect.height - padding))
    left = Math.max(padding, Math.min(left, window.innerWidth - tooltipRect.width - padding))

    tooltip.style.position = "fixed"
    tooltip.style.top = `${top}px`
    tooltip.style.left = `${left}px`
    tooltip.style.transform = "none"

    // Scroll element into view if needed
    element.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  centerTooltip() {
    // Remove any spotlight
    const oldSpotlight = document.querySelector(".tour-spotlight")
    if (oldSpotlight) oldSpotlight.remove()

    const tooltip = this.tooltipTarget
    tooltip.style.position = "fixed"
    tooltip.style.top = "50%"
    tooltip.style.left = "50%"
    tooltip.style.transform = "translate(-50%, -50%)"
  }

  prev() {
    this.showStep(this.currentStep - 1)
  }

  next() {
    if (this.currentStep === this.stepsValue.length - 1) {
      this.complete()
    } else {
      this.showStep(this.currentStep + 1)
    }
  }

  skip() {
    this.complete()
  }

  complete() {
    // Remove spotlight
    const spotlight = document.querySelector(".tour-spotlight")
    if (spotlight) spotlight.remove()

    // Hide overlay
    this.overlayTarget.classList.add("d-none")

    // Mark tour as complete on server
    fetch(this.completeUrlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json"
      }
    })
  }

  // Handle escape key
  keydown(event) {
    if (event.key === "Escape") {
      this.skip()
    } else if (event.key === "ArrowRight") {
      this.next()
    } else if (event.key === "ArrowLeft") {
      this.prev()
    }
  }
}
