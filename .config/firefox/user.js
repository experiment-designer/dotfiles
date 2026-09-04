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

// The tab-manager dropdown duplicates the tab strip; the CSS hides its button.
user_pref("browser.tabs.tabmanager.enabled", false);

// Preserve the existing hardware-accelerated video settings for this profile.
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
