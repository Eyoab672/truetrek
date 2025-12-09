import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "address", "latitude", "longitude"]
  static values = {
    lat: Number,
    lng: Number,
    mapboxToken: String
  }

  connect() {
    this.debounceTimer = null
    this.selectedIndex = -1

    // Create dropdown if it doesn't exist
    if (!this.hasDropdownTarget) {
      const dropdown = document.createElement("div")
      dropdown.className = "place-autocomplete-dropdown"
      dropdown.dataset.placeNameAutocompleteTarget = "dropdown"
      dropdown.style.display = "none"
      this.inputTarget.parentNode.appendChild(dropdown)
    }

    // Handle clicks outside to close dropdown
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.boundHandleClickOutside)
  }

  disconnect() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
    document.removeEventListener("click", this.boundHandleClickOutside)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }

  search(event) {
    const query = this.inputTarget.value.trim()

    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    if (query.length < 2) {
      this.hideDropdown()
      return
    }

    this.debounceTimer = setTimeout(() => {
      this.fetchSuggestions(query)
    }, 300)
  }

  async fetchSuggestions(query) {
    try {
      // Fetch from both sources in parallel
      const [appPlaces, mapboxPlaces] = await Promise.all([
        this.fetchAppPlaces(query),
        this.fetchMapboxPlaces(query)
      ])

      // Combine results: app places first, then mapbox
      const allSuggestions = [
        ...appPlaces.map(p => ({ ...p, source: "app" })),
        ...mapboxPlaces.map(p => ({ ...p, source: "mapbox" }))
      ]

      // Remove duplicates by title (case-insensitive)
      const seen = new Set()
      const uniqueSuggestions = allSuggestions.filter(s => {
        const key = s.title.toLowerCase()
        if (seen.has(key)) return false
        seen.add(key)
        return true
      })

      this.displaySuggestions(uniqueSuggestions.slice(0, 8))
    } catch (error) {
      console.error("Error fetching place suggestions:", error)
      this.hideDropdown()
    }
  }

  async fetchAppPlaces(query) {
    try {
      const params = new URLSearchParams({ query })
      if (this.hasLatValue && this.hasLngValue) {
        params.append("latitude", this.latValue)
        params.append("longitude", this.lngValue)
      }

      const response = await fetch(`/places/autocomplete?${params}`, {
        headers: { "Accept": "application/json" }
      })

      if (!response.ok) return []

      const data = await response.json()
      return data.suggestions || []
    } catch (error) {
      console.error("Error fetching app places:", error)
      return []
    }
  }

  async fetchMapboxPlaces(query) {
    if (!this.hasMapboxTokenValue || !this.mapboxTokenValue) {
      return []
    }

    try {
      const proximity = this.hasLatValue && this.hasLngValue
        ? `&proximity=${this.lngValue},${this.latValue}`
        : ""

      const url = `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json?access_token=${this.mapboxTokenValue}&types=poi,address,place&limit=5${proximity}`

      const response = await fetch(url)

      if (!response.ok) return []

      const data = await response.json()
      return data.features.map(feature => ({
        title: feature.text || feature.place_name.split(",")[0],
        address: feature.place_name,
        latitude: feature.center[1],
        longitude: feature.center[0]
      }))
    } catch (error) {
      console.error("Error fetching Mapbox places:", error)
      return []
    }
  }

  displaySuggestions(suggestions) {
    if (!suggestions || suggestions.length === 0) {
      this.hideDropdown()
      return
    }

    this.dropdownTarget.innerHTML = ""
    this.selectedIndex = -1

    suggestions.forEach((suggestion, index) => {
      const item = document.createElement("div")
      item.className = "place-autocomplete-item"
      item.dataset.index = index

      const sourceLabel = suggestion.source === "app"
        ? '<span class="place-autocomplete-source app"><i class="fa-solid fa-map-pin"></i> TrueTrek</span>'
        : '<span class="place-autocomplete-source mapbox"><i class="fa-solid fa-map"></i> Mapbox</span>'

      item.innerHTML = `
        <div class="place-autocomplete-header">
          <div class="place-autocomplete-title">${this.escapeHtml(suggestion.title)}</div>
          ${sourceLabel}
        </div>
        <div class="place-autocomplete-address">${this.escapeHtml(suggestion.address || '')}</div>
      `

      item.addEventListener("click", (e) => {
        e.preventDefault()
        e.stopPropagation()
        this.selectSuggestion(suggestion)
      })

      this.dropdownTarget.appendChild(item)
    })

    // Add hint about custom input
    const hint = document.createElement("div")
    hint.className = "place-autocomplete-hint"
    hint.innerHTML = '<i class="fa-solid fa-info-circle"></i> Or keep typing to use your own place name'
    this.dropdownTarget.appendChild(hint)

    this.showDropdown()
  }

  selectSuggestion(suggestion) {
    this.inputTarget.value = suggestion.title

    if (this.hasAddressTarget) {
      this.addressTarget.value = suggestion.address || ""
    }

    if (this.hasLatitudeTarget && suggestion.latitude) {
      this.latitudeTarget.value = suggestion.latitude
    }

    if (this.hasLongitudeTarget && suggestion.longitude) {
      this.longitudeTarget.value = suggestion.longitude
    }

    this.hideDropdown()
  }

  handleKeydown(event) {
    const items = this.dropdownTarget.querySelectorAll(".place-autocomplete-item")

    if (items.length === 0) return

    switch(event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.updateSelection(items)
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.updateSelection(items)
        break
      case "Enter":
        event.preventDefault()
        if (this.selectedIndex >= 0 && items[this.selectedIndex]) {
          const title = items[this.selectedIndex].querySelector(".place-autocomplete-title").textContent
          const address = items[this.selectedIndex].querySelector(".place-autocomplete-address").textContent
          this.selectSuggestion({ title, address })
        }
        break
      case "Escape":
        this.hideDropdown()
        break
    }
  }

  updateSelection(items) {
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add("selected")
      } else {
        item.classList.remove("selected")
      }
    })
  }

  showDropdown() {
    this.dropdownTarget.style.display = "block"
  }

  hideDropdown() {
    this.dropdownTarget.style.display = "none"
    this.selectedIndex = -1
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
