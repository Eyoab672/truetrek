import { Controller } from "@hotwired/stimulus"
import offlineDB from "pwa/offline_db"
import syncService from "pwa/sync_service"

// Controller for sync badge in navbar/bottombar
// Shows pending item count and sync status
export default class extends Controller {
  static targets = ["count", "icon"]

  async connect() {
    await offlineDB.init();

    // Listen for pending count updates
    window.addEventListener('pwa:pending-updated', this.boundUpdate = this.updateCount.bind(this));

    // Subscribe to sync service updates
    this.unsubscribe = syncService.onSyncUpdate(this.handleSyncUpdate.bind(this));

    // Initial count
    this.updateCount();
  }

  disconnect() {
    window.removeEventListener('pwa:pending-updated', this.boundUpdate);
    if (this.unsubscribe) this.unsubscribe();
  }

  async updateCount() {
    const count = await syncService.getPendingCount();

    if (this.hasCountTarget) {
      this.countTarget.textContent = count;
      this.countTarget.classList.toggle('d-none', count === 0);
    }

    // Update icon visibility
    if (this.hasIconTarget) {
      this.iconTarget.classList.toggle('d-none', count === 0);
    }
  }

  handleSyncUpdate(event) {
    switch (event.type) {
      case 'sync_started':
        if (this.hasIconTarget) {
          this.iconTarget.classList.add('syncing');
        }
        break;

      case 'sync_completed':
      case 'sync_error':
        if (this.hasIconTarget) {
          this.iconTarget.classList.remove('syncing');
        }
        this.updateCount();
        break;

      case 'comment_synced':
      case 'photo_synced':
        this.updateCount();
        break;
    }
  }
}
