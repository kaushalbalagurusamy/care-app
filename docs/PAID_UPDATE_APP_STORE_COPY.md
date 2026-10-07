# CARE 1.1 paid update: App Store Connect draft

Prepared October 7, 2026. Review the final wording, screenshots, and product price before entering it in App Store Connect. The 1.0 free release remains a separate submission.

## What's New

Explore the free Positive Relational Moments library to revisit moments saved from eligible exercises. CARE 1.1 also refines the Education lessons and quizzes, adds clearer assessment and past-results views, and introduces an optional one-time purchase for a personalized C.A.R.E. Action Plan and 61 additional exercises. The original eight exercises remain free.

## In-App Purchase

- Reference name: C.A.R.E. Plan + Exercises
- Product ID: `com.careapp.care.premium.unlock`
- Type: non-consumable, one-time unlock
- English (U.S.) display name: C.A.R.E. Plan + Exercises
- English (U.S.) description: Unlock your plan and 61 more exercises.
- Proposed U.S. price: $9.99. The app displays Apple's live storefront price; confirm the configured price and other territories in App Store Connect.
- Family Sharing: off in the local test configuration; decide before creating the production product.

## App Review notes draft

CARE works without an account. The first two exercises in each of the four C.A.R.E. pathways, assessments, Education, past results, and the Positive Relational Moments library are free. The library begins empty on a fresh install and stores moments locally when a user completes an eligible free or paid PRM exercise. No example user records ship with the app.

To inspect the paid flow, complete an assessment, open **Unlock Your C.A.R.E. Action Plan**, view the read-only plan preview, then use the one-time **C.A.R.E. Plan + Exercises** in-app purchase. A verified purchase unlocks the full personalized plan and 61 additional exercises. **Restore Purchase** is in My Profile for people reinstalling or using another device with the same Apple Account. Please use Apple's review test purchase flow; no CARE login is needed. The first non-consumable product should be submitted together with app version 1.1.

The app stores user assessments, saved moments, and exercise progress locally. Updating from free CARE 1.0 preserves that data; fresh installations contain no sample records.

Some exercises offer optional video examples. The original Calm clips and Mirror the Emotion use a consent-gated YouTube player; the paid Mirror a Gentle Gesture and Read a Character's Feelings screens open the selected TikTok or YouTube page in the external browser. CARE does not bundle those videos or their captured frames. Supply any requested third-party content permission or service-terms documentation with review materials.

## IAP review screenshot

Capture the actual 1.1 unlock screen on the final review build showing the product name, Apple's configured price, one-time purchase wording, and 61-exercise benefit. Do not submit a Debug screenshot with **Preview Paid Screens (No Charge)**.

## Submission checks

- Confirm 1.0 is approved or live and version 1.1 build 12 is available for the same bundle ID.
- Complete App Store Connect agreements, tax, banking, IAP localization, availability, price, and product review image.
- Verify sandbox and TestFlight purchase, cancellation, restore, revocation, and an update over 1.0 with existing local data.
- Clear media rights and health/privacy review; remove the distribution build guard only then.
- Confirm the released app contains the free PRM library and Education changes as well as the paid content.
