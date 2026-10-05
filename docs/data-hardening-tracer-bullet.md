# CARE user data hardening — tracer-bullet product requirement

Status: local data-hardening implementation complete; release UX testing remains a separate step, 29 September 2026. Source of truth is the live Swift code plus the user's decisions. The [source audit](/Users/jaymebanks/.codex/.chatgpt-projects/g-p-6ab9b0fbec9c81918a6fcd720b6948e0/CARE-data-architecture-audit.md) records the pre-hardening behavior; the [planning report](/Users/jaymebanks/.codex/.chatgpt-projects/g-p-6ab9b0fbec9c81918a6fcd720b6948e0/CARE-data-hardening-plan.md) describes design alternatives.

## Product invariants

1. An assessment requires **exactly five distinct people**, each answering all 20 questions. Five questions belong to each CARE category. Each answer contributes one to five raw points, so each category is out of **125** and all four together are out of **500**. Relationship-time percentages influence the separate safety distribution, not CARE category totals. Person safety indicators remain normalized to 100. A user cannot bypass the five-person gate via resume, navigation, or an old draft.
2. One app-facing user-data service is the authority for editable user facts and unfinished work. Views may keep short-lived rendering state, but reopening the app must recover the last successfully saved draft. A field shown on multiple screens resolves to the same record ID. Completed assessments keep immutable participant snapshots; those are intentional historical evidence.
3. A final assessment submission is saved locally before it is treated as complete. Failure preserves the draft and shows a retry path. A repeated submission cannot create two results. Previous /100 category results retain their old denominator; they are never relabeled as /125. Historical trends compare percentages when scales differ.
4. Exercise answers are temporary. Text, selections, step and media references are autosaved while in progress. Leaving retains the draft; completing creates one completion event and removes draft answers. The exercise card uses a gray overlay matching its card geometry and offers **Continue** or **Discard**. Continue opens the saved step; Discard removes the draft after confirmation. Exercise completion history keeps dates, rating and favorite, not completed answers.
5. A quiz has a saved topic, chosen question IDs, question index, selection, feedback state and accumulated score. A gray overlay matching the education module card offers **Continue** or **Discard**. Continue restores the exact question set and step, rather than drawing a new random set. Discard removes only that draft. Quiz result/progress is committed once on completion.
6. A selected Photos item is stored as an asset identifier when available, with content type/metadata needed to re-resolve it. The app does not persist a picker temporary path as a durable reference and does not retain an original-size media copy for a draft. If the item cannot be reopened (missing identifier, deleted asset, revoked access, offline iCloud original), show a reselect action and retain the other draft fields. A web video stores its URL, not its bytes. If guaranteed offline media resume becomes a separate requirement, specify a bounded temporary copy and deletion rule first.
7. Production starts with no invented people, results, progress or recommendation. Development previews and tests may inject fixtures. Latest Results, Past Results, and recommendation surfaces derive from real saved results or display an honest empty state. Clearing a category of data clears its drafts and dependent auxiliary records, and handles save/delete errors visibly.
8. Local save is the success condition. iCloud sync remains **off** until schema, migration, conflicts, deletion propagation, media policy and privacy copy are separately verified. Enabling iCloud later must not create parallel screen-level writes or duplicate records.

## Mutually exclusive acceptance areas

| Area | Tracer bullet | Tests and evaluation before implementation |
|---|---|---|
| Assessment entry and scoring | Select 4, 5, then 6 people; complete 100 answers with uneven time allocations | Only five can advance; all-max scores yield four 125s and 500; mixed answers sum raw points; safety distribution remains time-weighted; draft with wrong count cannot resume. |
| Assessment commit and history | Submit, terminate, reopen, inspect Latest and Past | One persisted result, correct denominator and participant snapshots; save failure leaves draft; legacy /100 result remains /100; mixed-scale trends compare normalized values. |
| Profile/contact/settings identity | Edit the same contact/profile field from each entry surface and reopen | One identified canonical record; Cancel discards only draft; save propagates to every screen; media and auxiliary keys clear with contact/profile. |
| Exercise draft and completion | Enter text, select choice/media, leave, relaunch, continue, complete | Same step and text return; asset ID or reselect placeholder returns; no completed answers remain; exactly one completion event; overlay Continue/Discard behaves correctly. |
| Quiz draft and completion | Start randomized quiz, answer, leave, relaunch, continue | Same question IDs/order, index, answer and score return; discard removes only draft; final progress commits once; module overlay reflects state. |
| Production/erasure/iCloud | Fresh install, upgraded sample install, scope-specific erase, offline run | No sample rows shown/seeded; empty states accurate; each erase scope complete; app works without iCloud; no false sync or encryption claim. |

## Evaluation method

Unit tests cover score math, unique IDs, draft encode/decode, version preservation and deletion semantics. Repository tests use a persistent test container reopened as a new app instance. UI tests drive each banner and exact-step resume. Manual simulator checks force-close after edits on each input screen, deny Photos access, remove a selected item, go offline, and relaunch. The independent reviewer will trace the storage write/read path in source, check error handling and card navigation, inspect migration assumptions, and report gaps even if tests pass.

## Implementation order

1. Add failing acceptance tests for the data service and key flows.
2. Build the app-facing store and versioned records. Preserve old persisted data; migrate or bridge existing locations without fabricating data.
3. Wire assessment, profile/contact, exercise and quiz screens to canonical records and draft operations.
4. Add the two geometry-matched resume overlays, empty states and accurate leave/reselect copy.
5. Run model, repository and UI tests, reopen the simulator app, and have an independent source reviewer evaluate the mechanism.

## Implemented local data paths

| User data | Durable record and writer | Read surfaces and close/reopen behavior |
|---|---|---|
| Relationships | `StoredContact` by UUID; compressed photo bytes keyed `contact-photo:<UUID>` in the same SwiftData container. `UserDraftStore.commitContact` writes contact, photo and removes the edit draft in one save. | Add/Edit/Choose fetch the contact repository. `contact-edit:<UUID or new>` restores unfinished form fields. A new form keeps its UUID across retries. |
| Profile and setup | `care.profile.settings.v1` stored in `StoredUserDraft`; `profile-edit` stores unfinished profile edits. Canonical Save and draft removal share one transaction. | Welcome and Profile read one `ProfileSettingsStore`. Photos are resized to at most 512 px before storage. |
| Assessment in progress | `assessment-selection`, `assessment-allocations` and `assessment-draft` keys in SwiftData. Taps/slider writes persist before the view advances. | Home shows a Continue/Discard overlay. The exact five-person session and current answer/step restore after relaunch. |
| Completed assessments | `StoredAssessmentSession` plus participant snapshots. `commitAssessmentResult` writes the result and deletes assessment drafts together by stable result ID. | Latest Results, Past Results and recommendations read saved results. Legacy rows retain `/100`; new rows store `/125`. No result displays an empty state. |
| Exercise in progress | `exercise:<ID>` includes step, fields, optional Photos asset IDs or web URL. | Home and exercise-category cards show Continue/Discard. Missing Photos assets ask for re-selection; completed answers are removed. |
| Exercise completion/favorites | `exercise-progress` stores completion dates, idempotency tokens, ratings and favorites. `finishExercise` writes the check-off and deletes the draft in one transaction. | Home streak and exercise screens derive counts from the shared record. The record has no completed answer text/media. |
| Education quiz | `quiz:<topic>` stores chosen question IDs, cursor, selection and score. `education-progress` stores attempts, pool and mastery. `finishQuiz` commits a result and removes its draft together. | Home and module cards show Continue/Discard; resumed quizzes retain the same questions and step. |
| App lock preference | `com.careapp.security.isAppLockEnabled` is migrated into the shared store and removed with full erasure. Authentication state remains transient. | App launch and security settings read one `AppLockManager`; a failed storage write prevents a successful toggle. |

### Source paths to inspect

| Concern | Source of the live behavior |
|---|---|
| App startup, failure screen and store wiring | [CAREApp.swift](../ios/CAREApp/CAREApp.swift), [AppEnvironment.swift](../ios/CAREApp/Navigation/AppEnvironment.swift), [StorageContainer.swift](../ios/CAREApp/Storage/StorageContainer.swift) |
| Drafts, contact photos, atomic commits and erasure | [ExerciseModels.swift](../ios/CAREApp/Models/ExerciseModels.swift), [LocalDeviceRepository.swift](../ios/CAREApp/Repositories/LocalDeviceRepository.swift) |
| Five-person gate, answers and scores | [AssessmentSession.swift](../ios/CAREApp/Models/AssessmentSession.swift), [ScoringEngine.swift](../ios/CAREApp/Models/ScoringEngine.swift), [SurveyQuestionView.swift](../ios/CAREApp/Views/SurveyQuestionView.swift) |
| Route restoration and current result | [ContentView.swift](../ios/CAREApp/ContentView.swift), [HomeView.swift](../ios/CAREApp/Views/HomeView.swift) |
| Exercise drafts and media cleanup | [AdditionalExerciseViews.swift](../ios/CAREApp/Views/AdditionalExerciseViews.swift), [WatchFunnyExerciseView.swift](../ios/CAREApp/Views/WatchFunnyExerciseView.swift) |
| Quiz draft and completion | [EducationQuizView.swift](../ios/CAREApp/Views/Education/EducationQuizView.swift), [EducationProgressRepositoryProtocol.swift](../ios/CAREApp/Repositories/EducationProgressRepositoryProtocol.swift) |
| Profile, lock and data controls | [ProfileSettingsStore.swift](../ios/CAREApp/Models/ProfileSettingsStore.swift), [AppLockManager.swift](../ios/CAREApp/Navigation/AppLockManager.swift), [ProfileView.swift](../ios/CAREApp/Views/ProfileView.swift), [StorageSettingsView.swift](../ios/CAREApp/Views/StorageSettingsView.swift) |

CloudKit sync is disabled in the live environment. The records above remain on this device; enabling cross-device sync requires a separate migration, conflict and deletion design. iCloud device backup is a separate platform behavior.

Picker movie copies exist only while an exercise is active. Normal exit removes them, and launch removes any copies abandoned by a force quit. If a saved Photos asset is no longer available, the draft retains its other fields and asks the user to reselect it. Unreadable drafts remain in the store and trigger a warning; assessment, exercise and quiz saves will not overwrite those records. Startup validates canonical profile, selection, allocation, exercise progress, education progress and app-lock records before opening any view. An unreadable canonical record or database shows a retry screen and remains intact. A damaged app-lock value also fails closed if opened directly.

### Verification and review

- The final iPhone 16 Pro simulator suite passed **167/167** tests with zero failures. Focused scoring, storage and security runs also passed while closing review findings.
- The app was installed and launched on the booted simulator. The visible Home screen showed **0/7** exercise activity and an honest “complete your first assessment” schedule prompt.
- An independent source reviewer traced the implementation, identified contact erasure, unreadable-draft, startup and temporary-video recovery gaps, and checked the repairs in source. The reviewer did not rely solely on passing tests.
- Manual release UX testing of real Photos permission changes, deleted/iCloud-only media, notification authorization and every exercise screen remains to be done before TestFlight. No App Store Connect upload is part of this hardening change.

### Data footprint estimates

These are logical payload estimates; SQLite indexes, journal files and backups add overhead. Compressed saved profile/contact photos are resized to at most 512 px. Exercise photo/video originals stay in Photos and are not copied for draft persistence.

| Scenario | Structured records | Saved portrait photos | Approximate local total including a 0.1–0.5 MB database baseline |
|---|---:|---:|---:|
| 5 contacts, 2 assessments, 20 exercise check-offs, 1 active draft | 20–80 KB | 0–3 photos at roughly 30–150 KB each | 0.12–1.03 MB |
| 20 contacts, 24 assessments, 200 check-offs, 1 active draft | 90–350 KB | 0–11 photos at roughly 30–150 KB each | 0.19–2.50 MB |
| 50 contacts, 50 assessments, 1,000 check-offs, 1 active draft | 180–700 KB | 0–51 photos at roughly 30–150 KB each | 0.28–8.85 MB |
