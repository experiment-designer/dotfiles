/* global ExtensionAPI, ChromeUtils, Services */
var phosphorNewTab = class extends ExtensionAPI {
  installUrlbarEscape() {
    if (this.windows) return;
    this.windows = new Map();
    const attach = window => {
      if (this.windows.has(window)) return;
      const onKeyDown = event => {
        const bar = window.gURLBar;
        if (
          event.key !== "Escape" || event.defaultPrevented ||
          event.altKey || event.ctrlKey || event.metaKey || event.shiftKey ||
          !bar?.focused || !event.composedPath().includes(bar.inputField) ||
          bar.view.isOpen || bar.searchMode ||
          bar.view.resultMenu.hasAttribute("open")
        ) return;

        // Firefox normally discards edited text here via handleRevert().
        // Once suggestions/search mode are dismissed, leave the field instead.
        event.preventDefault();
        event.stopImmediatePropagation();
        window.gBrowser.selectedBrowser.focus();
      };
      const detach = () => {
        window.removeEventListener("keydown", onKeyDown, true);
        window.removeEventListener("unload", detach);
        this.windows.delete(window);
      };
      window.addEventListener("keydown", onKeyDown, true);
      window.addEventListener("unload", detach);
      this.windows.set(window, detach);
    };
    this.windowObserver = { observe: attach };
    Services.obs.addObserver(this.windowObserver, "browser-delayed-startup-finished");
    for (const window of Services.wm.getEnumerator("navigator:browser")) {
      if (window.gBrowserInit.delayedStartupFinished) attach(window);
    }
  }

  getAPI() {
    const { AboutNewTab } = ChromeUtils.importESModule(
      "resource:///modules/AboutNewTab.sys.mjs"
    );
    const url = "http://127.0.0.1:7777/index.html";
    this.restore = () => {
      if (AboutNewTab.newTabURL === url) AboutNewTab.resetNewTabURL();
    };
    return {
      phosphorNewTab: {
        setURL: () => {
          // Set the actual new-tab URL, so Firefox handles the empty address
          // bar and focus normally and Tridactyl runs on ordinary HTTP content.
          AboutNewTab.newTabURL = url;
          this.installUrlbarEscape();
        }
      }
    };
  }

  onShutdown(isAppShutdown) {
    if (isAppShutdown) return;
    if (this.windowObserver) {
      Services.obs.removeObserver(this.windowObserver, "browser-delayed-startup-finished");
      for (const detach of this.windows.values()) detach();
    }
    if (this.restore) this.restore();
  }
};
