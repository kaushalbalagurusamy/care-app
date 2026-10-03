import Testing
import SwiftUI
import SwiftData
@testable import CAREApp

@Suite("Exercises Module Data Models & Views Test Suite")
struct ExercisesModuleTests {

    @Test("ExerciseCategory allCases covers all 4 CARE dimensions")
    func testExerciseCategories() {
        let categories = ExerciseCategory.allCases
        #expect(categories.count == 4)
        #expect(categories.map(\.rawValue) == ["Calm", "Accepted", "Resonant", "Energetic"])
        for cat in categories {
            #expect(!cat.pathwayDescription.isEmpty)
            #expect(ExerciseItem.allExercises.filter { $0.category == cat }.count == 2,
                    "The free release has exactly two exercises in each CARE category")
        }
        #expect(ExerciseItem.allExercises.count == 8)
    }
    
    @Test("Calm exercises start without completed activity")
    func testSampleCalmExercises() {
        let calmItems = ExerciseItem.sampleCalmExercises
        #expect(calmItems.count == 2)
        #expect(calmItems[0].id == "watch-something-funny")
        #expect(calmItems[0].category == .calm)
        #expect(calmItems[0].timesCompleted == 0)
        #expect(calmItems[0].ratingStars == 0)
        #expect(calmItems[0].isFavorite == false)
        
        #expect(calmItems[1].id == "keep-photo-close")
        #expect(calmItems[1].category == .calm)
        #expect(calmItems[1].timesCompleted == 0)
        #expect(calmItems[1].ratingStars == 0)
    }
    
    @Test("Sample Resonant exercises populate with valid identifiers")
    func testSampleResonantExercises() {
        let resonantItems = ExerciseItem.sampleResonantExercises
        #expect(resonantItems.count == 2)
        #expect(resonantItems[0].id == "mirror-emotion")
        #expect(resonantItems[1].id == "mirror-loved-one")
    }

    @Test("Exercise progress persists and counts one active day per calendar day")
    @MainActor
    func testExerciseProgress() throws {
        let suite = "care.exercise-tests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = ExerciseProgressStore(defaults: defaults)
        #expect(store.completionCount() == 0)
        #expect(store.weekCompletedDays() == 0)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let monday = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 28, hour: 12)))
        for offset in 0..<7 {
            let date = try #require(calendar.date(byAdding: .day, value: offset, to: monday))
            store.complete("watch-something-funny", at: date)
        }
        let sunday = try #require(calendar.date(byAdding: .day, value: 6, to: monday))
        store.complete("keep-photo-close", at: sunday)
        #expect(store.completionCount(for: .calm) == 8)
        #expect(store.weekCompletionCount(for: .calm, now: sunday, calendar: calendar) == 8)
        #expect(store.weekCompletedDays(for: .calm, now: sunday, calendar: calendar) == 7)
        #expect(store.currentStreak(for: .calm, now: sunday, calendar: calendar) == 7)
        #expect(store.weekStatuses(now: sunday, calendar: calendar) == Array(repeating: true, count: 7))

        store.toggleFavorite("watch-something-funny")
        store.setRating(5, for: "watch-something-funny")
        let restored = ExerciseProgressStore(defaults: defaults)
        #expect(restored.completionCount(for: .calm) == 8)
        #expect(restored.record(for: "watch-something-funny").isFavorite)
        #expect(restored.record(for: "watch-something-funny").rating == 5)
    }

    @Test("Duration sorting uses lower or upper numeric bounds with stable ties")
    func testDurationOrdering() {
        let items = ExerciseItem.allExercises
        #expect(items.count == 8)
        #expect(items.allSatisfy { $0.minimumDurationMinutes > 0 && $0.maximumDurationMinutes >= $0.minimumDurationMinutes })
        #expect(items.first(where: { $0.id == "watch-something-funny" })?.minimumDurationMinutes == 7)
        #expect(items.first(where: { $0.id == "watch-something-funny" })?.maximumDurationMinutes == 10)
        #expect(items.first(where: { $0.id == "watch-something-funny" })?.durationMinutesRange == "7–10 min")
        #expect(items.first(where: { $0.id == "keep-photo-close" })?.minimumDurationMinutes == 1)
        #expect(items.first(where: { $0.id == "keep-photo-close" })?.maximumDurationMinutes == 2)
        let shortest = ExerciseSortEngine.sorted(items, by: .shortestDuration, records: [:])
        let longest = ExerciseSortEngine.sorted(items, by: .longestDuration, records: [:])
        #expect(shortest.first?.id == "keep-photo-close")
        #expect(longest.first?.id == "watch-something-funny")
        #expect(ExerciseSortEngine.sorted(items, by: .shortestDuration, records: [:]).map(\.id) == shortest.map(\.id))
        let narrow = ExerciseItem(id: "narrow", title: "Narrow", category: .calm, emoji: "", subtitle: "", durationMinutesRange: "1–2 min", minimumDurationMinutes: 1, maximumDurationMinutes: 2)
        let wide = ExerciseItem(id: "wide", title: "Wide", category: .calm, emoji: "", subtitle: "", durationMinutesRange: "2–10 min", minimumDurationMinutes: 2, maximumDurationMinutes: 10)
        #expect(ExerciseSortEngine.sorted([wide, narrow], by: .shortestDuration, records: [:]).map(\.id) == ["narrow", "wide"])
        #expect(ExerciseSortEngine.sorted([narrow, wide], by: .longestDuration, records: [:]).map(\.id) == ["wide", "narrow"])
    }

    @Test("Exercise order reads saved count, rating, and completion date")
    func testActivityOrdering() {
        let items = ExerciseItem.sampleCalmExercises
        let old = Date(timeIntervalSince1970: 1_000)
        let recent = Date(timeIntervalSince1970: 2_000)
        let records = [
            "watch-something-funny": ExerciseProgressRecord(completionDates: [old, recent], rating: 2),
            "keep-photo-close": ExerciseProgressRecord(completionDates: [old], rating: 5)
        ]
        #expect(ExerciseSortEngine.sorted(items, by: .numberOfTimesCompleted, records: records).first?.id == "watch-something-funny")
        #expect(ExerciseSortEngine.sorted(items, by: .mostRecentlyCompleted, records: records).first?.id == "watch-something-funny")
        #expect(ExerciseSortEngine.sorted(items, by: .highestRated, records: records).first?.id == "keep-photo-close")
    }

    @Test("Weekly activity counts distinct local days across and within categories")
    @MainActor
    func testDistinctWeeklyActivity() throws {
        let suite = "care.exercise-days.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = ExerciseProgressStore(defaults: defaults)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let monday = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 28, hour: 12)))
        for _ in 0..<7 { store.complete("watch-something-funny", at: monday) }
        store.complete("belonging-list", at: monday)
        #expect(store.completionCount() == 8)
        #expect(store.weekCompletedDays(now: monday, calendar: calendar) == 1)
        #expect(store.weekCompletedDays(for: .calm, now: monday, calendar: calendar) == 1)
        #expect(store.weekCompletedDays(for: .accepted, now: monday, calendar: calendar) == 1)
        #expect(store.currentStreak(for: .calm, now: monday, calendar: calendar) == 1)
        for offset in 1..<7 {
            let date = try #require(calendar.date(byAdding: .day, value: offset, to: monday))
            store.complete("watch-something-funny", at: date)
        }
        let sunday = try #require(calendar.date(byAdding: .day, value: 6, to: monday))
        #expect(store.weekCompletedDays(now: sunday, calendar: calendar) == 7)
        #expect(store.currentStreak(for: .calm, now: sunday, calendar: calendar) == 7)
        #expect(store.currentStreak(for: .accepted, now: sunday, calendar: calendar) == 0)
    }

    @Test("A second result on the same local day is rejected atomically; tomorrow is allowed")
    @MainActor
    func testOneAssessmentPerLocalDayAtCommit() throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let store = try UserDraftStore(container: container)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: -4 * 3600)!
        let firstDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 29, hour: 23, minute: 50)))
        let sameDate = try #require(calendar.date(byAdding: .minute, value: 5, to: firstDate))
        let nextDate = try #require(calendar.date(byAdding: .minute, value: 15, to: firstDate))
        func result(at date: Date) -> AssessmentResult {
            AssessmentResult(domainScores: [:], safetyDistribution: .init(safePercentage: 0, moderatePercentage: 0, highRiskPercentage: 0), individualResults: [], timestamp: date)
        }
        let first = result(at: firstDate)
        #expect(try store.hasCompletedAssessment(on: firstDate, calendar: calendar) == false)
        try store.commitAssessmentResult(first, calendar: calendar)
        #expect(try store.hasCompletedAssessment(on: sameDate, calendar: calendar))
        #expect(try store.hasCompletedAssessment(on: nextDate, calendar: calendar) == false)
        try store.commitAssessmentResult(first, calendar: calendar)
        try store.saveValue("keep this", key: "assessment-draft")
        #expect(throws: AssessmentDailyLimitError.self) { try store.commitAssessmentResult(result(at: sameDate), calendar: calendar) }
        #expect(try store.loadValue(String.self, key: "assessment-draft") == "keep this")
        #expect(try container.mainContext.fetch(FetchDescriptor<StoredAssessmentSession>()).count == 1)
        try store.commitAssessmentResult(result(at: nextDate), calendar: calendar)
        #expect(try container.mainContext.fetch(FetchDescriptor<StoredAssessmentSession>()).count == 2)
    }

    @Test("Exercise count, rating, favorite, and recency survive a SQLite reopen")
    @MainActor
    func testPersistedExerciseSortingInputs() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("care-exercise-sort-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let config = ModelConfiguration(schema: StorageContainerFactory.schema,
                                        url: directory.appendingPathComponent("care.sqlite"), cloudKitDatabase: .none)
        let first = Date(timeIntervalSince1970: 1_000)
        let later = Date(timeIntervalSince1970: 2_000)
        do {
            let store = try UserDraftStore(container: ModelContainer(for: StorageContainerFactory.schema, configurations: [config]))
            let progress = ExerciseProgressStore(sharedStore: store)
            try store.saveExercise(ExerciseDraft(exerciseID: "watch-something-funny"))
            try progress.completeAndDiscard("watch-something-funny", at: first)
            try store.saveExercise(ExerciseDraft(exerciseID: "watch-something-funny"))
            try progress.completeAndDiscard("watch-something-funny", at: later)
            try store.saveExercise(ExerciseDraft(exerciseID: "keep-photo-close"))
            try progress.completeAndDiscard("keep-photo-close", at: first)
            progress.setRating(5, for: "keep-photo-close")
            progress.toggleFavorite("keep-photo-close")
        }
        let reopened = try UserDraftStore(container: ModelContainer(for: StorageContainerFactory.schema, configurations: [config]))
        let progress = ExerciseProgressStore(sharedStore: reopened)
        #expect(progress.record(for: "watch-something-funny").completionDates.count == 2)
        #expect(progress.record(for: "keep-photo-close").rating == 5)
        #expect(progress.record(for: "keep-photo-close").isFavorite)
        #expect(ExerciseSortEngine.sorted(ExerciseItem.sampleCalmExercises, by: .mostRecentlyCompleted, records: progress.records).first?.id == "watch-something-funny")
        #expect(ExerciseSortEngine.sorted(ExerciseItem.sampleCalmExercises, by: .highestRated, records: progress.records).first?.id == "keep-photo-close")
    }

    @Test("Existing quiz drafts decode with an empty answer history")
    func testLegacyQuizDraftDecode() throws {
        let original = QuizDraft(topicSlug: .relationalCulturalTheory, questionIDs: ["one"], questionIndex: 0)
        let encoded = try JSONEncoder().encode(original)
        var json = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        json.removeValue(forKey: "answeredLetters")
        let legacy = try JSONSerialization.data(withJSONObject: json)
        let decoded = try JSONDecoder().decode(QuizDraft.self, from: legacy)
        #expect(decoded.answeredLetters.isEmpty)
        #expect(decoded.questionIDs == ["one"])
    }

    @Test("Exercise drafts survive a new store instance and completion erases answers")
    @MainActor
    func testExerciseDraftRoundTrip() throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let store = try UserDraftStore(container: container)
        var draft = ExerciseDraft(exerciseID: "keep-photo-close")
        draft.step = 2
        draft.fields["reflection"] = "I feel calmer"
        draft.photoAssetID = "photo-local-id"
        try store.saveExercise(draft)

        let reopened = try UserDraftStore(container: container)
        #expect(reopened.exercise(for: "keep-photo-close")?.step == 2)
        #expect(reopened.exercise(for: "keep-photo-close")?.fields["reflection"] == "I feel calmer")
        #expect(reopened.exercise(for: "keep-photo-close")?.photoAssetID == "photo-local-id")
        try reopened.discardExercise("keep-photo-close")
        #expect(try UserDraftStore(container: container).exercise(for: "keep-photo-close") == nil)
    }

    @Test("Completing an exercise commits its check-off and removes its answers together")
    @MainActor
    func testAtomicExerciseCompletion() throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let drafts = try UserDraftStore(container: container)
        var draft = ExerciseDraft(exerciseID: "keep-photo-close")
        draft.fields["reflection"] = "private response"
        try drafts.saveExercise(draft)
        let progress = ExerciseProgressStore(sharedStore: drafts)
        try progress.completeAndDiscard("keep-photo-close")
        #expect(progress.completionCount(for: .calm) == 1)
        #expect(drafts.exercise(for: "keep-photo-close") == nil)
        let reopened = try UserDraftStore(container: container)
        #expect(ExerciseProgressStore(sharedStore: reopened).completionCount(for: .calm) == 1)
        #expect(reopened.exercise(for: "keep-photo-close") == nil)
        #expect(throws: CocoaError.self) { try progress.completeAndDiscard("keep-photo-close") }
    }
    
    @Test("Exercise Views instantiate cleanly without runtime fatal errors")
    @MainActor
    func testExerciseViewsInstantiation() {
        let calmView = CalmExercisesView()
        #expect(calmView != nil)
        
        let watchFunny = WatchFunnyExerciseView()
        #expect(watchFunny != nil)
        
        let keepPhoto = KeepPhotoExerciseView()
        #expect(keepPhoto != nil)
        
        let belonging = BelongingListExerciseView()
        #expect(belonging != nil)
        
        let resultsExercises = CAREResultsExercisesView(result: .figmaMockResult)
        #expect(resultsExercises != nil)
        
        let completeView = ExerciseCompleteView()
        #expect(completeView != nil)
    }
}
