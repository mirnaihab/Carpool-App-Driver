'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "f9514dfb586aab3abe472d7070ee66b3",
"assets/AssetManifest.json": "f8338ceae8a45fd2efb887cb9c4e3e6e",
"assets/assets/152-1520662_fast-car-png-black-sports-car-png-transparent.png": "92972a0095decd15e908677ad3ad2755",
"assets/assets/4660838.png": "65bca38a8c8143a208675c216130c713",
"assets/assets/5044445.png": "da0658522f2709022163aea506a5cc4b",
"assets/assets/5a21734b9ee9a6.5420974515121416436509.png": "7f0a0a6b34df54fecd9411f8214bc349",
"assets/assets/abasseya.jpg": "f7508468a461e7b5a79f7e4ed1cce477",
"assets/assets/abdubasha.jpg": "a71c8cfbe0a3c96e8637d233c126f271",
"assets/assets/alkoba.jpg": "b556b7c15a5248a412287201227d0499",
"assets/assets/Animation%2520-%25201700348934567.json": "e20bc3dfbcc1c240bf339ba32ba8e6bc",
"assets/assets/approved.png": "f7d0ccc772bcfa668acd2f021856ea1a",
"assets/assets/car-sharing.png": "2e3448071f4c42a0ee6c4a13425eb5b8",
"assets/assets/car.png": "63e7317c4e0ed9875d0f34d74a067265",
"assets/assets/car2.png": "3df69c6a6768b30512956f66a356e7a7",
"assets/assets/Card.png": "3d5a0133ee9ce2eb2e37085158cbd47f",
"assets/assets/carsharing.png": "564dd86bfbc14d249c839477d9e0652d",
"assets/assets/declined.png": "07c942245ebf0348566412772c30e45c",
"assets/assets/El%2520Sheikh%2520Zayed.jpg": "222a6f932e46e1324ac058f293afe3e5",
"assets/assets/elrehab.jpg": "bc0e19aa4afd26255451f17a1e87d2f1",
"assets/assets/elzamalek.jpg": "b21b5cb8641bfd04046865a4ad350fea",
"assets/assets/finish.png": "d48597cbf580a845f93d37aa0b27a727",
"assets/assets/gardencity.jpg": "5e9f9e4106499d5a73b2adf9da7aca0b",
"assets/assets/Group-1184@2x.png": "743f1a8b934159f11d7dfd6ffe239776",
"assets/assets/haram.jpg": "fd5f0f0f17260414661a3603a95da507",
"assets/assets/heliopolis.jpg": "083c475e40ac809cd6b3d6a9dd2e95fd",
"assets/assets/madinaty.jpg": "e5fea893072c63c76c9bbd574e08e7b9",
"assets/assets/Mastercard.png": "7e386dc6c169e7164bd6f88bffb733c7",
"assets/assets/nasrcity.jpg": "12fa0bfa805c43969f46a193861292b6",
"assets/assets/paid.png": "df277187f86b509a758648fa0badec45",
"assets/assets/pending.png": "631962ff3981917d16ca84a03867ab92",
"assets/assets/pngtree-carpool-service-vector-red-car-png-image_5719326.png": "c25bfc30dbabbe8b09a61c083cf29400",
"assets/assets/profile.png": "055a91979264664a1ee12b9453610d82",
"assets/assets/tahrir.jpg": "59b17ed49dc90467828588acfad52cef",
"assets/FontManifest.json": "d0975c94afeb32ec4155750ce2543f5e",
"assets/fonts/MaterialIcons-Regular.otf": "d4f96ef7fbaded01a7a097e7b371cb01",
"assets/NOTICES": "ee48dbe93e090eded8bc2ef8a6465ffc",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "aa5baa8059cf00bc0524fed404c87efe",
"assets/packages/flutter_credit_card/font/halter.ttf": "4e081134892cd40793ffe67fdc3bed4e",
"assets/packages/flutter_credit_card/icons/amex.png": "f75cabd609ccde52dfc6eef7b515c547",
"assets/packages/flutter_credit_card/icons/chip.png": "5728d5ac34dbb1feac78ebfded493d69",
"assets/packages/flutter_credit_card/icons/discover.png": "62ea19837dd4902e0ae26249afe36f94",
"assets/packages/flutter_credit_card/icons/elo.png": "ffd639816704b9f20b73815590c67791",
"assets/packages/flutter_credit_card/icons/hipercard.png": "921660ec64a89da50a7c82e89d56bac9",
"assets/packages/flutter_credit_card/icons/mastercard.png": "7e386dc6c169e7164bd6f88bffb733c7",
"assets/packages/flutter_credit_card/icons/rupay.png": "a10fbeeae8d386ee3623e6160133b8a8",
"assets/packages/flutter_credit_card/icons/unionpay.png": "87176915b4abdb3fcc138d23e4c8a58a",
"assets/packages/flutter_credit_card/icons/visa.png": "f6301ad368219611958eff9bb815abfe",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"canvaskit/canvaskit.js": "bbf39143dfd758d8d847453b120c8ebb",
"canvaskit/canvaskit.wasm": "42df12e09ecc0d5a4a34a69d7ee44314",
"canvaskit/chromium/canvaskit.js": "96ae916cd2d1b7320fff853ee22aebb0",
"canvaskit/chromium/canvaskit.wasm": "be0e3b33510f5b7b0cc76cc4d3e50048",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/skwasm.wasm": "1a074e8452fe5e0d02b112e22cdcf455",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "6b515e434cea20006b3ef1726d2c8894",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "3148dc4c76de182cf7f68b5f081db08a",
"/": "3148dc4c76de182cf7f68b5f081db08a",
"main.dart.js": "47655e91eb5162d8c0813f7ed92debc9",
"manifest.json": "84cd3f2e320e96835b8bd6b6ef38784e",
"version.json": "af6fb5b37b5d6dcc27ceea9b3c54ddaf"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
