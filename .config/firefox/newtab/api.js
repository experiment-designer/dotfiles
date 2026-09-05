/* global ExtensionAPI, ChromeUtils */
var phosphorNewTab = class extends ExtensionAPI {
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
        setURL() {
          // Set the actual new-tab URL, so Firefox handles the empty address
          // bar and focus normally and Tridactyl runs on ordinary HTTP content.
          AboutNewTab.newTabURL = url;
        }
      }
    };
  }

  onShutdown(isAppShutdown) {
    if (!isAppShutdown && this.restore) this.restore();
  }
};
