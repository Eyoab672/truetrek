// TrueTrek Sync Service - handles syncing offline data when back online
import offlineDB from "./offline_db";

class SyncService {
  constructor() {
    this.syncInProgress = false;
    this.listeners = new Set();
  }

  // Subscribe to sync events
  onSyncUpdate(callback) {
    this.listeners.add(callback);
    return () => this.listeners.delete(callback);
  }

  // Notify all listeners of sync status change
  notifyListeners(event) {
    this.listeners.forEach(callback => callback(event));
  }

  // Get CSRF token from meta tag
  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content;
  }

  // Sync all pending items
  async syncAll() {
    if (this.syncInProgress || !navigator.onLine) {
      return { success: false, reason: this.syncInProgress ? 'sync_in_progress' : 'offline' };
    }

    this.syncInProgress = true;
    this.notifyListeners({ type: 'sync_started' });

    try {
      const photoResults = await this.syncPhotos();
      const commentResults = await this.syncComments();

      const results = {
        success: true,
        photos: photoResults,
        comments: commentResults
      };

      this.notifyListeners({ type: 'sync_completed', results });
      return results;
    } catch (error) {
      this.notifyListeners({ type: 'sync_error', error: error.message });
      return { success: false, error: error.message };
    } finally {
      this.syncInProgress = false;
    }
  }

  // Sync all pending photos
  async syncPhotos() {
    const pending = await offlineDB.getPendingPhotos();
    const results = { synced: 0, failed: 0 };

    for (const photo of pending) {
      const result = await this.syncSinglePhoto(photo);
      if (result.success) {
        results.synced++;
      } else {
        results.failed++;
      }
    }

    return results;
  }

  // Sync a single photo
  async syncSinglePhoto(photo) {
    try {
      await offlineDB.updatePhotoStatus(photo.local_id, 'syncing');
      this.notifyListeners({ type: 'photo_syncing', localId: photo.local_id });

      const formData = new FormData();
      formData.append('image', photo.blob, 'capture.png');
      if (photo.latitude) formData.append('latitude', photo.latitude);
      if (photo.longitude) formData.append('longitude', photo.longitude);
      if (photo.place_id) formData.append('place_id', photo.place_id);

      const response = await fetch('/camera', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': this.getCSRFToken(),
          'Accept': 'application/json'
        },
        body: formData
      });

      if (response.ok) {
        await offlineDB.deletePendingPhoto(photo.local_id);
        this.notifyListeners({ type: 'photo_synced', localId: photo.local_id });
        return { success: true };
      } else {
        throw new Error(`Server error: ${response.status}`);
      }
    } catch (error) {
      await offlineDB.updatePhotoStatus(photo.local_id, 'failed', error.message);
      this.notifyListeners({ type: 'photo_failed', localId: photo.local_id, error: error.message });
      return { success: false, error: error.message };
    }
  }

  // Sync all pending comments
  async syncComments() {
    const pending = await offlineDB.getPendingComments();
    const results = { synced: 0, failed: 0 };

    for (const comment of pending) {
      const result = await this.syncSingleComment(comment);
      if (result.success) {
        results.synced++;
      } else {
        results.failed++;
      }
    }

    return results;
  }

  // Sync a single comment
  async syncSingleComment(comment) {
    try {
      await offlineDB.updateCommentStatus(comment.local_id, 'syncing');
      this.notifyListeners({ type: 'comment_syncing', localId: comment.local_id });

      const url = `/cities/${comment.city_id}/places/${comment.place_id}/comments`;

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken(),
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          comment: { description: comment.description }
        })
      });

      if (response.ok) {
        await offlineDB.deletePendingComment(comment.local_id);
        this.notifyListeners({ type: 'comment_synced', localId: comment.local_id });
        return { success: true };
      } else {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.errors?.join(', ') || `Server error: ${response.status}`);
      }
    } catch (error) {
      await offlineDB.updateCommentStatus(comment.local_id, 'failed', error.message);
      this.notifyListeners({ type: 'comment_failed', localId: comment.local_id, error: error.message });
      return { success: false, error: error.message };
    }
  }

  // Retry all failed items
  async retryFailed() {
    const { comments, photos } = await offlineDB.getFailedItems();

    // Reset status to pending for retry
    for (const comment of comments) {
      await offlineDB.updateCommentStatus(comment.local_id, 'pending');
    }
    for (const photo of photos) {
      await offlineDB.updatePhotoStatus(photo.local_id, 'pending');
    }

    // Now sync again
    return this.syncAll();
  }

  // Get pending count
  async getPendingCount() {
    return offlineDB.getPendingCount();
  }

  // Register for background sync if supported
  async registerBackgroundSync() {
    if ('serviceWorker' in navigator && 'sync' in ServiceWorkerRegistration.prototype) {
      try {
        const registration = await navigator.serviceWorker.ready;
        await registration.sync.register('sync-comments');
        await registration.sync.register('sync-photos');
        return true;
      } catch (error) {
        console.warn('Background sync registration failed:', error);
        return false;
      }
    }
    return false;
  }
}

// Export singleton instance
const syncService = new SyncService();
export default syncService;
