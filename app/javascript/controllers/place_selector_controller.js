import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleChange(event) {
    const selectedValue = event.target.value

    if (!selectedValue) {
      return
    }

    if (selectedValue === "new_place") {
      // Show the new place form by reloading with new_place param
      window.location.href = window.location.pathname + "?from_camera=true&new_place=true"
    } else {
      // Navigate to the selected place
      window.location.href = selectedValue
    }
  }
}
