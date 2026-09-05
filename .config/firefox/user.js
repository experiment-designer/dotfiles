// Load the userChrome.css and userContent.css files managed by this repository.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Keep Firefox's compact density available and make it the default.
user_pref("browser.compactmode.show", true);
user_pref("browser.uidensity", 1);

// Force the built-in dark theme for both chrome and content so the Phosphor
// stylesheets never have to fight a light system/theme default.
user_pref("browser.theme.content-theme", 0);
user_pref("browser.theme.toolbar-theme", 0);
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("layout.css.prefers-color-scheme.content-override", 0);

// about:newtab is a bare canvas: no sponsors, no tiles, no stories, no weather.
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.showWeather", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);

// The tab-manager dropdown duplicates the tab strip; the CSS hides its button.
user_pref("browser.tabs.tabmanager.enabled", false);

// Preserve the existing hardware-accelerated video settings for this profile.
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);

// ---------------------------------------------------------------------------
// Cold-start / first-paint tuning. Nothing here disables a security feature
// (Safe Browsing, certificate checks and updates are all left alone); each
// pref removes work Firefox would otherwise do while the first window is
// still being built.
// ---------------------------------------------------------------------------

// Put a themed blank window on screen before the full chrome is ready, so the
// first paint is not gated on session restore finishing.
user_pref("browser.startup.blankWindow", true);

// Restore tabs lazily: only the selected tab loads at startup, the rest wait
// until they are clicked.
user_pref("browser.sessionstore.restore_on_demand", true);

// No "what's new" tab after an update and no onboarding flow on first run.
// Dev Edition updates often, and each of those pages is an extra document
// loaded during startup.
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("browser.aboutwelcome.enabled", false);

// Skip the default-browser check and the add-on recommendation/Pocket
// components that spin up during startup.
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.discovery.enabled", false);
user_pref("extensions.pocket.enabled", false);
user_pref("extensions.getAddons.cache.enabled", false);

// No experiment/study machinery at startup.
user_pref("app.normandy.enabled", false);
user_pref("app.shield.optoutstudies.enabled", false);

// No telemetry pings, archives or data-reporting init during startup.
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);

// Render a skeleton UI before chrome is fully ready for faster perceived startup.

// Save session state less frequently to reduce disk I/O overhead.

// Disable new tab discovery stream to eliminate remote content fetching.
user_pref("browser.newtabpage.activity-stream.discoverystream.enabled", false);

// Disable UI tour backend to skip onboarding tour checks.
user_pref("browser.uitour.enabled", false);

// Use in-content menupopups so userChrome.css can style context menus.
user_pref("widget.gtk.native-context-menus", false);

// Suppress the ETP panel's illustrated info hero (kept off-palette).
user_pref("browser.protections_panel.infoMessage.seen", true);

// Launch and Home button open the Phosphor start page (same one Tridactyl serves on new tabs).
user_pref("browser.startup.page", 1);
user_pref("browser.startup.homepage", "http://127.0.0.1:7777/index.html");

// No proxy autodetection / captive-portal probe at startup (they delay the first page load).
user_pref("network.proxy.type", 0);
user_pref("network.captive-portal-service.enabled", false);

// Allow our unsigned local "Phosphor New Tab" extension (phosphor-newtab.xpi); Developer Edition honours this.
user_pref("xpinstall.signatures.required", false);
