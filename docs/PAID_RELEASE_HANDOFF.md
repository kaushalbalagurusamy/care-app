# CARE paid update: design handoff and release protocol

Updated 2026-10-06. This handoff applies to `feature/paid-care-action-plan-preview`. The free app release is being prepared separately in the `CARE App` chat on `jayme/initial-work`.

## The current state

- The paid branch contains the Action Plan preview and 61 added exercises across Calm, Accepted, Resonant, and Energetic. Their 120 screen steps are imported from the four CARE Figma pages. The app keeps its existing top bar.
- The first two exercises in each pathway (eight total), assessments, and the Positive Relational Moments library are free. The 61 added exercises and full personalized Action Plan require the one-time unlock. Free Action Plan buttons open the Figma unlock screen; paid buttons open the plan.
- StoreKit 2 loads product `com.careapp.care.premium.unlock`, grants access from verified current entitlements, observes transaction updates, and supports an explicit Restore Purchases action. A Debug-only button previews paid access without payment; it resets on relaunch. The real purchase button stays disabled until the product is configured and loaded. No real purchase has been tested.
- The paid branch has been published to the public GitHub repository with the user's explicit approval. Commit and push this update after review; keep the free release branch unchanged.
- The current iOS app target uses bundle ID `com.careapp.CAREApp`, marketing version `1.0`, and build `7`. Record the **actual** free-release version, build, and commit after the other agent finishes; these values will change.
- The paid branch has a compile-time guard in `FigmaExerciseScreenView.swift`: Debug builds work for design review, and distribution/Release builds stop with a message pointing to this protocol. The release engineer removes the guard only after the gates below are complete.

## Jayme's design lane

Jayme can edit copy, layouts, routing, recommendations, and exercise steps in this paid checkout. Save work with local commits on `feature/paid-care-action-plan-preview`. Keep the four Figma exercise pages as the visual source and preserve the shared app top bar.

When an edit changes what a buyer receives, add a short note to the release handoff: which feature is free, which feature requires purchase, and how a user reaches it. The Figma unlock preview shows $9.99; StoreKit supplies the actual storefront price when a product is available. Do not enable purchasing until the App Store Connect product and price are confirmed. If adding a video, image, or external clip, record its source and permission/license in the media register below.

Jayme does not need to create an App Store product or decide review metadata during design work. The release owner takes those steps after design is frozen.

## Purchase model

The design uses a one-time non-consumable unlock for the full Action Plan and expanded exercise library. The product ID in code is `com.careapp.care.premium.unlock`; create the matching product in App Store Connect before a real purchase test. The Account Holder must configure the Paid Apps Agreement, banking, tax, localization, and price. Set the US price to $9.99 if that remains the approved price. Other storefront prices come from Apple's configured price schedule, not a hardcoded UI string.

To review without payment in the current simulator: launch the Debug build, tap **Unlock Your C.A.R.E. Action Plan**, then **Preview Paid Access (No Payment)**. The full plan and added exercises appear immediately. Relaunching resets this preview. For a real purchase simulation, create a local StoreKit configuration in Xcode for the same product ID and attach it to the Run scheme; then test purchase, restore, cancellation, and revocation. Also test the configured product in Apple's sandbox before release.

Choose the smallest product that describes what buyers actually receive:

| Model | Appropriate when | Implementation consequence |
| --- | --- | --- |
| One-time non-consumable unlock | The Action Plan and expanded exercise library remain available after one purchase | StoreKit entitlement is permanent unless refunded or revoked; offer Restore Purchases. |
| Consumable assessment credit | A purchase buys one assessment use | Credits need transaction-safe accounting and clear wording; a consumable is not a permanent unlock. |
| Auto-renewable subscription | The customer receives ongoing value over time | Requires subscription terms, ongoing value, status changes, billing support, and a more complex review and support path. |

Do not use a recurring subscription just to unlock a fixed library. Apple says subscriptions must provide ongoing value. Digital features consumed inside the app must use In-App Purchase. Product type and product ID cannot be changed after creation, so confirm the model before creating the product.

## Release-owner protocol: free app to paid update

1. **Anchor the free release.** The other agent finishes its free-version cleanup, commits the exact source used for the App Store/TestFlight build, and records commit SHA, bundle ID, version, build number, and App Store Connect build ID. Do not merge the paid branch into the free-release branch.
2. **Bring the paid branch forward.** After the free-release commit is fixed, merge that release commit **into the paid branch** and resolve conflicts there. Preserve the same bundle ID and App Store Connect app record. Create the next app version and increment the build number for the paid update.
3. **Choose and configure the product.** Account Holder confirms the Paid Apps Agreement, tax, and banking setup. Create the product in App Store Connect with a stable product ID, type, localization, price, and availability. Keep those IDs in one app configuration source.
4. **Implement access in StoreKit 2.** Load product data from Apple; purchase through StoreKit; grant access only from verified current entitlements; observe transaction updates; restore/sync purchases; handle pending, cancelled, refunded, and revoked states. Keep free content usable when product loading or purchase fails. Do not use a local boolean or a hidden button as proof of purchase.
5. **Clear the content gates.** Confirm rights for every bundled thumbnail and external clip. Review clinical/health claims, privacy disclosures, data handling, and the in-app privacy policy link. Remove dead links and preview-only or “coming soon” purchase copy. Every paid exercise must reach a usable endpoint.
6. **Test the update path.** Use Xcode StoreKit testing, App Store sandbox, and TestFlight. Test fresh purchase, cancellation, pending approval, restore on a second device, offline/relaunch behavior, refund/revocation, and upgrade **over the released free app with existing assessment data**. Confirm the free features and stored results survive the update. Test on a physical phone as well as Simulator.
7. **Prepare review material.** Update App Store description and screenshots so paid features are identified as requiring an additional purchase. Add a clear “What’s New,” exact Review Notes explaining free and paid paths, any needed reviewer account, and an IAP review screenshot and notes. The first IAP of its type must be submitted **with a new app version** in the same review submission.
8. **Release deliberately.** Choose the exact processed build for the paid version, review its version/build number and purchase product status, submit the app version and first IAP together, then release after approval. Record the released build and product IDs here. Do not submit or publish from Jayme's design checkout by accident.

## Current paid-release gates

| Gate | State on 2026-10-02 | Owner |
| --- | --- | --- |
| Free release commit/build recorded | Pending today's free submission | Free-release agent |
| Product model, price, ID, and agreement | One-time product and ID chosen in code; App Store Connect setup pending | Kaushal / App Store Connect owner |
| StoreKit purchase, verified entitlement, restore, refund handling | Implemented in Debug build; needs StoreKit configuration, sandbox and revocation testing | iOS release engineer |
| Paid content locked until entitlement | Eight originals free; added exercises and Action Plan gated; Debug-only preview bypass | iOS release engineer |
| Purchase and upgrade-path testing | Free-to-paid preview verified in simulator; actual purchase and upgrade-over-release pending | iOS release engineer |
| Media rights/third-party service review | Open; see register below | Content owner |
| Bundled Apple emoji artwork replaced with platform rendering or licensed artwork | Open; a trial switch caused simulator test restarts, so the visual preview remains unchanged | iOS release engineer |
| Updated privacy and health-claim review | Open | Release owner |
| IAP review screenshot, notes, metadata, submission | Not started | App Store Connect owner |
| Remote branch backup | Public GitHub branch approved and published; push latest changes | Repository owner |

Assessments may be retaken on the same local day. A newly started or unfinished assessment leaves the earlier result untouched. A successful submission atomically replaces that day's earlier saved result, so history keeps one final result per day.

## Media register to resolve before paid submission

| Asset/content | Where it appears | Evidence needed |
| --- | --- | --- |
| `FigmaReadCharacterClip` image, visually depicting *Inside Out* characters | Read a Character's Feelings | License/permission, or replace with original/licensed media and update Figma and app. |
| `FigmaMirrorGestureOne`, `FigmaMirrorGestureTwo` and external gesture clips | Mirror a Gentle Gesture | Source rights and third-party service terms, or replace. |
| YouTube clip used in existing exercise flow | Mirror a Gentle Gesture | Confirm permitted embedding and a safe fallback when unavailable. |
| Other imported Figma image assets | Breathing, share illustrations | Confirm source ownership/license. |

The preview bundles PNGs rendered from Apple's emoji font. Apple's guideline 5.2.5 says apps may not include Apple emoji. A trial switch to native system emoji caused simulator UI-test restarts, so the preview was restored to its last passing design state. The iOS release engineer must replace those bundled images with a stable system-rendered or properly licensed approach and verify it on target devices before paid submission. Check the free-release checkout separately for the same assets.

## Apple sources checked 2026-10-02

- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/): 2.1 completeness; 2.3 accurate metadata and purchase disclosure; 3.1.1 digital unlocks; 3.1.2 subscription value; 1.4.1 medical claims; 5.1 privacy; 5.2 intellectual property and third-party services.
- [In-App Purchase setup overview](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases/): agreement, metadata, StoreKit, testing, and review.
- [Submit an In-App Purchase](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/): first product of each type goes with a new app version.
- [IAP review information](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/view-and-edit-in-app-purchase-information/): review notes and screenshot.
- [StoreKit testing](https://developer.apple.com/documentation/storekit/testing-at-all-stages-of-development-with-xcode-and-the-sandbox) and [TestFlight IAP testing](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testing-subscriptions-and-in-app-purchases-in-testflight).
- [Maintaining an app](https://developer.apple.com/help/app-store-connect/update-your-app/overview-of-maintaining-an-app) and [uploading builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds).

Apple can change its rules. The release owner should recheck these pages at the paid submission gate.
