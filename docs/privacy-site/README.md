# CARE public privacy page

`index.html` is a standalone static page with no JavaScript, analytics, or external assets. Vercel can serve this directory as a project root with the framework preset **Other** and no build command. Use a stable production `*.vercel.app` URL for App Store Connect's Privacy Policy URL; a temporary preview deployment URL is not suitable for the public policy.

Amy Banks, MD has approved the policy text and operator/contact line for publication. The page reflects the iOS implementation as checked on October 1, 2026, including local SwiftData storage, optional photo selection, embedded YouTube playback, Messages sharing, and in-app data deletion. If the app's data flows change, revise the policy and App Store privacy answers together.

When the Vercel account is available, create a standalone project rooted at `docs/privacy-site`, publish it to production, open its public URL without signing in, and then enter that URL in App Store Connect → RCT CARE → App Privacy → Privacy Policy URL. The same HTML can later be copied into Amy's website without changing the privacy content.
