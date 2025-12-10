import { Controller } from "@hotwired/stimulus"
import offlineDB from "pwa/offline_db"

// Controller for handling comment forms when offline
// Intercepts form submission and saves to IndexedDB if offline
export default class extends Controller {
  static targets = ["form", "description", "submitBtn", "offlineNotice"]
  static values = {
    placeId: Number,
    cityId: Number
  }

  connect() {
    this.checkOnlineStatus();
    window.addEventListener('online', this.boundCheckOnline = this.checkOnlineStatus.bind(this));
    window.addEventListener('offline', this.boundCheckOffline = this.checkOnlineStatus.bind(this));
  }

  disconnect() {
    window.removeEventListener('online', this.boundCheckOnline);
    window.removeEventListener('offline', this.boundCheckOffline);
  }

  checkOnlineStatus() {
    const isOffline = !navigator.onLine;

    if (this.hasOfflineNoticeTarget) {
      this.offlineNoticeTarget.classList.toggle('d-none', !isOffline);
    }

    if (this.hasSubmitBtnTarget) {
      if (isOffline) {
        this.submitBtnTarget.dataset.originalText = this.submitBtnTarget.textContent;
        this.submitBtnTarget.textContent = 'Save for Later';
      } else if (this.submitBtnTarget.dataset.originalText) {
        this.submitBtnTarget.textContent = this.submitBtnTarget.dataset.originalText;
      }
    }
  }

  async submit(event) {
    // Only intercept if offline
    if (!navigator.onLine) {
      event.preventDefault();
      await this.saveOffline();
    }
    // If online, let the form submit normally via Turbo
  }

  async saveOffline() {
    const description = this.hasDescriptionTarget ? this.descriptionTarget.value : '';

    // Validate minimum length (matching server-side validation)
    if (description.length < 20) {
      this.showError('Comment must be at least 20 characters');
      return;
    }

    try {
      await offlineDB.init();

      await offlineDB.addPendingComment({
        place_id: this.placeIdValue,
        city_id: this.cityIdValue,
        description: description
      });

      // Clear form
      if (this.hasDescriptionTarget) {
        this.descriptionTarget.value = '';
      }

      // Show confirmation
      this.showOfflineConfirmation();

      // Notify offline controller to update pending count
      window.dispatchEvent(new CustomEvent('pwa:pending-updated'));

    } catch (error) {
      console.error('Failed to save comment offline:', error);
      this.showError('Failed to save comment. Please try again.');
    }
  }

  showOfflineConfirmation() {
    // Remove any existing notice
    const existing = this.element.querySelector('.offline-saved-notice');
    if (existing) existing.remove();

    const notice = document.createElement('div');
    notice.className = 'offline-saved-notice';
    notice.innerHTML = `
      <i class="fa-solid fa-cloud-arrow-up"></i>
      <span>Comment saved! It will be posted when you're back online.</span>
    `;

    // Insert after the form or submit button
    if (this.hasFormTarget) {
      this.formTarget.insertAdjacentElement('afterend', notice);
    } else {
      this.element.appendChild(notice);
    }

    // Auto-remove after 5 seconds
    setTimeout(() => notice.remove(), 5000);
  }

  showError(message) {
    // Remove any existing error
    const existing = this.element.querySelector('.offline-error-notice');
    if (existing) existing.remove();

    const notice = document.createElement('div');
    notice.className = 'offline-error-notice';
    notice.innerHTML = `
      <i class="fa-solid fa-exclamation-circle"></i>
      <span>${message}</span>
    `;

    if (this.hasFormTarget) {
      this.formTarget.insertAdjacentElement('beforebegin', notice);
    } else {
      this.element.prepend(notice);
    }

    setTimeout(() => notice.remove(), 5000);
  }
}
