# CARE App Store privacy disclosure worksheet

Status: source audit completed October 2, 2026; **not entered or published in App Store Connect**. Complete this against the exact release binary and the current App Privacy form before submission.

## Source-backed inventory

| Flow | What leaves the device | App Store treatment |
| --- | --- | --- |
| Profile, relationships, assessments, quiz and exercise drafts, completion history | None to a CARE server. `AppEnvironment.live` creates the SwiftData container with CloudKit disabled; other draft/activity records use local storage. | Apple's definition excludes data processed only on device. Do not select Contact Info, Health, Photos, User Content, or similar solely because CARE stores them locally. |
| Optional photo/video selection | PhotosPicker provides selected items locally; profile/contact copies and unfinished exercise references remain on device. | No CARE collection from this flow. |
| Optional Messages compose | User initiates the system composer and decides whether to send. | No CARE server collection. Review Apple’s handling separately; do not claim that CARE sends messages. |
| Embedded YouTube playback | The app loads Google's iframe player inside WKWebView after a user opens a clip. Google says its embedded player shares basic user data when loaded and additional playback data when played. Google describes receipt of IP address, page URL, cookies/identifiers, and content interactions from embedded services. | **Answer “Yes, we collect data from this app”** unless the release changes this flow. Account for the third-party player in the categories below. |
| CARE privacy-policy web page | Opening the external page sends a request to Vercel. It does not send CARE app records. | Hosting access logs belong to the website's privacy notice; verify the exact in-app opening behavior when the link is added. |

## App Privacy form work

1. Set the public CARE privacy-policy URL after the standalone Vercel project is deployed and tested in a signed-out browser. Do not use Amy's generic WordPress website policy.
2. Answer **Yes** to collection because of the embedded YouTube player. Do not label the app “Data Not Collected” while that player is present.
3. Map Google's embedded-player data to Apple's current categories in App Store Connect. Evidence supports at least video-view **Product Interaction** and device/network identifiers; Google says IP address can indicate general location. Verify the exact category wording and whether the player uses identifiers, coarse location, ad interaction, or diagnostic categories in this integration. Do not mark locally stored CARE records as transmitted.
4. For each selected category, verify Apple's purpose, linked-to-user, and tracking questions against Google's current embedded-player practices. Google says embedded services may use information for ads and personalization; Apple's tracking definition and ATT rule apply to tracking inside a functional WebView. The current CARE app has no ATT consent flow. Therefore **do not publish a “no tracking” assertion or a final disclosure until this is resolved**. A privacy-enhanced YouTube embed is currently documented by YouTube for websites, not iOS apps.
5. Recheck the published product-page preview against the policy and current binary, then publish the responses.

## Evidence

- App: `ios/CAREApp/Navigation/AppEnvironment.swift`, `ios/CAREApp/Storage/StorageContainer.swift`, `ios/CAREApp/Views/WatchFunnyExerciseView.swift`, and `ios/CAREApp/Views/AdditionalExerciseViews.swift`.
- Apple, [App privacy details](https://developer.apple.com/app-store/app-privacy-details/): on-device processing is not collection; third-party collection must be included.
- Apple, [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/): form workflow and publishing requirements.
- Apple, [User privacy and data use](https://developer.apple.com/app-store/user-privacy-and-data-use/): tracking in a functional WebView requires ATT.
- Google, [YouTube API Services Developer Policies](https://developers.google.com/youtube/terms/developer-policies): embedded-player sharing on load and playback.
- Google, [How Google uses information from partner sites/apps](https://policies.google.com/technologies/partner-sites): embedded videos, IP address, URL, cookies, ads.
- YouTube, [Embed videos and playlists](https://support.google.com/youtube/answer/171780?expand=PrivacyEnhancedMode&hl=en-GB): privacy-enhanced mode is currently available only for website embeds.
