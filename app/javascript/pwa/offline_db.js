// TrueTrek Offline Database using IndexedDB
const DB_NAME = 'truetrek-offline';
const DB_VERSION = 1;

const STORES = {
  PENDING_COMMENTS: 'pending_comments',
  PENDING_PHOTOS: 'pending_photos',
  SYNC_META: 'sync_meta'
};

class OfflineDB {
  constructor() {
    this.db = null;
    this.initPromise = null;
  }

  async init() {
    if (this.db) return this;
    if (this.initPromise) return this.initPromise;

    this.initPromise = new Promise((resolve, reject) => {
      const request = indexedDB.open(DB_NAME, DB_VERSION);

      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        this.db = request.result;
        resolve(this);
      };

      request.onupgradeneeded = (event) => {
        const db = event.target.result;

        // Pending comments store
        if (!db.objectStoreNames.contains(STORES.PENDING_COMMENTS)) {
          const commentsStore = db.createObjectStore(STORES.PENDING_COMMENTS, {
            keyPath: 'local_id',
            autoIncrement: true
          });
          commentsStore.createIndex('place_id', 'place_id', { unique: false });
          commentsStore.createIndex('status', 'status', { unique: false });
          commentsStore.createIndex('created_at', 'created_at', { unique: false });
        }

        // Pending photos store
        if (!db.objectStoreNames.contains(STORES.PENDING_PHOTOS)) {
          const photosStore = db.createObjectStore(STORES.PENDING_PHOTOS, {
            keyPath: 'local_id',
            autoIncrement: true
          });
          photosStore.createIndex('place_id', 'place_id', { unique: false });
          photosStore.createIndex('status', 'status', { unique: false });
          photosStore.createIndex('created_at', 'created_at', { unique: false });
        }

        // Sync metadata store
        if (!db.objectStoreNames.contains(STORES.SYNC_META)) {
          db.createObjectStore(STORES.SYNC_META, { keyPath: 'key' });
        }
      };
    });

    return this.initPromise;
  }

  // Add a record to a store
  async add(storeName, data) {
    await this.init();
    return this._transaction(storeName, 'readwrite', (store) => {
      return store.add({ ...data, cached_at: Date.now() });
    });
  }

  // Put (update or insert) a record
  async put(storeName, data) {
    await this.init();
    return this._transaction(storeName, 'readwrite', (store) => {
      return store.put({ ...data, cached_at: Date.now() });
    });
  }

  // Get a single record by key
  async get(storeName, key) {
    await this.init();
    return this._transaction(storeName, 'readonly', (store) => {
      return store.get(key);
    });
  }

  // Get all records from a store
  async getAll(storeName) {
    await this.init();
    return this._transaction(storeName, 'readonly', (store) => {
      return store.getAll();
    });
  }

  // Delete a record by key
  async delete(storeName, key) {
    await this.init();
    return this._transaction(storeName, 'readwrite', (store) => {
      return store.delete(key);
    });
  }

  // Get records by index value
  async getByIndex(storeName, indexName, value) {
    await this.init();
    return this._transaction(storeName, 'readonly', (store) => {
      const index = store.index(indexName);
      return index.getAll(value);
    });
  }

  // Clear all records in a store
  async clear(storeName) {
    await this.init();
    return this._transaction(storeName, 'readwrite', (store) => {
      return store.clear();
    });
  }

  // Count records in a store
  async count(storeName) {
    await this.init();
    return this._transaction(storeName, 'readonly', (store) => {
      return store.count();
    });
  }

  // Internal transaction helper
  _transaction(storeName, mode, callback) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(storeName, mode);
      const store = tx.objectStore(storeName);
      const request = callback(store);

      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  // Convenience methods for pending comments
  async addPendingComment(commentData) {
    return this.add(STORES.PENDING_COMMENTS, {
      ...commentData,
      status: 'pending',
      created_at: Date.now(),
      retry_count: 0
    });
  }

  async getPendingComments() {
    return this.getByIndex(STORES.PENDING_COMMENTS, 'status', 'pending');
  }

  async updateCommentStatus(localId, status, error = null) {
    const comment = await this.get(STORES.PENDING_COMMENTS, localId);
    if (comment) {
      comment.status = status;
      if (error) comment.error = error;
      if (status === 'failed') comment.retry_count = (comment.retry_count || 0) + 1;
      return this.put(STORES.PENDING_COMMENTS, comment);
    }
  }

  async deletePendingComment(localId) {
    return this.delete(STORES.PENDING_COMMENTS, localId);
  }

  // Convenience methods for pending photos
  async addPendingPhoto(photoData) {
    return this.add(STORES.PENDING_PHOTOS, {
      ...photoData,
      status: 'pending',
      created_at: Date.now(),
      retry_count: 0
    });
  }

  async getPendingPhotos() {
    return this.getByIndex(STORES.PENDING_PHOTOS, 'status', 'pending');
  }

  async updatePhotoStatus(localId, status, error = null) {
    const photo = await this.get(STORES.PENDING_PHOTOS, localId);
    if (photo) {
      photo.status = status;
      if (error) photo.error = error;
      if (status === 'failed') photo.retry_count = (photo.retry_count || 0) + 1;
      return this.put(STORES.PENDING_PHOTOS, photo);
    }
  }

  async deletePendingPhoto(localId) {
    return this.delete(STORES.PENDING_PHOTOS, localId);
  }

  // Get total pending count
  async getPendingCount() {
    const comments = await this.getPendingComments();
    const photos = await this.getPendingPhotos();
    return comments.length + photos.length;
  }

  // Get all failed items
  async getFailedItems() {
    const comments = await this.getByIndex(STORES.PENDING_COMMENTS, 'status', 'failed');
    const photos = await this.getByIndex(STORES.PENDING_PHOTOS, 'status', 'failed');
    return { comments, photos };
  }
}

// Export singleton instance
const offlineDB = new OfflineDB();
export default offlineDB;
export { STORES };
