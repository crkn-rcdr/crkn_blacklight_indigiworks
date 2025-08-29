// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite ⚡️ Rails')

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
    let canvasIndex = 0
    const params = new URLSearchParams(window.location.search)
    if(params.has("pageNum")) canvasIndex = parseInt(params.get("pageNum")-1)
    if(params.has("q")) contentSearch = {  query: params.get("q") }
    let manifest = documentId.replace("https://n2t.net/ark:/", "https://crkn-iiif-api.azurewebsites.net/manifest/")
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
            canvasIndex,
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

    /*miradorViewer.store.subscribe(() => {
      const titleElement = document.querySelector('dd.blacklight-title_ssm p')
      const titleText = titleElement?.textContent?.trim()
      const h2Element = document.querySelector('h2.MuiTypography-h2')
      if (titleText && h2Element) {
        h2Element.textContent = h2Element.textContent.replace(titleText, '').replace(/\s+:\s+/, '').trim()
      }
    })*/
}
import "bootstrap-icons/font/bootstrap-icons.css";
import BlacklightRangeLimit from 'blacklight-range-limit';
//Blacklight.onLoad(() => {});
BlacklightRangeLimit.init({ onLoadHandler: Blacklight.onLoad });
console.log("here???")

// Enhance top search bar UX/accessibility without changing server templates
document.addEventListener('DOMContentLoaded', () => {
  const form = document.querySelector('.navbar-search form.search-query-form');
  const input = document.querySelector('.navbar-search input#q');
  const submit = document.querySelector('.navbar-search #search');

  if (!form || !input || !submit) return;

  // Add a clear button (shows when there is text)
  const clearBtn = document.createElement('button');
  clearBtn.type = 'button';
  clearBtn.className = 'btn btn-outline-secondary btn-clear-search';
  const lang = document.documentElement.lang || 'en';
  const clearLabel = lang.startsWith('fr') ? 'Effacer la recherche' : 'Clear search';
  const clearText = lang.startsWith('fr') ? 'Effacer' : 'Clear';
  clearBtn.innerHTML = `<i class="bi bi-x-circle" aria-hidden="true"></i><span class="visually-hidden">${clearText}</span>`;
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

  // Insert clear button before submit
  submit.parentElement.insertBefore(clearBtn, submit);

  // Keyboard shortcuts
  // Focus search with '/' or Ctrl/Cmd+K
  window.addEventListener('keydown', (e) => {
    const isTypingInInput = document.activeElement && (document.activeElement.tagName === 'INPUT' || document.activeElement.tagName === 'TEXTAREA');
    if (!isTypingInInput && (e.key === '/' || (e.key.toLowerCase() === 'k' && (e.ctrlKey || e.metaKey)))) {
      e.preventDefault();
      input.focus();
      input.select();
    }
  });

  // ESC clears current query when focused
  input.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && input.value) {
      input.value = '';
      clearBtn.hidden = true;
      e.stopPropagation();
    }
  });

  // Improve labeling for assistive tech
  const helpId = 'search-help-text';
  let help = document.getElementById(helpId);
  if (!help) {
    help = document.createElement('div');
    help.id = helpId;
    help.className = 'visually-hidden';
    const lang = document.documentElement.lang || 'en';
    help.textContent = lang.startsWith('fr')
      ? 'Utilisez la barre oblique (/) ou Ctrl+K pour activer la recherche. Appuyez sur Échap pour effacer.'
      : 'Use slash (/) or Ctrl+K to focus search. Press Escape to clear.';
    form.appendChild(help);
  }
  input.setAttribute('aria-describedby', [input.getAttribute('aria-describedby'), helpId].filter(Boolean).join(' '));
});
