import { Controller } from "@hotwired/stimulus"
import offlineDB from "pwa/offline_db"
import syncService from "pwa/sync_service"

// Main offline state management controller
// Handles online/offline detection, sync status, and service worker messages
export default class extends Controller {
  static targets = ["indicator", "badge", "syncButton", "syncStatus"]

  async connect() {
    await offlineDB.init();

    // Listen for online/offline events
    window.addEventListener('online', this.handleOnline.bind(this));
    window.addEventListener('offline', this.handleOffline.bind(this));

    // Listen for service worker messages
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.addEventListener('message', this.handleSWMessage.bind(this));
    }

    // Subscribe to sync service updates
    syncService.onSyncUpdate(this.handleSyncUpdate.bind(this));

    // Listen for custom events from other controllers
    window.addEventListener('pwa:pending-updated', this.updatePendingCount.bind(this));

    // Initial state check
    this.updateOnlineStatus();
    this.updatePendingCount();
  }

  disconnect() {
    window.removeEventListener('online', this.handleOnline.bind(this));
    window.removeEventListener('offline', this.handleOffline.bind(this));
    window.removeEventListener('pwa:pending-updated', this.updatePendingCount.bind(this));
  }

  handleOnline() {
    this.updateOnlineStatus();
    // Auto-sync when coming back online
    this.triggerSync();
  }

  handleOffline() {
    this.updateOnlineStatus();
  }

  updateOnlineStatus() {
    const isOnline = navigator.onLine;
    document.body.classList.toggle('offline-mode', !isOnline);

    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.toggle('d-none', isOnline);
    }
  }

  async updatePendingCount() {
    const count = await syncService.getPendingCount();

    if (this.hasBadgeTarget) {
      this.badgeTarget.textContent = count;
      this.badgeTarget.classList.toggle('d-none', count === 0);
    }

    // Show/hide sync button based on pending items
    if (this.hasSyncButtonTarget) {
      this.syncButtonTarget.classList.toggle('d-none', count === 0);
    }
  }

  async triggerSync() {
    if (!navigator.onLine) {
      this.showNotification('You are offline. Items will sync when you reconnect.', 'warning');
      return;
    }

    // Update button state
    if (this.hasSyncButtonTarget) {
      this.syncButtonTarget.classList.add('syncing');
      this.syncButtonTarget.disabled = true;
    }

    // Try background sync first, fallback to manual sync
    const backgroundSyncRegistered = await syncService.registerBackgroundSync();
    if (!backgroundSyncRegistered) {
      await syncService.syncAll();
    }
  }

  handleSWMessage(event) {
    if (event.data.type === 'SYNC_COMMENTS' || event.data.type === 'SYNC_PHOTOS') {
      syncService.syncAll();
    }
  }

  handleSyncUpdate(event) {
    switch (event.type) {
      case 'sync_started':
        if (this.hasSyncStatusTarget) {
          this.syncStatusTarget.textContent = 'Syncing...';
        }
        break;

      case 'sync_completed':
        this.updatePendingCount();
        if (this.hasSyncButtonTarget) {
          this.syncButtonTarget.classList.remove('syncing');
          this.syncButtonTarget.disabled = false;
        }
        const total = event.results.photos.synced + event.results.comments.synced;
        if (total > 0) {
          this.showNotification(`Synced ${total} item${total > 1 ? 's' : ''} successfully!`, 'success');
        }
        break;

      case 'sync_error':
        if (this.hasSyncButtonTarget) {
          this.syncButtonTarget.classList.remove('syncing');
          this.syncButtonTarget.disabled = false;
        }
        this.showNotification('Sync failed. Please try again.', 'error');
        break;

      case 'comment_synced':
      case 'photo_synced':
        this.updatePendingCount();
        break;
    }
  }

  showNotification(message, type = 'info') {
    // Dispatch event for flash message system
    const event = new CustomEvent('pwa:notification', {
      detail: { message, type }
    });
    window.dispatchEvent(event);

    // Also create a toast notification if flash system not available
    this.createToast(message, type);
  }

  createToast(message, type) {
    const existing = document.querySelector('.pwa-toast');
    if (existing) existing.remove();

    const toast = document.createElement('div');
    toast.className = `pwa-toast pwa-toast-${type}`;
    toast.innerHTML = `
      <span>${message}</span>
      <button class="pwa-toast-close" onclick="this.parentElement.remove()">&times;</button>
    `;
    document.body.appendChild(toast);

    // Auto-remove after 5 seconds
    setTimeout(() => toast.remove(), 5000);
  }
}
