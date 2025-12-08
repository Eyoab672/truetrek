import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl'

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array,
    pop: Boolean,
    center: Array, // Optional [lng, lat] for initial center
    zoom: { type: Number, default: 9 },
  }
  connect() {
    console.log(mapboxgl.version);

    mapboxgl.accessToken = this.apiKeyValue

    const mapOptions = {
      container: this.element,
      zoom: this.zoomValue,
      style: "mapbox://styles/roukiasabry/cmist36hs001h01r6142a7chf",
    }

    // If center is provided, use it; otherwise map will fit to markers
    if (this.hasCenterValue && this.centerValue.length === 2) {
      mapOptions.center = this.centerValue
    }

    this.map = new mapboxgl.Map(mapOptions);
    this.#addMarkersToMap()

    // Only fit to markers if no center was specified
    if (!this.hasCenterValue || this.centerValue.length !== 2) {
      this.#fitMapToMarkers()
    }

    this.map.addControl(new mapboxgl.NavigationControl());
  }
  #addMarkersToMap() {
    this.markersValue.forEach((marker) => {
      const popup = new mapboxgl.Popup().setHTML(marker.info_window_html)
      const mapboxMarker = new mapboxgl.Marker().setLngLat([marker.lng, marker.lat])
      if (this.popValue === true) {
        mapboxMarker.setPopup(popup) // Added this
      }
      mapboxMarker.addTo(this.map)
    })
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds()
    this.markersValue.forEach(marker => bounds.extend([marker.lng, marker.lat]))
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 })
  }
}
