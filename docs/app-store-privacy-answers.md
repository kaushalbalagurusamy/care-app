# CARE App Store privacy disclosure worksheet

Status: source audit updated October 5, 2026; public policy published and accessible without sign-in at <https://care-app-privacy.vercel.app/>; the English (US) App Store privacy-policy URL and optional privacy-choices URL (`/#choices`) are set. The October 5 release source uses YouTube Privacy Enhanced Mode in a nonpersistent WKWebView after explicit user choice. Amy Banks published the approved App Privacy responses in App Store Connect on October 5, 2026. The published product-page preview shows Location and Usage Data as data not linked to the user.

## Source-backed inventory

| Flow | What leaves the device | App Store treatment |
| --- | --- | --- |
| Profile, relationships, assessments, quiz and exercise drafts, completion history | None to a CARE server. `AppEnvironment.live` creates the SwiftData container with CloudKit disabled; other draft/activity records use local storage. | Apple's definition excludes data processed only on device. Do not select Contact Info, Health, Photos, User Content, or similar solely because CARE stores them locally. |
| Optional photo/video selection | PhotosPicker provides selected items locally; profile/contact copies and unfinished exercise references remain on device. | No CARE collection from this flow. |
| Optional Messages compose | User initiates the system composer and decides whether to send. | No CARE server collection. Review Apple’s handling separately; do not claim that CARE sends messages. |
| Embedded YouTube playback | After the user's optional pre-play choice, the app loads Google's `youtube-nocookie.com` Privacy Enhanced Mode player inside a WKWebView with nonpersistent browser storage. Google still receives network and playback data and may serve nonpersonalized ads. Google says Privacy Enhanced Mode views do not personalize the viewer's YouTube experience or advertising outside the app. | **Answer “Yes, we collect data from this app”** and declare the third-party player categories below. The release does not use persistent WebView storage or the IDFA for this flow. |
| CARE privacy-policy web page | Opening the external page sends a request to Vercel. It does not send CARE app records. | Hosting access logs belong to the website's privacy notice; verify the exact in-app opening behavior when the link is added. |

## App Privacy form work

1. The public CARE privacy-policy URL is set to <https://care-app-privacy.vercel.app/>. Do not use Amy's generic WordPress website policy.
2. Answer **Yes** to collection because of the embedded YouTube player. Do not label the app “Data Not Collected” while that player is present.
3. Select **Coarse Location**, **Product Interaction**, and **Advertising Data** for the optional embedded player. Do not mark locally stored CARE records as transmitted.
4. Mark these data types **not linked to the user's identity** and **not used for tracking**. The player uses temporary browser storage, does not receive a CARE identity, and Privacy Enhanced Mode prevents the embedded view from personalizing YouTube activity or advertising outside CARE. Revisit this conclusion if the player domain, storage policy, sign-in behavior, or Google documentation changes.
5. Recheck the published product-page preview against the policy and current binary, then publish the responses.

## Provisional data-type decisions for the current embedded player

These are the approved final answers published in App Store Connect on October 5, 2026. Apple says data sent through a functional web view must be declared. The app does not send locally stored CARE records to Google.

| App Store item | Working answer | Basis / open question |
| --- | --- | --- |
| Does this app or its third-party partners collect data? | **Yes** | The embedded YouTube player sends data to Google. |
| Usage Data → Product Interaction | **Select** | Google receives video-playback activity; Apple explicitly includes video views in this type. Purposes: Analytics and App Functionality. |
| Location → Coarse Location | **Select** | Google receives IP addresses and may infer general location. Purposes: Third-Party Advertising and App Functionality. |
| Usage Data → Advertising Data | **Select** | Privacy Enhanced Mode may serve nonpersonalized ads and process information about displayed ads. Purposes: Third-Party Advertising and Analytics. |
| Identifiers → Device ID | **Do not select** | CARE does not send IDFA or a CARE identifier; the player runs in nonpersistent browser storage. |
| Diagnostics | **Do not select** | Available evidence does not establish an Apple diagnostic subtype collected through this integration. |
| Contact Info, Contacts, Health, User Content, Photos/Videos | **Do not select solely for CARE's local records** | This app keeps those records on device and does not send them to a CARE server or to the embedded player. |
| Linked to the user | **No** | CARE supplies no account or identity to Google, and each player uses temporary browser storage. |
| Used for tracking | **No** | Google states Privacy Enhanced Mode views do not personalize YouTube activity or ads outside the app; CARE does not use IDFA or a persistent player identity. |

Apple says tracking inside a functional WebView requires ATT permission. The proposed release avoids that tracking use by combining YouTube Privacy Enhanced Mode, nonpersistent browser storage, no CARE or Google sign-in flow, and an optional pre-play choice. No ATT prompt is proposed. Confirm the exact release binary retains these controls.

## Embedded-player terms check

The current code uses YouTube's iframe API with `youtube-nocookie.com`. YouTube's developer policies require an API client to display a link to YouTube's Terms of Service, state that using the client binds users to those terms, and obtain agreement to an accessible privacy policy before the client feature is used. The local free-release branch shows an optional pre-play sheet with the CARE policy and YouTube Terms links, plus an explicit Agree & Play action, before either embedded player loads. A user who declines can still complete the exercise. The privacy-enhanced build passed compilation and the focused simulator test that opens and closes the embedded player.

## Evidence

- App: `ios/CAREApp/Navigation/AppEnvironment.swift`, `ios/CAREApp/Storage/StorageContainer.swift`, `ios/CAREApp/Views/WatchFunnyExerciseView.swift`, and `ios/CAREApp/Views/AdditionalExerciseViews.swift`.
- Apple, [App privacy details](https://developer.apple.com/app-store/app-privacy-details/): on-device processing is not collection; third-party collection must be included.
- Apple, [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/): form workflow and publishing requirements.
- Apple, [User privacy and data use](https://developer.apple.com/app-store/user-privacy-and-data-use/): tracking in a functional WebView requires ATT.
- Google, [YouTube API Services Developer Policies](https://developers.google.com/youtube/terms/developer-policies): embedded-player sharing on load and playback.
- Google, [How Google uses information from partner sites/apps](https://policies.google.com/technologies/partner-sites): embedded videos, IP address, URL, cookies, ads.
- YouTube, [Embed videos and playlists](https://support.google.com/youtube/answer/171780?expand=PrivacyEnhancedMode&hl=en): Privacy Enhanced Mode uses `youtube-nocookie.com`, supports app WebViews, and prevents embedded views from personalizing YouTube activity or ads outside the app.
