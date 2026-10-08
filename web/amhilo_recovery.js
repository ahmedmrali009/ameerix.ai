// Retire only this site's legacy Flutter offline cache; preserve preferences.
async function retireAmhiloCache() {
  let removed = false;
  if ('serviceWorker' in navigator) {
    const registrations = await navigator.serviceWorker.getRegistrations();
    for (const registration of registrations) {
      const workers = [registration.active, registration.waiting, registration.installing];
      if (workers.some(worker => worker && new URL(worker.scriptURL).pathname.endsWith('/flutter_service_worker.js'))) {
        removed = (await registration.unregister()) || removed;
      }
    }
  }
  if ('caches' in window) {
    const names = await caches.keys();
    await Promise.all(names.filter(name =>
      ['flutter-app-cache', 'flutter-temp-cache', 'flutter-app-manifest'].includes(name)
    ).map(name => caches.delete(name)));
  }
  return removed;
}
