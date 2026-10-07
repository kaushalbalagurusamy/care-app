# CARE public privacy page

`index.html` is the public privacy policy. `support.html` is the public CARE support form, and `api/support.js` validates submissions before forwarding them through the existing Forminator contact processor on Amy Banks, MD's website. The receiving email address stays configured privately in WordPress and is not exposed in this repository or the page source. Use a stable production `*.vercel.app` URL for App Store Connect URLs; a temporary preview deployment URL is not suitable.

Amy Banks, MD approved the original policy text and operator/contact line for the free release. The October 7 source revision adds the paid update's Positive Relational Moments retention, local photo copies, optional Apple purchase, and external clip disclosures. The live site must be updated and checked before the paid app is submitted. If the app's data flows change, revise the policy and App Store privacy answers together.

The standalone Vercel project is published at <https://care-app-privacy.vercel.app/>. The privacy page and support page returned HTTP 200 without signing in, and the support form completed an end-to-end delivery test on October 5, 2026. App Store Connect uses the production privacy URL and <https://care-app-privacy.vercel.app/support.html> as the English (US) Support URL.
