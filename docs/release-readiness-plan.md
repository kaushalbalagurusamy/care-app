# CARE release readiness plan

**Updated:** October 1, 2026
**Release intent:** a free, U.S.-only educational iOS app. No in-app purchase or paid-content teaser in the first public version. This document records verified local evidence separately from App Store Connect status; it is not a claim that a public release has been approved.

## Current snapshot

| Workstream | Status | Evidence and next action |
|---|---|---|
| iOS app and persistence | Implemented locally; final release regression pending | The [first-user walkthrough spec](walkthrough-tracer-bullet-prd.md) records 190/190 local tests on an iPhone 16e before the latest release assets and policy work. Re-run the full suite and a fresh-install device walkthrough after the final app changes. |
| Build and TestFlight pipeline | Build 1.0 (7) valid and in beta testing | Fastlane archived, exported, and uploaded the current local app with the three illustrated home cards on October 1. App Store Connect reports build 7 `VALID`, `IN_BETA_TESTING` internally and externally, and attached to both the CARE internal and Jayme/Kaushal external groups. Device UX sign-off remains pending. The local source changes are still uncommitted. |
| CI | Workflow written; hosted run pending | `.github/workflows/ci.yml` runs iOS simulator tests and backend tests on push/PR. The current worktree has many uncommitted changes; a hosted run cannot verify them until the intended branch is pushed. |
| Privacy policy | Drafted; **not yet public** | [Privacy page](privacy-site/index.html) is a static, locally reviewed draft. Publish to a stable Vercel production URL, have Amy review the operator/data wording, open the URL without signing in, enter it in App Store Connect, and align the App Privacy answers. |
| Educational positioning | Product intent agreed; copy audit pending | Amy describes CARE as education, not diagnosis or treatment. Review user-facing claims and App Store metadata against that intent before submission. The privacy page describes data handling; the education/nonmedical message belongs in app and store copy. |
| Video use and thumbnails | Audit in progress; release decision pending | Three YouTube IDs in the app resolve to public embed metadata. The two Calm preview assets are bundled local illustrations, while the Mirror the Emotion preview is a bundled video still. Public playback does not itself grant a license to copy a creator's still into the app. Confirm source/permission for that still or replace it with a licensed image or official YouTube thumbnail fetched under YouTube's rules. Confirm the embed is permitted and playable on a physical device. |
| Free launch / purchase UI | **Plan only; no change authorized yet** | The release slice below removes the sparkle navigation and paid-plan teaser comprehensively. The app currently has no `StoreKit` import or transaction flow, but the plan route and “Unlock Full Book Exercises” buttons remain in the compiled UI. |
| Availability and release metadata | Decision stated; configuration unverified | Select U.S. as the initial storefront, set the app price to Free, complete required App Store fields/screenshots, and choose a release method. “Immediate” means after App Review approval, not immediately after upload. |

## Release slice: remove the purchase teaser

**Decision to review:** The initial public app offers all currently implemented assessments, education, and exercises without payment. There is no visible promise of a future paid tier. The free “Your C.A.R.E. Profile” exercise recommendations remain available.

**Implementation sequence, after approval to edit the app:**

1. Remove the sparkle action from `HeaderNavBar` rather than setting `showSparkleButton: false` on each screen. Delete its route-specific callback, placement/configuration API, and action-plan accessibility label. Keep unrelated decorative sparkle art/icons used by education or exercise content.
2. Remove the pinned **Unlock Full Book Exercises** buttons from `ExercisesView` and the shared `ExerciseCategoryHomeView` (all four category screens). Let the existing scroll content use the freed vertical space; keep normal exercise navigation and the free recommendations in `CAREResultsExercisesView`.
3. Remove `.personalizedActionPlan` from `AppRoute`, its `ContentView` case, and the `PersonalizedActionPlanView` from the app target. Remove assessment/person-transition `onSparkle` navigation and any remaining direct links. The unused screen can be recovered from Git history if monetization is designed later; it should not be dormant in the submitted app.
4. Search all compiled UI, accessibility labels, bundled copy, screenshots, App Store metadata, and tests for `purchase`, `unlock`, `premium`, `exclusive`, `full book`, the plan route, and price strings. Review matches in context: biometric “Unlock” and ordinary educational prose are unrelated and should remain.
5. Replace old tests that expect the sparkle button/route with observable absence tests. Verify Home, Assessment, Results, Past Results, Profile, all exercise categories, and in-progress-flow headers have only their intended navigation. Verify no empty header slot or bottom spacer remains, and that Back/Home/progress warnings still work.
6. Build the Release configuration, run the iOS and backend CI suite, inspect a clean-install simulator and a physical phone, then archive a new build number. Only that newly verified build should be selected for public App Review.

**Acceptance:** no visible paid-content teaser, no reachable or compiled plan screen, no broken route, and no change to free exercise access, saved data, or the free results-to-exercises recommendations. This is a code/build cleanup, not an App Store Connect switch. Removing the teaser requires an updated build; it does not retroactively alter existing TestFlight builds.

Apple's [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) say app functionality should be clear and prohibit hidden, dormant, or undocumented features (2.3.1). They also govern payment for digital goods (3.1.1). This is why the plan removes the dormant route rather than merely hiding its button. A later paid feature would use a normal app update; Apple says the first in-app purchase of a given type must be [submitted with a new app version](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/). No takedown of the free app is required.

## Remaining release gates, in order

1. Decide and implement the free-launch UI slice above; separately finalize educational/nonmedical wording and the YouTube thumbnail/embedding decision.
2. Finish the public privacy URL and Amy's policy review; verify App Privacy disclosures, contact/support information, rights, screenshots, app category, U.S. availability, and Free pricing in App Store Connect.
3. Run local and hosted CI on the exact release source, then a fresh-install and persistence walkthrough on simulator and phone. Check video playback, permissions, accessibility, and no sample data.
4. Archive/upload a new TestFlight build, verify processing and tester access, and collect final device UX sign-off. Uploading a new build does not replace older TestFlight builds; select the intended build for each group and for App Review.
5. Submit the approved build and metadata for App Review. Confirm the chosen automatic/manual release setting and verify the U.S. listing after approval.

## Source checkpoints

- `ios/CAREApp/Components/HeaderNavBar.swift`, `Views/ExercisesView.swift`, `Views/CalmExercisesView.swift`, `Navigation/AppRouter.swift`, `ContentView.swift`, and `Views/PersonalizedActionPlanView.swift` define the current teaser surface and route.
- `ios/CAREApp/Views/CAREResultsExercisesView.swift` is the separate free recommendation screen and stays.
- `ios/CAREApp/Views/WatchFunnyExerciseView.swift` embeds two YouTube clips and bundles two preview illustrations; `Views/AdditionalExerciseViews.swift` embeds the Mirror clip and bundles its preview still.
- `fastlane/Fastfile`, `.github/workflows/ci.yml`, and `docs/privacy-site/` contain the pipeline and privacy-site draft.
