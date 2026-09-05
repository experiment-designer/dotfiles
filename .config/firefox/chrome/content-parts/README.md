Phosphor internal-page coverage
==============================

`00-tokens.css` owns the existing graphite palette, monospace typography,
hairlines and amber state colors. It applies to all `about:`, `chrome://` and
`resource://` documents loaded as content, including toolkit subdocuments,
and `moz-extension://` extension pages and popups.

`05-internal-defaults.css` supplies common surface rules and compatibility for
newer Firefox components. It loads before the page-specific files so their
layouts and more specific rules can keep refining the shared design. Add
reusable component fixes here rather than duplicating the palette per page.

Firefox's actual error document URI is `about:neterror?...` or
`about:certerror?...`, even when the address bar shows the failed website.
Verified in Firefox Developer Edition 154.0: userContent rules reach both
these documents and their `net-error-card` shadow trees. Older notes claiming
these pages cannot receive userContent styles are incorrect. The shared
error-family rules preserve explanations, diagnostic details and actions;
only the new card's decorative illustration is hidden.

Coverage is a fallback, not a guarantee that arbitrary future Firefox layouts
will need no maintenance. Components can introduce new hard-coded styles.
Browser windows and dialogs loaded as chrome use `userChrome.css`; operating
system dialogs and the separate crash-reporter application are outside this
stylesheet. HTTP(S) and local files are not added to the fallback's URL scope.
Existing global rules elsewhere are unchanged.

`06-extension-defaults.css` supplies semantic surfaces for all extension IDs:
navigation, sections, details, menus and dialogs. The shared base widgets in
`00-tokens.css` style extension controls. No per-install UUID is required.
Custom canvas UIs and unlabelled containers can still need specific styling.

`../chrome-parts/05-toolkit-defaults.css` is imported in both chrome and content
contexts to cover shared toolkit dialogs (alerts, confirmations, text prompts
and authentication), including their shadow dialog buttons.

Native GTK3 menus, controls and file pickers use `../../../gtk-3.0/gtk.css`
and `settings.ini`, managed by the dotfiles manifest. New GTK processes pick
them up automatically; restart existing applications to load changes. This
does not theme Qt, GTK4/libadwaita, or arbitrary website designs.

Changes are live through the profile's symlinks after a Firefox restart.
Test in a separate profile with the repo's chrome directory linked into it.
Include settings, config, blank/newtab, tab crashes, diagnostics, an actual
failed connection, an actual TLS certificate failure, and an ordinary HTTP
page. Check shadow-button colors and borders as well as the document canvas.
