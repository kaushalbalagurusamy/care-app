# CARE public privacy page

`index.html` is a standalone static page with no JavaScript, analytics, or external assets. Vercel can serve this directory as a project root with the framework preset **Other** and no build command. Use a stable production `*.vercel.app` URL for App Store Connect's Privacy Policy URL; a temporary preview deployment URL is not suitable for the public policy.

Amy Banks, MD has approved the policy text and operator/contact line for publication. The page reflects the iOS implementation as checked on October 1, 2026, including local SwiftData storage, optional photo selection, embedded YouTube playback, Messages sharing, and in-app data deletion. If the app's data flows change, revise the policy and App Store privacy answers together.

The standalone Vercel project is published at <https://care-app-privacy.vercel.app/>. The page returned HTTP 200 without signing in, and the same production URL is set for the RCT CARE English (US) App Store privacy-policy field. The same HTML can later be copied into Amy's website without changing the privacy content.
