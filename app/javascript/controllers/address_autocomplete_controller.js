import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="address-autocomplete"
export default class extends Controller {
  static values = { apiKey: String }
  static targets = ["address", "latitude", "longitude", "citySelect"]

  connect() {
    this.selectedCity = null
    this.cityCoords = null
    this.suggestionsContainer = null
    this.debounceTimer = null

    // Create suggestions container
    this.#createSuggestionsContainer()

    // Add input listener to address field
    if (this.hasAddressTarget) {
      this.addressTarget.addEventListener("input", this.#handleInput.bind(this))
      this.addressTarget.addEventListener("focus", this.#handleFocus.bind(this))
    }

    // Close suggestions when clicking outside
    document.addEventListener("click", this.#handleClickOutside.bind(this))

    // Check for pre-selected city on connect
    if (this.hasCitySelectTarget) {
      this.#initializeFromSelectedCity()
    }
  }

  #initializeFromSelectedCity() {
    const select = this.citySelectTarget
    const selectedOption = select.options[select.selectedIndex]

    if (selectedOption && selectedOption.value) {
      this.selectedCity = selectedOption.text
      this.#geocodeCity()
    }
  }

  disconnect() {
    if (this.suggestionsContainer) {
      this.suggestionsContainer.remove()
    }
    document.removeEventListener("click", this.#handleClickOutside.bind(this))
  }

  cityChanged() {
    const select = this.citySelectTarget
    const selectedOption = select.options[select.selectedIndex]

    if (!selectedOption || !selectedOption.value) {
      this.selectedCity = null
      this.cityCoords = null
      return
    }

    this.selectedCity = selectedOption.text
    this.#geocodeCity()
  }

  #createSuggestionsContainer() {
    if (!this.hasAddressTarget) return

    this.suggestionsContainer = document.createElement("div")
    this.suggestionsContainer.className = "address-suggestions"
    this.suggestionsContainer.style.cssText = `
      position: absolute;
      z-index: 1000;
      background: white;
      border: 1px solid #ddd;
      border-top: none;
      border-radius: 0 0 4px 4px;
      max-height: 200px;
      overflow-y: auto;
      display: none;
      box-shadow: 0 2px 8px rgba(0,0,0,0.15);
      width: 100%;
      left: 0;
      top: 100%;
      margin-top: 0;
    `

    // Position relative to the input wrapper
    const inputWrapper = this.addressTarget.closest(".input") || this.addressTarget.parentElement
    inputWrapper.style.position = "relative"
    inputWrapper.appendChild(this.suggestionsContainer)
  }

  #handleInput(event) {
    const query = event.target.value

    // Clear previous timer
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    if (query.length < 3) {
      this.#hideSuggestions()
      return
    }

    // Debounce the search
    this.debounceTimer = setTimeout(() => {
      this.#searchAddress(query)
    }, 300)
  }

  #handleFocus() {
    const query = this.addressTarget.value
    if (query.length >= 3) {
      this.#searchAddress(query)
    }
  }

  #handleClickOutside(event) {
    if (!this.addressTarget.contains(event.target) && !this.suggestionsContainer.contains(event.target)) {
      this.#hideSuggestions()
    }
  }

  async #searchAddress(query) {
    if (!this.apiKeyValue) return

    // Build search query - if city is selected, append it to improve results
    let searchQuery = query
    if (this.selectedCity && !query.toLowerCase().includes(this.selectedCity.toLowerCase())) {
      searchQuery = `${query}, ${this.selectedCity}`
    }

    let url = `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(searchQuery)}.json?access_token=${this.apiKeyValue}&types=address&limit=5&autocomplete=true`

    // Add proximity bias if we have city coordinates
    if (this.cityCoords) {
      url += `&proximity=${this.cityCoords.longitude},${this.cityCoords.latitude}`
    }

    try {
      const response = await fetch(url)
      const data = await response.json()

      if (data.features && data.features.length > 0) {
        // Filter results to selected city if available
        let results = data.features
        if (this.selectedCity) {
          results = results.filter(item => this.#isInSelectedCity(item))
        }
        this.#showSuggestions(results)
      } else {
        this.#hideSuggestions()
      }
    } catch (error) {
      console.error("Error searching address:", error)
      this.#hideSuggestions()
    }
  }

  #geocodeCity() {
    if (!this.selectedCity || !this.apiKeyValue) return

    fetch(`https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(this.selectedCity)}.json?access_token=${this.apiKeyValue}&types=place&limit=1`)
      .then(response => response.json())
      .then(data => {
        if (data.features && data.features.length > 0) {
          const coords = data.features[0].center
          this.cityCoords = { longitude: coords[0], latitude: coords[1] }
        }
      })
      .catch(error => console.error("Error geocoding city:", error))
  }

  #isInSelectedCity(item) {
    if (!this.selectedCity) return true

    const placeName = item.place_name.toLowerCase()
    const cityName = this.selectedCity.toLowerCase()

    return placeName.includes(cityName)
  }

  #showSuggestions(results) {
    if (!this.suggestionsContainer) return

    this.suggestionsContainer.innerHTML = ""

    results.forEach(result => {
      const item = document.createElement("div")
      item.className = "address-suggestion-item"
      item.style.cssText = `
        padding: 10px 12px;
        cursor: pointer;
        border-bottom: 1px solid #eee;
        font-size: 14px;
      `
      item.textContent = result.place_name
      item.addEventListener("mouseenter", () => {
        item.style.backgroundColor = "#f5f5f5"
      })
      item.addEventListener("mouseleave", () => {
        item.style.backgroundColor = "white"
      })
      item.addEventListener("click", () => {
        this.#selectSuggestion(result)
      })

      this.suggestionsContainer.appendChild(item)
    })

    this.suggestionsContainer.style.display = "block"
  }

  #hideSuggestions() {
    if (this.suggestionsContainer) {
      this.suggestionsContainer.style.display = "none"
    }
  }

  #selectSuggestion(result) {
    this.addressTarget.value = result.place_name

    if (this.hasLatitudeTarget && this.hasLongitudeTarget && result.center) {
      this.longitudeTarget.value = result.center[0]
      this.latitudeTarget.value = result.center[1]
    }

    this.#hideSuggestions()
  }
}