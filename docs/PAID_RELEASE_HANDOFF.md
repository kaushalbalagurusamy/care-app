# CARE paid update: design handoff and release protocol

Updated 2026-10-07. This handoff applies to `feature/paid-care-action-plan-preview`. The free app version 1.0 (build 11) was submitted separately from `jayme/free-release` in the `CARE App` chat and was `WAITING_FOR_REVIEW` on October 5. Its submitted source is `537107bb4e14f4f885dc60b442ce6a6297373f6a`. This paid checkout has separate Git ancestry and must preserve the submitted free build while bringing forward its relevant fixes.

## The current state

- The paid branch contains the Action Plan preview and 61 added exercises across Calm, Accepted, Resonant, and Energetic. Their 120 screen steps are imported from the four CARE Figma pages. The app keeps its existing top bar.
- The first two exercises in each pathway (eight total), assessments, and the Positive Relational Moments library are free. The 61 added exercises and full personalized Action Plan require the one-time unlock. Free Action Plan buttons open the Figma unlock screen; paid buttons open the plan.
- StoreKit 2 loads product `com.careapp.care.premium.unlock`, grants access from verified current entitlements, observes transaction updates, and supports Restore Purchase from My Profile. The free Action Plan preview shows recommendations and all pathway titles without opening exercises or granting access. The primary unlock button uses StoreKit in both Debug and Release; a separate Debug-only button previews paid screens without payment. Xcode Run has a local StoreKit configuration for the same non-consumable product ID at $9.99. On October 7, the no-charge local purchase sheet displayed the correct product and price and completing it opened the full plan. A real App Store purchase has not been tested.
- The paid branch has been published to the public GitHub repository with the user's explicit approval. Commit and push this update after review; keep the free release branch unchanged.
- The paid checkout keeps bundle ID `com.careapp.CAREApp` and is prepared as marketing version `1.1`, build `12`. Confirm this is the next available App Store Connect build before upload. The submitted free app is version `1.0`, build `11`, source commit `537107bb4e14f4f885dc60b442ce6a6297373f6a`.
- The paid branch has a compile-time guard in `FigmaExerciseScreenView.swift`: Debug builds work for design review, and distribution/Release builds stop with a message pointing to this protocol. The release engineer removes the guard only after the gates below are complete.

## Jayme's design lane

Jayme can edit copy, layouts, routing, recommendations, and exercise steps in this paid checkout. Save work with local commits on `feature/paid-care-action-plan-preview`. Keep the four Figma exercise pages as the visual source and preserve the shared app top bar.

When an edit changes what a buyer receives, add a short note to the release handoff: which feature is free, which feature requires purchase, and how a user reaches it. The Figma unlock preview shows $9.99; StoreKit supplies the actual storefront price when a product is available. Do not enable purchasing until the App Store Connect product and price are confirmed. If adding a video, image, or external clip, record its source and permission/license in the media register below.

Jayme does not need to create an App Store product or decide review metadata during design work. The release owner takes those steps after design is frozen.

## Purchase model

The design uses a one-time non-consumable unlock for the full Action Plan and expanded exercise library. The product ID in code and App Store Connect is `com.careapp.care.premium.unlock` (Apple IAP ID `6820168912`). The product is **Prepare for Submission**, with English (U.S.) localization, a U.S. base price of $9.99, and availability in all 175 countries or regions. Other storefront prices come from Apple's configured price schedule, not a hardcoded UI string. On October 7, App Store Connect showed the Paid Apps Agreement, bank account, U.S. W-9, and EU Digital Services Act compliance as **Active**. No private tax or banking values are stored in this handoff.

To review without payment in the current simulator: launch the Debug build and tap **Unlock Your C.A.R.E. Action Plan**. **Preview Your C.A.R.E. Action Plan** opens a read-only plan; exercise buttons are replaced by lock labels. The separate **Preview Paid Screens (No Charge)** button enables a temporary Debug preview. For the StoreKit path, tap the $9.99 button, confirm **Continue to Apple Purchase**, and use Xcode's no-charge test sheet. The Run scheme selects `CAREPremium.storekit`. Test cancellation, restore, and revocation locally, then test the configured product in Apple's sandbox and TestFlight before release.

Choose the smallest product that describes what buyers actually receive:

| Model | Appropriate when | Implementation consequence |
| --- | --- | --- |
| One-time non-consumable unlock | The Action Plan and expanded exercise library remain available after one purchase | StoreKit entitlement is permanent unless refunded or revoked; offer Restore Purchases. |
| Consumable assessment credit | A purchase buys one assessment use | Credits need transaction-safe accounting and clear wording; a consumable is not a permanent unlock. |
| Auto-renewable subscription | The customer receives ongoing value over time | Requires subscription terms, ongoing value, status changes, billing support, and a more complex review and support path. |

Do not use a recurring subscription just to unlock a fixed library. Apple says subscriptions must provide ongoing value. Digital features consumed inside the app must use In-App Purchase. Product type and product ID cannot be changed after creation, so confirm the model before creating the product.

## Release-owner protocol: free app to paid update

1. **Anchor the free release.** Version 1.0, build 11, source commit `537107bb4e14f4f885dc60b442ce6a6297373f6a` was submitted to App Review. Confirm approval/publication and the App Store Connect build ID before paid submission. Do not merge the paid branch into the free-release branch.
2. **Bring the paid branch forward.** The branches have unrelated Git histories, so compare and port relevant free-release fixes into the paid branch rather than merging whole histories. Preserve the same bundle ID and App Store Connect app record. Create the next app version and increment the build number for the paid update.
3. **Choose and configure the product.** Account Holder confirms the Paid Apps Agreement, tax, and banking setup. Create the product in App Store Connect with a stable product ID, type, localization, price, and availability. Keep those IDs in one app configuration source.
4. **Implement access in StoreKit 2.** Load product data from Apple; purchase through StoreKit; grant access only from verified current entitlements; observe transaction updates; restore/sync purchases; handle pending, cancelled, refunded, and revoked states. Keep free content usable when product loading or purchase fails. Do not use a local boolean or a hidden button as proof of purchase.
5. **Clear the content gates.** Confirm rights for every bundled thumbnail and external clip. Review clinical/health claims, privacy disclosures, data handling, and the in-app privacy policy link. Remove dead links and preview-only or “coming soon” purchase copy. Every paid exercise must reach a usable endpoint.
6. **Test the update path.** Use Xcode StoreKit testing, App Store sandbox, and TestFlight. Test fresh purchase, cancellation, pending approval, restore on a second device, offline/relaunch behavior, refund/revocation, and upgrade **over the released free app with existing assessment data**. Confirm the free features and stored results survive the update. Test on a physical phone as well as Simulator.
7. **Prepare review material.** Update App Store description and screenshots so paid features are identified as requiring an additional purchase. Add a clear “What’s New,” exact Review Notes explaining free and paid paths, any needed reviewer account, and an IAP review screenshot and notes. The first IAP of its type must be submitted **with a new app version** in the same review submission.
8. **Release deliberately.** Choose the exact processed build for the paid version, review its version/build number and purchase product status, submit the app version and first IAP together, then release after approval. Record the released build and product IDs here. Do not submit or publish from Jayme's design checkout by accident.

## Current paid-release gates

| Gate | State on 2026-10-07 | Owner |
| --- | --- | --- |
| Free release commit/build recorded | 1.0 (11), `537107bb4e14f4f885dc60b442ce6a6297373f6a`; submitted, awaiting review as of October 5 | Release owner |
| Product model, price, ID, and agreement | Production non-consumable `6820168912` created October 7, U.S. base price $9.99, 175 regions, English (U.S.) metadata, **Prepare for Submission**. Paid Apps Agreement, bank account, U.S. W-9, and EU compliance show **Active** | App Store Connect owner |
| StoreKit purchase, verified entitlement, restore, refund handling | Xcode's local StoreKit product and no-charge purchase were verified October 7. Cancellation, restore, revocation, sandbox, and TestFlight remain pending. A separate headless StoreKit test could not reach the product because the simulator test host was not entitled | iOS release engineer |
| Paid content locked until entitlement | Eight originals free; read-only Action Plan preview; added exercise routes gated; Debug-only simulated purchase bypass | iOS release engineer |
| Purchase and upgrade-path testing | A normal fresh install on a separate iPad simulator showed empty onboarding and zero records in all four app storage tables. An in-place 1.0 (11) to 1.1 (12) simulator upgrade preserved a test assessment, contact, photo, profile setup, and exercise draft; the paid app reopened normally. A signed build with a Sandbox Apple Account and a physical-device/TestFlight upgrade remain to be tested | iOS release engineer |
| Media rights/third-party service review | Three screenshot previews replaced with approved original AI art and all three video taps connected on October 7; linked clip rights and remaining imported artwork still need review. See register below | Content owner |
| Bundled Apple emoji artwork replaced with platform rendering or licensed artwork | Free-release Noto artwork and Apache license carried forward for 21 icons; remaining emoji render through iOS. Rebuild and visually verify before distribution | iOS release engineer |
| Updated privacy and health-claim review | Open | Release owner |
| IAP review screenshot, notes, metadata, submission | Product localization is saved. Review screenshot still missing; final build needed. Draft review notes are in `PAID_UPDATE_APP_STORE_COPY.md`; an attempt to save them in App Store Connect did not persist. No IAP was submitted | App Store Connect owner |
| Remote branch backup | Public GitHub branch approved and published; push latest changes | Repository owner |

Assessments may be retaken on the same local day. A newly started or unfinished assessment leaves the earlier result untouched. A successful submission atomically replaces that day's earlier saved result, so history keeps one final result per day.

## Media register to resolve before paid submission

| Asset/content | Where it appears | Evidence needed |
| --- | --- | --- |
| `FigmaReadCharacterClip` preview and YouTube video `dOkyKyVFnSs` | Read a Character's Feelings | Original realistic-people art is installed and Jayme supplied the YouTube link on October 7. The video is titled “Inside Out: Guessing the feelings.” Its use as a paid-exercise source needs a content-rights and availability check; the original video/film artwork is not bundled. |
| `FigmaMirrorGestureOne` preview and TikTok video `7406052816931933482` | Mirror a Gentle Gesture | Original warm-smile art is installed. Jayme supplied the TikTok link on October 7 and the image now opens it externally. Check playback on a device and confirm third-party terms. The unused `FigmaMirrorGestureTwo` screenshot was removed. |
| Hug compilation YouTube video `0Bk5yoFJDo4` | Mirror a Gentle Gesture | Original preview art is installed and the link opens YouTube. Jayme confirmed this eight-minute compilation stays in the exercise; the eight-second welcoming-gesture TikTok is not used. Confirm the video remains available and its use is permitted. |
| Other imported Figma image assets | Breathing, share illustrations | Confirm source ownership/license. |

The paid checkout now carries the free release's Google Noto Emoji PNGs for 21 icons and bundles the Apache 2.0 license; additional Unicode emoji render through iOS at runtime. This removes the Apple-rendered emoji PNGs from the asset catalog. Verify visual sizing and the compiled asset catalog before paid submission. Apple's guideline 5.2.5 prohibits bundling Apple emoji artwork.

## Apple sources checked 2026-10-02

- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/): 2.1 completeness; 2.3 accurate metadata and purchase disclosure; 3.1.1 digital unlocks; 3.1.2 subscription value; 1.4.1 medical claims; 5.1 privacy; 5.2 intellectual property and third-party services.
- [In-App Purchase setup overview](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases/): agreement, metadata, StoreKit, testing, and review.
- [Submit an In-App Purchase](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/): first product of each type goes with a new app version.
- [IAP review information](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/view-and-edit-in-app-purchase-information/): review notes and screenshot.
- [StoreKit testing](https://developer.apple.com/documentation/storekit/testing-at-all-stages-of-development-with-xcode-and-the-sandbox) and [TestFlight IAP testing](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testing-subscriptions-and-in-app-purchases-in-testflight).
- [Maintaining an app](https://developer.apple.com/help/app-store-connect/update-your-app/overview-of-maintaining-an-app) and [uploading builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds).

Apple can change its rules. The release owner should recheck these pages at the paid submission gate.

## Inclusion and data checks for the paid update

The paid update must include all of the current branch's approved design and content changes, not just the purchase screen. The verified routes on October 7 include the free Positive Relational Moments library with saved moment detail, search, favorites, and category filtering; the revised Education introduction, six ten-question rotating quiz banks, and the reviewed quiz wording; the read-only Action Plan preview; and the full plan with 61 additional paid exercises. The first two exercises in each pathway remain free. The library and Education routes do not require a purchase entitlement.

A new installation must start without sample assessments, contacts, saved moments, quiz progress, or exercise progress. `AppEnvironment.makeLive()` uses an empty local store on first launch; sample contacts and assessment history are confined to explicit `--uitesting-*` launch fixtures or SwiftUI previews. A normal update must retain the user's existing local records, including assessments, exercise progress, photos, and saved moments. Do not add a data reset or change the bundle ID. Test both a fresh install and an in-place upgrade from free version 1.0 (11) before submission. The populated CARE Paid Preview simulator is review/test data on that simulator only; it is not bundled into the app.

Relevant free-release fixes carried forward include relationship contact photos in selection and frequency views, optional embedded-video consent, Privacy Enhanced Mode YouTube players with temporary web storage, the public privacy-policy link, licensed Noto exercise icons, and original Mirror preview artwork. Remaining content-rights and release gates below still apply.

## October 7 pre-submission audit

- The paid app and submitted free app use the same bundle ID, `com.careapp.CAREApp`. Their SwiftData storage model files and container configuration are identical at the two recorded commits. The paid app also retains the free app's legacy exercise and Education progress migration. The representative install-over-1.0 simulator check below passed; a physical-device update using existing user data remains required.
- A normal first launch on the separate iPad Pro 13-inch (M5) simulator, without `--uitesting-*` arguments, showed empty onboarding. Its new SwiftData database contained zero assessment sessions, contacts, participant results, and user-draft rows. The CARE Paid Preview simulator and its review data were not changed.
- The current Debug simulator build compiles with the approved original video-preview images. The Release compile guard remains in place until all review gates are closed.
- Apple limits a localized In-App Purchase display name to 30 characters and description to 45 characters. The draft in `PAID_UPDATE_APP_STORE_COPY.md` has been shortened to fit. Confirm those values and the actual $9.99 price in App Store Connect.
- Jayme supplied the warm-smile TikTok and character-feelings YouTube links; both are connected to their exercise screens. All three Figma video preview taps now have destinations. Confirm real-device playback and the rights/third-party-service basis for the linked clips, especially the *Inside Out* video.
- CARE's public privacy-policy URL returned HTTP 200 on October 7. The existing policy describes external links in general and embedded YouTube playback, but the release owner should review whether its wording and App Store Connect privacy answers accurately cover the new paid update and TikTok link.
- The in-place upgrade check used the exact submitted free-app source for version 1.0 (11), plus a temporary test-only launch fixture to save one assessment, one contact and photo, profile setup, and an exercise draft in its live SwiftData store. The fixture was outside this Git branch and is not in either shipping app. Installing the paid 1.1 (12) Debug build over that free build, without deleting the app, retained the assessment, contact, participant result, and three draft rows, including the photo and exercise draft. The paid home screen reopened. This confirms one representative simulator upgrade path, not every existing-user data combination.
- A simulator launch of the ad-hoc paid build without Xcode's local StoreKit configuration could not load the App Store product; the purchase screen showed “Purchase unavailable.” A StoreKitTest lifecycle attempt in that test host also returned `notEntitled` before any purchase. The Mac keychain currently reports zero valid development signing identities. Obtain working Apple development signing and a Sandbox Apple Account, then repeat purchase, cancellation, restore, and refund tests using Apple's sandbox and TestFlight. Do not treat this unsuccessful attempt as proof that the product is unavailable to customers.
