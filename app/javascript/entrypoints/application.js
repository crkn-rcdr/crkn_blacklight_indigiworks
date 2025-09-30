// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite lightning Rails')
// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>
console.log('Visit the guide for more information: ', 'https://vite-ruby.netlify.app/guide/rails')
// Example: Load Rails libraries in Vite.
//
// import * as Turbo from '@hotwired/turbo'
// Turbo.start()
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')
// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'
//import "../javascript/application"
console.log("mirador", Mirador)
let pageViewer = document.getElementById("my-mirador")
if(pageViewer) {
    let language = document.documentElement.lang || "en";
    const documentId = pageViewer.getAttribute("data-docid")
    let contentSearch = {}
    //let canvasIndex = 0
    const params = new URLSearchParams(window.location.search)
    //if(params.has("pageNum")) canvasIndex = parseInt(params.get("pageNum")-1)
    if(params.has("q")) contentSearch = {  query: params.get("q") }
    const manifestBase = document.querySelector('meta[name="iiif-manifest-base"]')?.content || "https://crkn-iiif-api.azurewebsites.net/manifest";
    let normalizedBase = manifestBase.endsWith('/') ? manifestBase : manifestBase + '/';
    let manifest = documentId.replace("https://n2t.net/ark:/", normalizedBase)
    const manifestList = {}
    manifestList[manifest] = { "provider": "Canadian Research Knowledge Network" }
    console.log("Mirador", Mirador)
    let mconfig = {
        id: "my-mirador",
        manifests: manifestList,
        windows: [
        {
            manifestId: manifest,
            //view: 'single',
            //canvasIndex,
            contentSearch
        }],
        view: "catalogueView",
        selectedTheme: 'light', // light | dark
        language,
        window: {
            imageToolsOpen: false,
            //global window defaults
            allowClose: false, // Configure if windows can be closed or not
            allowFullscreen: true, // Configure to show a "fullscreen" button in the WindowTopBar
            allowMaximize: false, // Configure if windows can be maximized or not
            allowTopMenuButton: true, // Configure if window view and thumbnail display menu are visible or not
            allowWindowSideBar: false, // Configure if side bar menu is visible or not
            authNewWindowCenter: "parent", // Configure how to center a new window created by the authentication flow. Options: parent, screen
            sideBarPanel: "info", // Configure which sidebar is selected by default. Options: info, attribution, canvas, annotations, search
            defaultSidebarPanelHeight: 201, // Configure default sidebar height in pixels
            defaultSidebarPanelWidth: 235, // Configure default sidebar width in pixels
            defaultView: "single", // Configure which viewing mode (e.g. single, book, gallery) for windows to be opened in
            forceDrawAnnotations: true,
            hideWindowTitle: true, // Configure if the window title is shown in the window title bar or not
            highlightAllAnnotations: false, // Configure whether to display annotations on the canvas by default
            showLocalePicker: false, // Configure locale picker for multi-lingual metadata
            sideBarOpen:  false, // Configure if the sidebar (and its content panel) is open by default
            switchCanvasOnSearch: true, // Configure if Mirador should automatically switch to the canvas of the first search result
            panels: {
              // Configure which panels are visible in WindowSideBarButtons
              info: true,
              attribution: false,
              canvas: true, // table of contents
              annotations: false,
              search: false,
              layers: false
            },
            views: [
              { key: "single", behaviors: ["individuals"] },
              { key: "book", behaviors: ["paged"] },
              { key: "scroll", behaviors: ["continuous"] }
            ],
            elastic: {
              height: 400,
              width: 480
            }
          },
          osdConfig: {
            prefixUrl: "/assets/",
            // Default config used for OpenSeadragon
            showNavigationControl: 1,
            /**
             * fullpage_rest.png:1   GET http://localhost:3000/images/fullpage_rest.png 404 (Not Found)
                fullpage_pressed.png:1   GET http://localhost:3000/images/fullpage_pressed.png 404 (Not Found)
                fullpage_grouphover.png:1   GET http://localhost:3000/images/fullpage_grouphover.png 404 (Not Found)
            zoomin
            zoomout
            home
                */
          },
          workspace: {
            draggingEnabled: false,
            allowNewWindows: true,
            isWorkspaceAddVisible: false, // Catalog/Workspace add window feature visible by default
            exposeModeOn: false, // unused?
            height: 5000, // height of the elastic mode's virtual canvas
            showZoomControls: false, // Configure if zoom controls should be displayed by default
            type: "mosaic", // Which workspace type to load by default. Other possible values are "elastic". If "mosaic" or "elastic" are not selected no worksapce type will be used.
            viewportPosition: {
              // center coordinates for the elastic mode workspace
              x: 0,
              y: 0
            },
            width: 5000 // width of the elastic mode's virtual canvas
          },
          workspaceControlPanel: {
            enabled: false // Configure if the control panel should be rendered.  Useful if you want to lock the viewer down to only the configured manifests
          },
    }
    let miradorViewer = Mirador.viewer(mconfig);
    console.log("miradorViewer", miradorViewer)
    miradorViewer.store.subscribe((e) => {
      console.log("m?", e)
    })
}
import "bootstrap-icons/font/bootstrap-icons.css";
import BlacklightRangeLimit from 'blacklight-range-limit';
//Blacklight.onLoad(() => {});
BlacklightRangeLimit.init({ onLoadHandler: Blacklight.onLoad });
console.log("here???")
// Enhance search bars (navbar + home hero) consistently
function enhanceSearchBar(rootSelector) {
  const root = document.querySelector(rootSelector);
  if (!root) return;
  const form = root.querySelector('form.search-query-form');
  const input = root.querySelector('input#q');
  const submit = root.querySelector('#search');
  if (!form || !input || !submit) return;
  // Prevent duplicate clear button
  if (submit.previousElementSibling && submit.previousElementSibling.classList?.contains('btn-clear-search')) return;
  const clearBtn = document.createElement('button');
  clearBtn.type = 'button';
  clearBtn.className = 'btn btn-outline-secondary btn-clear-search';
  const lang = document.documentElement.lang || 'en';
  const clearLabel = lang.startsWith('fr') ? 'Effacer la recherche' : 'Clear search';
  const clearText = lang.startsWith('fr') ? 'Effacer' : 'Clear';
  clearBtn.innerHTML = `<i class="bi bi-x-lg" aria-hidden="true"></i><span class="visually-hidden">${clearText}</span>`;
  clearBtn.setAttribute('aria-label', clearLabel);
  clearBtn.hidden = !input.value;
  clearBtn.addEventListener('click', () => {
    input.value = '';
    input.focus();
    clearBtn.hidden = true;
  });
  input.addEventListener('input', () => {
    clearBtn.hidden = input.value.length === 0;
  });
  submit.parentElement.insertBefore(clearBtn, submit);
  // Keyboard shortcuts
  window.addEventListener('keydown', (e) => {
    const isTypingInInput = document.activeElement && (document.activeElement.tagName === 'INPUT' || document.activeElement.tagName === 'TEXTAREA');
    if (!isTypingInInput && (e.key === '/' || (e.key.toLowerCase() === 'k' && (e.ctrlKey || e.metaKey)))) {
      e.preventDefault();
      input.focus();
      input.select();
    }
  });
  input.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && input.value) {
      input.value = '';
      clearBtn.hidden = true;
      e.stopPropagation();
    }
  });
  // Accessibility hint
  const helpId = `${rootSelector.replace(/[^a-z]/gi,'')}-search-help`;
  let help = document.getElementById(helpId);
  if (!help) {
    help = document.createElement('div');
    help.id = helpId;
    help.className = 'visually-hidden';
    const lng = document.documentElement.lang || 'en';
    help.textContent = lng.startsWith('fr')
      ? 'Utilisez la barre oblique (/) ou Ctrl+K pour activer la recherche. Appuyez sur Échap pour effacer.'
      : 'Use slash (/) or Ctrl+K to focus search. Press Escape to clear.';
    form.appendChild(help);
  }
  input.setAttribute('aria-describedby', [input.getAttribute('aria-describedby'), helpId].filter(Boolean).join(' '));
}
document.addEventListener('DOMContentLoaded', () => {
  enhanceSearchBar('.navbar-search');
  enhanceSearchBar('.home-search');
});
// Page search chips: toggle show more/less
document.addEventListener('click', (e) => {
  const btn = e.target.closest('.page-search-toggle');
  if (!btn) return;
  const container = btn.closest('.page-search-res-wrap');
  if (!container) return;
  const more = container.querySelector('.page-search-more');
  if (!more) return;
  const span = btn.querySelector('span');
  const icon = btn.querySelector('i');
  const lang = document.documentElement.lang || 'en';
  const labelMore = lang.startsWith('fr') ? 'Afficher plus' : 'Show more';
  const labelLess = lang.startsWith('fr') ? 'Afficher moins' : 'Show less';
  const hidden = more.hasAttribute('hidden');
  if (hidden) {
    more.removeAttribute('hidden');
    if (span) span.textContent = labelLess;
    if (icon) icon.classList.remove('bi-chevron-down'), icon.classList.add('bi-chevron-up');
  } else {
    more.setAttribute('hidden', '');
    if (span) span.textContent = labelMore;
    if (icon) icon.classList.remove('bi-chevron-up'), icon.classList.add('bi-chevron-down');
  }
});
// Members section interactions: tabs, province chips, name filter
document.addEventListener('DOMContentLoaded', () => {
  const section = document.querySelector('.members-section');
  if (!section) return;
  const tabs = section.querySelectorAll('[data-members-tab]');
  const grids = section.querySelectorAll('.members-grid');
  const filterChips = section.querySelectorAll('.chip-filter');
  const input = section.querySelector('#members-filter-input');
  const clearBtn = section.querySelector('.btn-clear-members');
  let activeGroup = 'institutional';
  let activeProvince = 'all';
  let text = '';
  function applyFilters() {
    grids.forEach(grid => {
      grid.classList.toggle('d-none', grid.dataset.membersGroup !== activeGroup);
      if (grid.dataset.membersGroup === activeGroup) {
        grid.querySelectorAll('.member-card').forEach(card => {
          const prov = card.dataset.province || '';
          const name = card.querySelector('.member-name')?.textContent?.toLowerCase() || '';
          const provOk = activeProvince === 'all' || prov === activeProvince;
          const textOk = text === '' || name.includes(text);
          card.style.display = (provOk && textOk) ? '' : 'none';
        });
      }
    });
  }
  tabs.forEach(btn => btn.addEventListener('click', () => {
    tabs.forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    activeGroup = btn.dataset.membersTab;
    applyFilters();
  }));
  filterChips.forEach(chip => chip.addEventListener('click', () => {
    filterChips.forEach(c => c.classList.remove('active'));
    chip.classList.add('active');
    activeProvince = chip.dataset.province;
    applyFilters();
  }));
  if (input) {
    // initialize clear visibility
    if (clearBtn) clearBtn.hidden = input.value.length === 0;
    input.addEventListener('input', () => {
      text = input.value.trim().toLowerCase();
      if (clearBtn) clearBtn.hidden = input.value.length === 0;
      applyFilters();
    });
  }
  if (clearBtn && input) {
    clearBtn.addEventListener('click', () => {
      input.value = '';
      text = '';
      clearBtn.hidden = true;
      input.focus();
      applyFilters();
    });
  }
  applyFilters();
});
function initializeDocumentLeafletMap() {
  console.log('[LeafletMap] initializeDocumentLeafletMap called');
  console.log('[LeafletMap] script version', '2025-09-30-debug');
  const container = document.getElementById('document-leaflet-map');
  if (container) {
    console.log('[LeafletMap] container dataset', JSON.stringify(container.dataset || {}));
  }
  if (!container) {
    console.log('[LeafletMap] no map container found on page');
    return;
  }
  if (container.dataset.mapInitialized === '1') {
    console.log('[LeafletMap] map already initialized, skipping');
    return;
  }
  if (typeof L === 'undefined') {
    console.warn('Leaflet is required to render the document map.');
    return;
  }
  container.dataset.mapInitialized = '1';
  const geojsonUrl = container.dataset.geojsonUrl;
  if (!geojsonUrl) {
    console.log('[LeafletMap] geojson URL missing on container');
    return;
  }
  console.log('[LeafletMap] using geojson endpoint', geojsonUrl);
  let map;
  try {
    map = L.map(container, {
    scrollWheelZoom: false,
    worldCopyJump: true
  });
  } catch (error) {
    console.error('[LeafletMap] failed to initialize Leaflet map', error);
    return;
  }
  let documentLayer = null;
  const bringDocumentLayerToFront = () => {
    if (!documentLayer) return;
    if (typeof documentLayer.bringToFront === 'function') documentLayer.bringToFront();
    if (documentLayer.eachLayer) {
      documentLayer.eachLayer((featureLayer) => {
        if (featureLayer && typeof featureLayer.bringToFront === 'function') {
          featureLayer.bringToFront();
        }
      });
    }
  };
  let territoryLayer = null;
  console.log('[LeafletMap] base tile layer');
  const base = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18,
    attribution: '(c) OpenStreetMap contributors'
  });
  base.addTo(map);
  const overlayControl = L.control.layers(null, {}, { collapsed: false }).addTo(map);
  overlayControl.expand();
  console.log('[LeafletMap] overlay control created');
  const documentPane = map.createPane('document-geometries');
  console.log('[LeafletMap] document pane ready');
  documentPane.style.zIndex = 680;
  documentPane.style.pointerEvents = 'auto';
  documentPane.style.mixBlendMode = 'normal';
  const nativePolygonPane = map.createPane('native-land-polygons');
  console.log('[LeafletMap] polygon pane ready');
  nativePolygonPane.style.zIndex = 420;
  nativePolygonPane.style.mixBlendMode = 'multiply';
  const nativeLabelPane = map.createPane('native-land-labels');
  console.log('[LeafletMap] label pane ready');
  nativeLabelPane.style.zIndex = 450;
  nativeLabelPane.style.pointerEvents = 'none';
  nativeLabelPane.style.display = 'none';
  const territoryLabelLayers = [];
  const refreshNativeLabels = () => {
    nativeLabelPane.style.display = 'none';
    nativeLabelPane.style.opacity = '0';
  };
  map.on('zoomend', refreshNativeLabels);
  map.on('moveend', refreshNativeLabels);
  const geometryContainsLatLng = (latlng, meta) => {
    if (!meta || !meta.projectedPolygons || meta.projectedPolygons.length === 0) return false;
    if (meta.bounds && typeof meta.bounds.contains === 'function' && !meta.bounds.contains(latlng)) return false;
    const projectedPoint = projectToMercator([latlng.lng, latlng.lat]);
    return projectedGeometryContainsPoint(projectedPoint, meta.projectedPolygons);
  };
  const showTerritoryPopup = (latlng) => {
    if (!territoryLayer || !map.hasLayer(territoryLayer)) return;
    const matches = [];
    territoryLabelLayers.forEach((layer) => {
      if (!map.hasLayer(layer)) return;
      const meta = layer._nativeMeta;
      if (!meta) return;
      if (geometryContainsLatLng(latlng, meta)) matches.push(layer);
    });
    if (matches.length === 0) return;
    matches.sort((a, b) => (a._nativeMeta?.area || 0) - (b._nativeMeta?.area || 0));
    const html = matches.map((layer) => {
      const meta = layer._nativeMeta || {};
      const lines = [`<strong>${meta.primary || 'Territory'}</strong>`];
      if (meta.secondary) {
        lines.push(`<div class="native-land-popup-secondary">${meta.secondary}</div>`);
      }
      return `<div class="native-land-popup-territory">${lines.join('')}</div>`;
    }).join('');
    L.popup({ autoPan: true, className: 'native-land-popup' })
      .setLatLng(latlng)
      .setContent(`<div class="native-land-popup-list">${html}</div>`)
      .openOn(map);
  };
  map.on('overlayadd', refreshNativeLabels);
  map.on('overlayremove', refreshNativeLabels);
  const territoryColorPalette = [
    '#f97316', '#ec4899', '#6366f1', '#22d3ee', '#14b8a6', '#a855f7',
    '#ef4444', '#f59e0b', '#10b981', '#3b82f6', '#8b5cf6', '#fb7185'
  ];
  const hashString = (value) => {
    const str = value || '';
    let hash = 0;
    for (let i = 0; i < str.length; i += 1) {
      hash = (hash << 5) - hash + str.charCodeAt(i);
      hash |= 0;
    }
    return Math.abs(hash);
  };
  const colorForTerritory = (name) => territoryColorPalette[hashString(name) % territoryColorPalette.length];
  const projectToMercator = ([lon, lat]) => {
    const rad = Math.PI / 180;
    const x = (lon * 20037508.34) / 180;
    const safeLat = Math.min(Math.max(lat, -89.9999), 89.9999);
    const y = Math.log(Math.tan((90 + safeLat) * rad / 2)) * 6378137;
    return [x, y];
  };
  const ringArea = (ring) => {
    let sum = 0;
    for (let i = 0; i < ring.length; i += 1) {
      const current = projectToMercator(ring[i]);
      const next = projectToMercator(ring[(i + 1) % ring.length]);
      sum += current[0] * next[1] - next[0] * current[1];
    }
    return Math.abs(sum / 2);
  };
  const polygonArea = (coords) => coords.reduce((total, ring) => total + ringArea(ring), 0);
  const geometryArea = (geometry) => {
    if (!geometry) return 0;
    if (geometry.type === 'Polygon') return polygonArea(geometry.coordinates);
    if (geometry.type === 'MultiPolygon') return geometry.coordinates.reduce((total, coords) => total + polygonArea(coords), 0);
    return 0;
  };
  const projectPolygon = (coords) => coords.map((ring) => ring.map(projectToMercator));
  const projectGeometry = (geometry) => {
    if (!geometry) return [];
    if (geometry.type === 'Polygon') return [projectPolygon(geometry.coordinates)];
    if (geometry.type === 'MultiPolygon') return geometry.coordinates.map((coords) => projectPolygon(coords));
    return [];
  };
  const geometryBounds = (geometry) => {
    if (!geometry) return null;
    let minLon = Infinity;
    let minLat = Infinity;
    let maxLon = -Infinity;
    let maxLat = -Infinity;
    const updateBounds = (coord) => {
      if (!Array.isArray(coord) || coord.length < 2) return;
      const [lon, lat] = coord;
      if (Number.isNaN(lon) || Number.isNaN(lat)) return;
      if (lon < minLon) minLon = lon;
      if (lat < minLat) minLat = lat;
      if (lon > maxLon) maxLon = lon;
      if (lat > maxLat) maxLat = lat;
    };
    const processCoords = (coords) => {
      coords.forEach((item) => {
        if (Array.isArray(item[0])) {
          processCoords(item);
        } else {
          updateBounds(item);
        }
      });
    };
    if (geometry.type === 'Point') {
      updateBounds(geometry.coordinates);
    } else if (geometry.type === 'MultiPoint' || geometry.type === 'LineString') {
      processCoords([geometry.coordinates]);
    } else if (geometry.type === 'MultiLineString' || geometry.type === 'Polygon') {
      processCoords(geometry.coordinates);
    } else if (geometry.type === 'MultiPolygon') {
      geometry.coordinates.forEach((polygon) => processCoords(polygon));
    } else if (geometry.type === 'GeometryCollection' && Array.isArray(geometry.geometries)) {
      geometry.geometries.forEach((child) => {
        const childBounds = geometryBounds(child);
        if (!childBounds) return;
        if (childBounds.minLon < minLon) minLon = childBounds.minLon;
        if (childBounds.minLat < minLat) minLat = childBounds.minLat;
        if (childBounds.maxLon > maxLon) maxLon = childBounds.maxLon;
        if (childBounds.maxLat > maxLat) maxLat = childBounds.maxLat;
      });
      return Number.isFinite(minLon) ? { minLon, minLat, maxLon, maxLat } : null;
    } else {
      return null;
    }
    return Number.isFinite(minLon) ? { minLon, minLat, maxLon, maxLat } : null;
  };
  const bboxIntersects = (a, b) => {
    if (!a || !b) return false;
    return !(a.maxLon < b.minLon || a.minLon > b.maxLon || a.maxLat < b.minLat || a.minLat > b.maxLat);
  };
  const ringContainsPoint = (point, ring) => {
    if (!ring || ring.length === 0) return false;
    let inside = false;
    for (let i = 0, j = ring.length - 1; i < ring.length; j = i, i += 1) {
      const xi = ring[i][0];
      const yi = ring[i][1];
      const xj = ring[j][0];
      const yj = ring[j][1];
      const denominator = yj - yi;
      const intersects = ((yi > point[1]) !== (yj > point[1]))
        && (point[0] < ((xj - xi) * (point[1] - yi)) / (denominator === 0 ? 1e-12 : denominator) + xi);
      if (intersects) inside = !inside;
    }
    return inside;
  };
  const polygonContainsPoint = (point, polygon) => {
    if (!polygon || polygon.length === 0) return false;
    if (!ringContainsPoint(point, polygon[0])) return false;
    for (let i = 1; i < polygon.length; i += 1) {
      if (ringContainsPoint(point, polygon[i])) return false;
    }
    return true;
  };
  const projectedGeometryContainsPoint = (point, polygons) => polygons.some((polygon) => polygonContainsPoint(point, polygon));
  const primaryNameFromProps = (props = {}) => {
    const candidates = ['Name', 'name', 'English', 'english', 'Nation', 'Tribe', 'Tribal Affiliation'];
    for (const field of candidates) {
      const value = props[field];
      if (typeof value === 'string' && value.trim().length > 0) return value.trim();
      if (Array.isArray(value) && value.length > 0) return value[0];
    }
    return 'Territory';
  };
  const secondaryNameFromProps = (props = {}) => {
    const candidates = ['Other_names', 'other_names', 'Alternate Name', 'French', 'Language'];
    for (const field of candidates) {
      const value = props[field];
      if (typeof value === 'string' && value.trim().length > 0) return value.trim();
      if (Array.isArray(value) && value.length > 0) return value[0];
    }
    return '';
  };
  let combinedBounds = null;
  const extendBounds = (layer) => {
    if (!layer || typeof layer.getBounds !== 'function') return;
    const layerBounds = layer.getBounds();
    if (!layerBounds || typeof layerBounds.isValid !== 'function' || !layerBounds.isValid()) return;
    combinedBounds = combinedBounds ? combinedBounds.extend(layerBounds) : layerBounds;
  };
  const fetchDocumentLayer = () => {
    console.log('[LeafletMap] requesting document geometry', geojsonUrl);
    return fetch(geojsonUrl, { headers: { Accept: 'application/json' } })
      .then((response) => (response.ok ? response.json() : null))
      .then((data) => {
        if (!data || !Array.isArray(data.features) || data.features.length === 0) {
          console.log('[LeafletMap] document geometry request returned no features', data);
          return null;
        }
        const featureCount = data.features.length;
        console.log('[LeafletMap] document features received', featureCount, data);
        const fallbackPlacename = Array.isArray(data.properties?.placenames)
          ? data.properties.placenames.find((name) => typeof name === 'string' && name.trim().length > 0)
          : null;
        documentLayer = L.geoJSON(data, {
          pane: 'document-geometries',
          pointToLayer: (feature, latlng) => L.circleMarker(latlng, {
            pane: 'document-geometries',
            radius: 6,
            weight: 1,
            color: '#1d4ed8',
            fillColor: '#60a5fa',
            fillOpacity: 0.85,
            zIndexOffset: 1000
          }),
          style: () => ({
            color: '#1d4ed8',
            weight: 1,
            fillColor: '#93c5fd',
            fillOpacity: 0.2
          }),
          onEachFeature: (feature, layer) => {
            const props = feature && feature.properties ? feature.properties : {};
            const placename = typeof props.placename === 'string' && props.placename.trim().length > 0
              ? props.placename.trim()
              : fallbackPlacename;
            if (placename) {
              layer.bindPopup('<strong>' + placename + '</strong>');
            }
            layer.on('click', (event) => {
              if (event && L.DomEvent?.stop) L.DomEvent.stop(event);
              event?.originalEvent?.preventDefault?.();
              event?.originalEvent?.stopPropagation?.();
              if (layer.getPopup()) layer.openPopup(event.latlng);
              bringDocumentLayerToFront();
            });
          }
        });
        if (!documentLayer.getLayers || documentLayer.getLayers().length === 0) {
          console.log('[LeafletMap] document layer contained no renderable geometries');
          return null;
        }
        documentLayer.addTo(map);
        bringDocumentLayerToFront();
        console.log('[LeafletMap] document layer added to map');
        overlayControl.addOverlay(documentLayer, 'Collection Locations');
        documentLayer.on('add', bringDocumentLayerToFront);
        if (Array.isArray(data.bbox) && data.bbox.length === 4) {
          console.log('[LeafletMap] applying bbox from document data', data.bbox);
          const bboxBounds = L.latLngBounds(
            [data.bbox[1], data.bbox[0]],
            [data.bbox[3], data.bbox[2]]
          );
          if (bboxBounds.isValid()) {
            combinedBounds = combinedBounds ? combinedBounds.extend(bboxBounds) : bboxBounds;
          }
        } else {
          console.log('[LeafletMap] computing bounds from document layer geometry');
          extendBounds(documentLayer);
        }
        return documentLayer;
      })
      .catch((error) => {
        console.error('[LeafletMap] fetchNativeTerritories error', error);
        console.warn('Unable to load document geometry for the map.', error);
        return null;
      });
  };
  const fetchNativeTerritories = () => {
    const apiKeySource = container.dataset.nativeLandKey || document.querySelector('meta[name="native-land-api-key"]')?.content;
    let apiKey = (apiKeySource || '').trim();
    if (apiKey) {
      apiKey = apiKey.replace(/^["']+|["']+$/g, '');
    }

    const baseUrl = container.dataset.nativeLandUrl || 'https://native-land.ca/api/index.php';
    const defaultNativeBbox = '-172,7,-52,83';
    const parseBbox = (bboxString) => {
      if (!bboxString) return null;
      const parts = bboxString.split(',').map((value) => parseFloat(value.trim()));
      if (parts.length !== 4 || parts.some((value) => Number.isNaN(value))) return null;
      const [minLon, minLat, maxLon, maxLat] = parts;
      return { minLon, minLat, maxLon, maxLat };
    };
    const defaultNativeBounds = parseBbox(defaultNativeBbox);
    let nativeUrl;

    try {
      nativeUrl = new URL(baseUrl);
    } catch (error) {
      try {
        nativeUrl = new URL(baseUrl, window.location.origin);
      } catch (fallbackError) {
        console.warn('[LeafletMap] invalid Native Land base URL', baseUrl, fallbackError);
        return Promise.resolve(null);
      }
    }

    const usingLocalProxy = nativeUrl.origin === window.location.origin;
    if (!nativeUrl.searchParams.has('maps')) {
      nativeUrl.searchParams.set('maps', 'territories');
    }
    if (!nativeUrl.searchParams.has('poly')) {
      nativeUrl.searchParams.set('poly', '1');
    }
    if (!nativeUrl.searchParams.has('bbox')) {
      nativeUrl.searchParams.set('bbox', defaultNativeBbox);
    }

    if (usingLocalProxy) {
      if (apiKey) {
        nativeUrl.searchParams.set('key', apiKey);
      }
    } else {
      if (!apiKey) {
        console.warn('[LeafletMap] Native Land API key missing; skipping territories layer');
        return Promise.resolve(null);
      }
      nativeUrl.searchParams.set('key', apiKey);
    }

    const requestUrl = nativeUrl.toString();
    const maskedUrl = apiKey ? requestUrl.replace(apiKey, '***') : requestUrl;
    console.log('[LeafletMap] parsed base url', maskedUrl, usingLocalProxy ? '(same origin)' : '(remote)');
    console.log('[LeafletMap] requesting Native Land territories', maskedUrl);
    const filterBounds = parseBbox(nativeUrl.searchParams.get('bbox')) || defaultNativeBounds;

    return fetch(requestUrl)
      .then((response) => {
        if (!response.ok) {
          console.warn('[LeafletMap] Native Land response not ok', response.status, response.statusText);
          return null;
        }
        return response.json();
      })
      .then((data) => {
        if (!data) {
          console.log('[LeafletMap] Native Land API returned no data');
          return null;
        }

        const featureCollection = Array.isArray(data)
          ? { type: 'FeatureCollection', features: data.filter((feature) => feature && feature.geometry) }
          : data;

        if (!featureCollection || !Array.isArray(featureCollection.features)) {
          console.warn('[LeafletMap] featureCollection invalid', featureCollection);
          console.log('[LeafletMap] Native Land feature collection malformed', data);
          return null;
        }

        if (featureCollection.features.length === 0) {
          console.log('[LeafletMap] Native Land feature collection empty');
          return null;
        }

        console.log('[LeafletMap] Native Land features available', featureCollection.features.length, featureCollection.features.slice(0, 3));
        const filteredFeatures = featureCollection.features.filter((feature) => {
          const bounds = geometryBounds(feature.geometry);
          return bounds ? bboxIntersects(bounds, filterBounds) : false;
        });
        if (filteredFeatures.length === 0) {
          console.log('[LeafletMap] Native Land features filtered out by bbox', filterBounds);
          return null;
        }
        console.log('[LeafletMap] Native Land features after bbox filter', filteredFeatures.length, filteredFeatures.slice(0, 3));
        const computeLabelMinZoom = (rankRatio) => {
          if (rankRatio >= 0.9) return 3;
          if (rankRatio >= 0.75) return 4;
          if (rankRatio >= 0.55) return 5;
          if (rankRatio >= 0.35) return 6;
          if (rankRatio >= 0.2) return 7;
          return 8;
        };
        const featuresWithArea = filteredFeatures.map((feature) => ({
          feature,
          area: geometryArea(feature.geometry)
        }));
        featuresWithArea.sort((a, b) => a.area - b.area);
        const totalFeatures = featuresWithArea.length || 1;
        const metadataByFeature = new Map();
        featuresWithArea.forEach((entry, index) => {
          const rankRatio = (totalFeatures - index) / totalFeatures;
          metadataByFeature.set(entry.feature, {
            area: entry.area,
            priority: rankRatio,
            labelMinZoom: computeLabelMinZoom(rankRatio),
            projectedPolygons: projectGeometry(entry.feature.geometry)
          });
        });
        console.log('[LeafletMap] sorted feature sample', featuresWithArea.slice(0, 2).map((entry) => entry.feature));
        console.log('[LeafletMap] creating territory layer with features', featuresWithArea.length);
        territoryLabelLayers.length = 0;

        territoryLayer = L.geoJSON(featuresWithArea.map((entry) => entry.feature), {
          pane: 'native-land-polygons',
          smoothFactor: 0.4,
          style: (feature) => {
            const props = feature && feature.properties ? feature.properties : {};
            const primary = primaryNameFromProps(props);
            const color = colorForTerritory(primary);
            return {
              color,
              weight: 1,
              opacity: 0.9,
              fillColor: color,
              fillOpacity: 0.35,
            };
          },
          onEachFeature: (feature, layer) => {
            const props = feature && feature.properties ? feature.properties : {};
            const primary = primaryNameFromProps(props);
            const secondary = secondaryNameFromProps(props);
            const meta = metadataByFeature.get(feature) || {};
            const bounds = typeof layer.getBounds === 'function' ? layer.getBounds() : null;
            layer._nativeMeta = {
              primary,
              secondary,
              area: meta.area || 0,
              priority: meta.priority || 0,
              labelMinZoom: meta.labelMinZoom || labelZoomThreshold,
              projectedPolygons: meta.projectedPolygons || [],
              bounds
            };
            territoryLabelLayers.push(layer);
            layer.on('click', (event) => {
              event?.originalEvent?.preventDefault?.();
              event?.originalEvent?.stopPropagation?.();
              if (map.hasLayer(layer)) layer.bringToFront();
              showTerritoryPopup(event.latlng);
            });
          }
        });
        territoryLayer.addTo(map);
        territoryLayer.on('add', () => {
          console.log('[LeafletMap] native layer added to map');
          refreshNativeLabels();
        });
        territoryLayer.on('remove', () => {
          console.log('[LeafletMap] native layer removed from map');
          refreshNativeLabels();
        });
        return territoryLayer;
      })
      .catch((error) => {
        console.error('[LeafletMap] fetchNativeTerritories error', error);
        console.warn('Unable to load Native Land territories.', error);
        return null;
      });
  };
  map.on('focus', () => map.scrollWheelZoom.enable());
  map.on('blur', () => map.scrollWheelZoom.disable());
  Promise.all([fetchDocumentLayer(), fetchNativeTerritories()]).then(([documentLayer, nativeLayer]) => {
    if (nativeLayer) {
      overlayControl.addOverlay(nativeLayer, 'Native Land Territories');
      console.log('[LeafletMap] overlay count now', Object.keys(overlayControl._layers || {}).length);
      console.log('[LeafletMap] Native Land layer ready; use the layer control to toggle it');
      refreshNativeLabels();
    }
    bringDocumentLayerToFront();
    if (combinedBounds && typeof combinedBounds.isValid === 'function' && combinedBounds.isValid()) {
      console.log('[LeafletMap] fitting map to combined bounds');
      map.fitBounds(combinedBounds, { padding: [24, 24], maxZoom: 8 });
    } else {
      console.log('[LeafletMap] using default fallback view');
      map.setView([56.1304, -106.3468], 3);
    }
    setTimeout(() => {
      map.invalidateSize();
      console.log('[LeafletMap] map invalidateSize triggered');
    }, 200);
    console.log('[LeafletMap] map initialization complete');
  });
}
if (typeof document !== 'undefined') {
  const lifecycleEvents = ['DOMContentLoaded', 'turbo:load', 'turbo:frame-load', 'blacklight:load'];
  console.log('[LeafletMap] bootstrap', 'readyState:', document.readyState, 'events:', lifecycleEvents);
  lifecycleEvents.forEach((eventName) => {
    document.addEventListener(eventName, initializeDocumentLeafletMap);
  });
  if (document.readyState !== 'loading') {
    console.log('[LeafletMap] document already loaded; running initializeDocumentLeafletMap immediately');
    initializeDocumentLeafletMap();
  }
}
