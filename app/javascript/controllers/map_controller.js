import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl'

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array,
    pop: Boolean,
  }
  connect() {
    mapboxgl.accessToken = this.apiKeyValue
    this.map = new mapboxgl.Map({
      container: this.element,
      zoom: 9, // starting zoom
      // style: "mapbox://styles/mapbox/standard-satellite", // not working
      style: "mapbox://styles/roukiasabry/cmist36hs001h01r6142a7chf", // not working
    });
    this.#addMarkersToMap()
    this.#fitMapToMarkers()
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
