// TrueTrek Service Worker
const CACHE_VERSION = 'v1';
const STATIC_CACHE = `truetrek-static-${CACHE_VERSION}`;
const IMAGES_CACHE = `truetrek-images-${CACHE_VERSION}`;
const PAGES_CACHE = `truetrek-pages-${CACHE_VERSION}`;

// Static assets to precache on install
const PRECACHE_ASSETS = [
  '/',
  '/manifest.json',
  '/icon.png',
  '/icon-192.png',
  '/offline.html'
];

// Install event - precache static assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE).then((cache) => {
      return cache.addAll(PRECACHE_ASSETS);
    })
  );
  self.skipWaiting();
});

// Activate event - cleanup old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name.startsWith('truetrek-') && !name.endsWith(CACHE_VERSION))
          .map((name) => caches.delete(name))
      );
    })
  );
  self.clients.claim();
});

// Fetch event - routing strategy
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Skip non-GET requests (handled by sync)
  if (event.request.method !== 'GET') {
    return;
  }

  // Skip chrome-extension and other non-http(s) requests
  if (!url.protocol.startsWith('http')) {
    return;
  }

  // Static assets (CSS, JS, fonts)
  if (url.pathname.startsWith('/assets/') ||
      url.pathname.endsWith('.css') ||
      url.pathname.endsWith('.js') ||
      url.pathname.endsWith('.woff2') ||
      url.pathname.endsWith('.woff')) {
    event.respondWith(cacheFirst(event.request, STATIC_CACHE));
    return;
  }

  // Cloudinary images
  if (url.hostname.includes('cloudinary.com') ||
      url.hostname.includes('res.cloudinary.com')) {
    event.respondWith(cacheFirst(event.request, IMAGES_CACHE));
    return;
  }

  // Local images
  if (url.pathname.match(/\.(png|jpg|jpeg|gif|svg|webp|ico)$/)) {
    event.respondWith(cacheFirst(event.request, IMAGES_CACHE));
    return;
  }

  // HTML pages - Network first with cache fallback
  if (event.request.headers.get('Accept')?.includes('text/html')) {
    event.respondWith(networkFirstWithCache(event.request, PAGES_CACHE));
    return;
  }

  // Default: network only
  event.respondWith(fetch(event.request));
});

// Cache-first strategy
async function cacheFirst(request, cacheName) {
  const cached = await caches.match(request);
  if (cached) return cached;

  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(cacheName);
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    // Return a placeholder for failed image requests
    if (request.url.match(/\.(png|jpg|jpeg|gif|svg|webp)$/)) {
      return new Response('', { status: 404 });
    }
    return new Response('Offline', { status: 503 });
  }
}

// Network-first with cache fallback
async function networkFirstWithCache(request, cacheName) {
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(cacheName);
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    const cached = await caches.match(request);
    if (cached) return cached;

    // Return offline page
    return caches.match('/offline.html');
  }
}

// Background Sync for offline actions
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-comments') {
    event.waitUntil(notifyClientsToSync('SYNC_COMMENTS'));
  }
  if (event.tag === 'sync-photos') {
    event.waitUntil(notifyClientsToSync('SYNC_PHOTOS'));
  }
});

async function notifyClientsToSync(type) {
  const clients = await self.clients.matchAll();
  clients.forEach(client => {
    client.postMessage({ type: type });
  });
}

// Listen for messages from the app
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
