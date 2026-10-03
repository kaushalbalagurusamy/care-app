# CARE release readiness plan

**Updated:** October 2, 2026, after the local build 9 archive
**Release intent:** a free, U.S.-only educational iOS app. No in-app purchase or paid-content teaser in the first public version. This document records verified local evidence separately from App Store Connect status; it is not a claim that a public release has been approved.

## Current snapshot

| Workstream | Status | Evidence and next action |
|---|---|---|
| iOS app and persistence | Final simulator suite passed; device walkthrough pending | The exact build 9 source passed 198/198 iOS tests with no failures or skips on a clean-install iPhone 16 Pro simulator (iOS 18.6, October 2). An earlier run caught a clipped Privacy tab; the spacing fix and full rerun passed. The dedicated CARE Fresh Install QA simulator has since been erased, booted, and launched with the latest app and no test fixture. Visual confirmation is pending because the Mac was locked. A fresh-install walkthrough on a physical phone remains. |
| Build and TestFlight pipeline | Signed build 1.0 (9) prepared locally; last upload: build 7 | Fastlane archived and exported build 9 without uploading it. The 13 MB IPA at `build/fastlane/export-1.0-9/CAREApp.ipa` has bundle ID `com.careapp.CAREApp`, build number 9, and a verified distribution signature. SHA-256: `49e3311cd0d063a4e8f07d42a32be4507a93203ffc2fa61e0248abc5ac2fcfbd`. Build 8 was also prepared locally but is superseded and was never uploaded. Build 7 remains the last recorded TestFlight upload; build 9 awaits review before upload, processing, and phone UX sign-off. |
| CI | Local suites passed; hosted run pending | `.github/workflows/ci.yml` runs iOS simulator tests and backend tests on push/PR. The exact build 9 source passed 198/198 iOS tests; backend suite passed 2/2. GitHub push is pending renewed GitHub authentication on this Mac, so hosted CI has not run against the free-release branch. |
| Privacy policy | Published; disclosure form pending | Amy-approved CARE policy is live at <https://care-app-privacy.vercel.app/> and returned HTTP 200 without signing in. The app Privacy screen links to it; the App Store record has the English (US) policy URL and privacy-choices URL. The data-practice questionnaire still needs a signed-in App Store Connect session and a resolved embedded-video tracking answer. |
| Educational positioning | Product intent agreed; copy audit in progress | Amy describes CARE as education, not diagnosis or treatment. The first-launch profile description and two other stray terms were adjusted to avoid implying an account or medical metrics. Review remaining user-facing claims and the proposed App Store listing against that intent before submission. |
| Video use and thumbnails | Audit in progress; release decision pending | Three YouTube IDs in the app resolve to public embed metadata. Both embedded players now present an optional pre-play choice linking CARE's policy and YouTube's terms; focused UI tests passed. The two Calm preview assets are bundled local illustrations, while the Mirror the Emotion preview is a bundled video still. Public playback does not itself grant a license to copy a creator's still into the app. Confirm source/permission for that still or replace it with a licensed image or official YouTube thumbnail fetched under YouTube's rules. Confirm the embed is permitted and playable on a physical device. |
| Free launch / purchase UI | Implemented on local branch | The `jayme/initial-work` checkpoint commit `15a4060` preserves the prior teaser. On `jayme/free-release`, the sparkle navigation, paid-plan route, screen, and “Unlock Full Book Exercises” buttons have been removed. Exactly two exercises per CARE category are visible. The free-release UI test and the broader simulator suite passed. The separately named remote paid-preview branch currently points to the same commit as `origin/main`; it does not contain a purchase implementation. |
| Availability and release metadata | Partly verified | Apple's API reports U.S. as the base territory and version 1.0 in `PREPARE_FOR_SUBMISSION`, with release type `AFTER_APPROVAL`. The English (US) App Store version currently lacks a description, keywords, and support URL. Free pricing, storefront availability, screenshots, and the actual release choice still need verification in App Store Connect. “Immediate” means after App Review approval, not immediately after upload. |

The [App Store listing draft](app-store-listing-draft.md) supplies reviewable copy for the missing English (US) fields; it has not been entered in App Store Connect.

## Release slice: remove the purchase teaser

**Implementation intent:** The initial public app offers assessments, education, and exactly two exercises in each CARE category without payment. There is no visible promise of a future paid tier. The free “Your C.A.R.E. Profile” exercise recommendations remain available.

**Implemented cleanup and verification sequence:**

1. Remove the sparkle action from `HeaderNavBar` rather than setting `showSparkleButton: false` on each screen. Delete its route-specific callback, placement/configuration API, and action-plan accessibility label. Keep unrelated decorative sparkle art/icons used by education or exercise content.
2. Remove the pinned **Unlock Full Book Exercises** buttons from `ExercisesView` and the shared `ExerciseCategoryHomeView` (all four category screens). Let the existing scroll content use the freed vertical space; keep normal exercise navigation and the free recommendations in `CAREResultsExercisesView`.
3. Remove `.personalizedActionPlan` from `AppRoute`, its `ContentView` case, and the `PersonalizedActionPlanView` from the app target. Remove assessment/person-transition `onSparkle` navigation and any remaining direct links. The unused screen can be recovered from Git history if monetization is designed later; it should not be dormant in the submitted app.
4. Search all compiled UI, accessibility labels, bundled copy, screenshots, App Store metadata, and tests for `purchase`, `unlock`, `premium`, `exclusive`, `full book`, the plan route, and price strings. Review matches in context: biometric “Unlock” and ordinary educational prose are unrelated and should remain.
5. Replace old tests that expect the sparkle button/route with observable absence tests. Verify Home, Assessment, Results, Past Results, Profile, all exercise categories, and in-progress-flow headers have only their intended navigation. Verify no empty header slot or bottom spacer remains, and that Back/Home/progress warnings still work.
6. Build the Release configuration, run the iOS and backend CI suite, inspect a clean-install simulator and a physical phone, then archive a new build number. Only that newly verified build should be selected for public App Review.

**Acceptance:** no visible paid-content teaser, no reachable or compiled plan screen, no broken route, and no change to free exercise access, saved data, or the free results-to-exercises recommendations. This is a code/build cleanup, not an App Store Connect switch. Removing the teaser requires an updated build; it does not retroactively alter existing TestFlight builds.

Apple's [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) say app functionality should be clear and prohibit hidden, dormant, or undocumented features (2.3.1). They also govern payment for digital goods (3.1.1). This is why the plan removes the dormant route rather than merely hiding its button. A later paid feature would use a normal app update; Apple says the first in-app purchase of a given type must be [submitted with a new app version](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/). No takedown of the free app is required.

## Remaining release gates, in order

1. Finish the free-launch regression checks; separately finalize educational/nonmedical wording and the YouTube thumbnail/embedding decision.
2. Finish the App Privacy data-practice answers, including the embedded YouTube player’s collection and tracking treatment; verify contact/support information, rights, screenshots, app category, U.S. availability, and Free pricing in App Store Connect. The policy URL and privacy-choices URL are already set.
3. Run local and hosted CI on the exact release source, then a fresh-install and persistence walkthrough on simulator and phone. Check video playback, permissions, accessibility, and no sample data.
4. Archive/upload a new TestFlight build, verify processing and tester access, and collect final device UX sign-off. Uploading a new build does not replace older TestFlight builds; select the intended build for each group and for App Review.
5. Submit the approved build and metadata for App Review. Confirm the chosen automatic/manual release setting and verify the U.S. listing after approval.

## Source checkpoints

- `ios/CAREApp/Components/HeaderNavBar.swift`, `Views/ExercisesView.swift`, `Views/CalmExercisesView.swift`, `Navigation/AppRouter.swift`, and `ContentView.swift` define the current free navigation and exercise catalog. The removed plan screen remains recoverable from Git history.
- `ios/CAREApp/Views/CAREResultsExercisesView.swift` is the separate free recommendation screen and stays.
- `ios/CAREApp/Views/WatchFunnyExerciseView.swift` embeds two YouTube clips and bundles two preview illustrations; `Views/AdditionalExerciseViews.swift` embeds the Mirror clip and bundles its preview still.
- `fastlane/Fastfile`, `.github/workflows/ci.yml`, and `docs/privacy-site/` contain the pipeline and published policy source.

For a reviewable release archive without a TestFlight upload, run `SKIP_TESTFLIGHT_UPLOAD=1 bundle exec fastlane ios beta`. The lane still increments the build number and exports an IPA under `build/fastlane/`; once approved, `bundle exec fastlane ios upload_ipa IPA_PATH=<absolute IPA path>` uploads that exact file.
