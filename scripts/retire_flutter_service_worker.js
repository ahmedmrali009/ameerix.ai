'use strict';
// Replaces the old worker at its original URL so existing installations update.
self.addEventListener('install', event => event.waitUntil(self.skipWaiting()));
self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const names = await caches.keys();
    await Promise.all(names.filter(name =>
      ['flutter-app-cache', 'flutter-temp-cache', 'flutter-app-manifest'].includes(name)
    ).map(name => caches.delete(name)));
    await self.registration.unregister();
    const windows = await self.clients.matchAll({type: 'window', includeUncontrolled: true});
    await Promise.allSettled(windows.map(client => client.navigate(client.url)));
  })());
});
