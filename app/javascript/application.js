// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"
import "camera"

// Scroll to top on full page load/refresh
if (history.scrollRestoration) {
  history.scrollRestoration = 'manual'
}

document.addEventListener('DOMContentLoaded', () => {
  window.scrollTo(0, 0)
})
