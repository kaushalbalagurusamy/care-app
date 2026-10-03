# CARE App Store privacy disclosure worksheet

Status: source audit completed October 2, 2026; public policy published and accessible without sign-in at <https://care-app-privacy.vercel.app/>; the English (US) App Store privacy-policy URL and optional privacy-choices URL (`/#choices`) are set. **App Privacy data-practice answers are not yet entered or published in App Store Connect.** Complete these against the exact release binary and the current App Privacy form before submission.

## Source-backed inventory

| Flow | What leaves the device | App Store treatment |
| --- | --- | --- |
| Profile, relationships, assessments, quiz and exercise drafts, completion history | None to a CARE server. `AppEnvironment.live` creates the SwiftData container with CloudKit disabled; other draft/activity records use local storage. | Apple's definition excludes data processed only on device. Do not select Contact Info, Health, Photos, User Content, or similar solely because CARE stores them locally. |
| Optional photo/video selection | PhotosPicker provides selected items locally; profile/contact copies and unfinished exercise references remain on device. | No CARE collection from this flow. |
| Optional Messages compose | User initiates the system composer and decides whether to send. | No CARE server collection. Review Apple’s handling separately; do not claim that CARE sends messages. |
| Embedded YouTube playback | The app loads Google's iframe player inside WKWebView after a user opens a clip. Google says its embedded player shares basic user data when loaded and additional playback data when played. Google describes receipt of IP address, page URL, cookies/identifiers, and content interactions from embedded services. | **Answer “Yes, we collect data from this app”** unless the release changes this flow. Account for the third-party player in the categories below. |
| CARE privacy-policy web page | Opening the external page sends a request to Vercel. It does not send CARE app records. | Hosting access logs belong to the website's privacy notice; verify the exact in-app opening behavior when the link is added. |

## App Privacy form work

1. The public CARE privacy-policy URL is set to <https://care-app-privacy.vercel.app/>. Do not use Amy's generic WordPress website policy.
2. Answer **Yes** to collection because of the embedded YouTube player. Do not label the app “Data Not Collected” while that player is present.
3. Map Google's embedded-player data to Apple's current categories in App Store Connect. Evidence supports at least video-view **Product Interaction** and device/network identifiers; Google says IP address can indicate general location. Verify the exact category wording and whether the player uses identifiers, coarse location, ad interaction, or diagnostic categories in this integration. Do not mark locally stored CARE records as transmitted.
4. For each selected category, verify Apple's purpose, linked-to-user, and tracking questions against Google's current embedded-player practices. Google says embedded services may use information for ads and personalization; Apple's tracking definition and ATT rule apply to tracking inside a functional WebView. The current CARE app has no ATT consent flow. Therefore **do not publish a “no tracking” assertion or a final disclosure until this is resolved**. A privacy-enhanced YouTube embed is currently documented by YouTube for websites, not iOS apps.
5. Recheck the published product-page preview against the policy and current binary, then publish the responses.

## Provisional data-type decisions for the current embedded player

These are working answers, not a published App Privacy label. Apple says data sent through a functional web view must be declared. Google says the embedded player shares basic user data on load and more on playback; its partner-site notice describes IP address, page URL, cookies, and ad personalization. The app does not send locally stored CARE records to Google.

| App Store item | Working answer | Basis / open question |
| --- | --- | --- |
| Does this app or its third-party partners collect data? | **Yes** | The embedded YouTube player sends data to Google. |
| Usage Data → Product Interaction | **Select** | Google receives video-playback activity; Apple explicitly includes video views in this type. |
| Location → Coarse Location | **Likely select** | Google says it uses IP addresses to infer general location. Confirm how the current form treats IP-derived location. |
| Identifiers → Device ID | **Review before selection** | Google may set/read cookies, but its public text does not establish exactly which persistent identifiers this iOS WebView sends. Do not guess that IDFA is present. |
| Usage Data → Advertising Data | **Review before selection** | Ads may appear in YouTube videos. Confirm whether this player collects ad-view data for these clips. |
| Diagnostics | **Review before selection** | Google describes fraud and abuse data; that does not by itself establish an Apple diagnostic subtype. |
| Contact Info, Contacts, Health, User Content, Photos/Videos | **Do not select solely for CARE's local records** | This app keeps those records on device and does not send them to a CARE server or to the embedded player. |
| Linked to the user / Used for tracking | **Unresolved; do not publish yet** | Google describes cookies, personalization, and ad measurement. Apple's tracking definition asks whether app data is joined with third-party data for advertising. The present app has no App Tracking Transparency flow or verified nontracking player configuration. |

Apple says tracking inside a WebView used for app functionality requires ATT permission and also says apps cannot condition functionality on agreeing to tracking. A simple ATT prompt alone therefore does not resolve what happens when a user declines. Keep the embedded player while investigating a documented nontracking configuration or an equivalent no-tracking viewing path before making a final tracking declaration.

## Embedded-player terms check

The current code uses YouTube's iframe API. YouTube's developer policies require an API client to display a link to YouTube's Terms of Service, state that using the client binds users to those terms, and obtain agreement to an accessible privacy policy before the client feature is used. The local free-release branch now shows an optional pre-play sheet with the CARE policy and YouTube Terms links, plus an explicit Agree & Play action, before either embedded player loads. A user who declines can still complete the exercise. Both playback entry points passed focused simulator UI tests. This is not yet in a TestFlight build and does not settle the separate Apple tracking/ATT question or establish that the full YouTube policy is satisfied.

## Evidence

- App: `ios/CAREApp/Navigation/AppEnvironment.swift`, `ios/CAREApp/Storage/StorageContainer.swift`, `ios/CAREApp/Views/WatchFunnyExerciseView.swift`, and `ios/CAREApp/Views/AdditionalExerciseViews.swift`.
- Apple, [App privacy details](https://developer.apple.com/app-store/app-privacy-details/): on-device processing is not collection; third-party collection must be included.
- Apple, [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/): form workflow and publishing requirements.
- Apple, [User privacy and data use](https://developer.apple.com/app-store/user-privacy-and-data-use/): tracking in a functional WebView requires ATT.
- Google, [YouTube API Services Developer Policies](https://developers.google.com/youtube/terms/developer-policies): embedded-player sharing on load and playback.
- Google, [How Google uses information from partner sites/apps](https://policies.google.com/technologies/partner-sites): embedded videos, IP address, URL, cookies, ads.
- YouTube, [Embed videos and playlists](https://support.google.com/youtube/answer/171780?expand=PrivacyEnhancedMode&hl=en-GB): privacy-enhanced mode is currently available only for website embeds.
