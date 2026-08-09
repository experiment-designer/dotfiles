// Load the userChrome.css and userContent.css files managed by this repository.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Preserve the existing hardware-accelerated video settings for this profile.
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
