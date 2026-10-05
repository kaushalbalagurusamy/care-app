import Foundation
import Observation
import SwiftUI
import SwiftData
import Photos
import AVKit

// MARK: - Exercise Category
public enum ExerciseCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case calm = "Calm"
    case accepted = "Accepted"
    case resonant = "Resonant"
    case energetic = "Energetic"
    
    public var id: String { rawValue }

    public var badgeColor: Color {
        switch self {
        case .calm: return Theme.Colors.Domains.calm
        case .accepted: return Theme.Colors.Domains.accepted
        case .resonant: return Theme.Colors.Domains.resonant
        case .energetic: return Theme.Colors.Domains.energetic
        }
    }

    public var accentColor: Color {
        switch self {
        case .calm: return Theme.Colors.Domains.calmAccent
        case .accepted: return Theme.Colors.Domains.acceptedAccent
        case .resonant: return Theme.Colors.Domains.resonantAccent
        case .energetic: return Theme.Colors.Domains.energeticAccent
        }
    }
    
    public var pathwayDescription: String {
        switch self {
        case .calm:
            return "Exercises for feeling safe, grounded & connected."
        case .accepted:
            return "Exercises for feeling valued, validated & included."
        case .resonant:
            return "Exercises for emotional attunement & mutual empathy."
        case .energetic:
            return "Exercises for vitality, zest & shared motivation."
        }
    }
}

// MARK: - Exercise Item Model
public struct ExerciseItem: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let category: ExerciseCategory
    public let emoji: String
    public let subtitle: String
    public let durationMinutesRange: String
    public let minimumDurationMinutes: Int
    public let maximumDurationMinutes: Int
    public var timesCompleted: Int
    public var lastCompletedDate: String?
    public var ratingStars: Int
    public var isFavorite: Bool
    
    public init(
        id: String,
        title: String,
        category: ExerciseCategory,
        emoji: String,
        subtitle: String,
        durationMinutesRange: String,
        minimumDurationMinutes: Int,
        maximumDurationMinutes: Int,
        timesCompleted: Int = 0,
        lastCompletedDate: String? = nil,
        ratingStars: Int = 0,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.emoji = emoji
        self.subtitle = subtitle
        self.durationMinutesRange = durationMinutesRange
        precondition(minimumDurationMinutes > 0 && maximumDurationMinutes >= minimumDurationMinutes)
        self.minimumDurationMinutes = minimumDurationMinutes
        self.maximumDurationMinutes = maximumDurationMinutes
        self.timesCompleted = timesCompleted
        self.lastCompletedDate = lastCompletedDate
        self.ratingStars = ratingStars
        self.isFavorite = isFavorite
    }
    
    public static let sampleCalmExercises: [ExerciseItem] = [
        ExerciseItem(
            id: "watch-something-funny",
            title: "Watch Something Funny",
            category: .calm,
            emoji: "🎬",
            subtitle: "A quick way to reconnect with joy and shift your nervous system.",
            durationMinutesRange: "7–10 min",
            minimumDurationMinutes: 7,
            maximumDurationMinutes: 10,
            timesCompleted: 0
        ),
        ExerciseItem(
            id: "keep-photo-close",
            title: "Keep a Photo Close",
            category: .calm,
            emoji: "📷",
            subtitle: "Ground yourself with an image of someone you love.",
            durationMinutesRange: "1–2 min",
            minimumDurationMinutes: 1,
            maximumDurationMinutes: 2,
            timesCompleted: 0
        )
    ]
    
    public static let sampleAcceptedExercises: [ExerciseItem] = [
        ExerciseItem(id: "belonging-list", title: "Make a Belonging List", category: .accepted, emoji: "🫂", subtitle: "Notice the people, places, and communities where you feel you belong.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        ExerciseItem(id: "share-something-small", title: "Share Something Small", category: .accepted, emoji: "💬", subtitle: "Share a small thought or appreciation with someone you trust.", durationMinutesRange: "2–5 min", minimumDurationMinutes: 2, maximumDurationMinutes: 5)
    ]

    public static let sampleResonantExercises: [ExerciseItem] = [
        ExerciseItem(
            id: "mirror-emotion",
            title: "Mirror the Emotion",
            category: .resonant,
            emoji: "🎭",
            subtitle: "Gently mirror expressions and notice any shift in your mood.",
            durationMinutesRange: "2–4 min",
            minimumDurationMinutes: 2,
            maximumDurationMinutes: 4
        ),
        ExerciseItem(
            id: "mirror-loved-one",
            title: "Mirror Someone You Love",
            category: .resonant,
            emoji: "📷",
            subtitle: "Mirror a loved one’s expressions and notice what shifts in you.",
            durationMinutesRange: "2–5 min",
            minimumDurationMinutes: 2,
            maximumDurationMinutes: 5
        )
    ]

    public static let sampleEnergeticExercises: [ExerciseItem] = [
        ExerciseItem(id: "share-something-new", title: "Share Something New", category: .energetic, emoji: "✨", subtitle: "Send a new discovery to someone who might enjoy it.", durationMinutesRange: "2–5 min", minimumDurationMinutes: 2, maximumDurationMinutes: 5),
        ExerciseItem(id: "connection-countdown", title: "Connection Countdown", category: .energetic, emoji: "⏳", subtitle: "Look forward to a small moment with someone you care about.", durationMinutesRange: "1–3 min", minimumDurationMinutes: 1, maximumDurationMinutes: 3)
    ]

    public static var allExercises: [ExerciseItem] {
        sampleCalmExercises + sampleAcceptedExercises + sampleResonantExercises + sampleEnergeticExercises
    }
}

public struct ExerciseProgressRecord: Codable, Equatable {
    public var completionDates: [Date] = []
    public var completionTokens: [UUID]? = nil
    public var rating: Int = 0
    public var isFavorite: Bool = false
}

/// Sorts the static catalog against persisted activity. Equal keys preserve catalog order.
public enum ExerciseSortEngine {
    public static func sorted(_ items: [ExerciseItem], by option: ExerciseSortOption,
                              records: [String: ExerciseProgressRecord]) -> [ExerciseItem] {
        items.enumerated().sorted { left, right in
            let a = left.element
            let b = right.element
            let activityA = records[a.id] ?? .init()
            let activityB = records[b.id] ?? .init()
            switch option {
            case .mostRecentlyCompleted:
                let aDate = activityA.completionDates.max() ?? .distantPast
                let bDate = activityB.completionDates.max() ?? .distantPast
                if aDate != bDate { return aDate > bDate }
            case .numberOfTimesCompleted:
                let aCount = activityA.completionDates.count
                let bCount = activityB.completionDates.count
                if aCount != bCount { return aCount > bCount }
            case .highestRated:
                if activityA.rating != activityB.rating { return activityA.rating > activityB.rating }
            case .longestDuration:
                if a.maximumDurationMinutes != b.maximumDurationMinutes { return a.maximumDurationMinutes > b.maximumDurationMinutes }
            case .shortestDuration:
                if a.minimumDurationMinutes != b.minimumDurationMinutes { return a.minimumDurationMinutes < b.minimumDurationMinutes }
            }
            return left.offset < right.offset
        }.map(\.element)
    }
}

@Observable
@MainActor
public final class ExerciseProgressStore {
    private static let storageKey = "care.exerciseProgress.v1"
    public private(set) var records: [String: ExerciseProgressRecord]
    public private(set) var storageError: String?

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.sharedStore = nil
        if let data = defaults.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode([String: ExerciseProgressRecord].self, from: data) {
            records = decoded
        } else {
            records = [:]
        }
    }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let sharedStore: UserDraftStore?

    public init(sharedStore: UserDraftStore) {
        self.defaults = .standard
        self.sharedStore = sharedStore
        self.records = (try? sharedStore.loadValue([String: ExerciseProgressRecord].self, key: "exercise-progress")) ?? [:]
    }

    public func record(for id: String) -> ExerciseProgressRecord { records[id] ?? .init() }

    public func complete(_ id: String, at date: Date = .now) {
        records[id, default: .init()].completionDates.append(date)
        persist()
    }

    public func completeAndDiscard(_ id: String, at date: Date = .now) throws {
        guard let sharedStore else {
            complete(id, at: date)
            return
        }
        records = try sharedStore.finishExercise(id, at: date)
    }

    public func setRating(_ rating: Int, for id: String) {
        var next = records
        next[id, default: .init()].rating = min(max(rating, 0), 5)
        commit(next)
    }

    public func toggleFavorite(_ id: String) {
        var next = records
        next[id, default: .init()].isFavorite.toggle()
        commit(next)
    }

    public func clearAll() throws {
        if let sharedStore { try sharedStore.removeValue(key: "exercise-progress") }
        else { defaults.removeObject(forKey: Self.storageKey) }
        records = [:]
        storageError = nil
    }

    public func resetAfterErasure() {
        records = [:]
        storageError = nil
    }

    public func completionCount(for category: ExerciseCategory? = nil) -> Int {
        matchingDates(for: category).count
    }

    public func weekCompletionCount(for category: ExerciseCategory? = nil, now: Date = .now, calendar: Calendar = .current) -> Int {
        guard let monday = monday(for: now, calendar: calendar),
              let nextMonday = calendar.date(byAdding: .day, value: 7, to: monday) else { return 0 }
        return matchingDates(for: category).filter { $0 >= monday && $0 < nextMonday }.count
    }

    public func weekCompletedDays(for category: ExerciseCategory? = nil, now: Date = .now, calendar: Calendar = .current) -> Int {
        let days = Set(matchingDates(for: category).map { calendar.startOfDay(for: $0) })
        guard let monday = monday(for: now, calendar: calendar),
              let nextMonday = calendar.date(byAdding: .day, value: 7, to: monday) else { return 0 }
        return days.filter { $0 >= monday && $0 < nextMonday }.count
    }

    public func currentStreak(for category: ExerciseCategory? = nil, now: Date = .now, calendar: Calendar = .current) -> Int {
        let days = Set(matchingDates(for: category).map { calendar.startOfDay(for: $0) })
        var day = calendar.startOfDay(for: now)
        if !days.contains(day), let yesterday = calendar.date(byAdding: .day, value: -1, to: day) { day = yesterday }
        var count = 0
        while days.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    public func weekStatuses(now: Date = .now, calendar: Calendar = .current) -> [Bool] {
        guard let monday = monday(for: now, calendar: calendar) else { return Array(repeating: false, count: 7) }
        let days = Set(matchingDates(for: nil).map { calendar.startOfDay(for: $0) })
        return (0..<7).map { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else { return false }
            return days.contains(calendar.startOfDay(for: date))
        }
    }

    private func monday(for date: Date, calendar: Calendar) -> Date? {
        let daysSinceMonday = (calendar.component(.weekday, from: date) + 5) % 7
        return calendar.date(byAdding: .day, value: -daysSinceMonday, to: calendar.startOfDay(for: date))
    }

    private func matchingDates(for category: ExerciseCategory?) -> [Date] {
        let ids = ExerciseItem.allExercises.filter { category == nil || $0.category == category }.map(\.id)
        return ids.flatMap { records[$0]?.completionDates ?? [] }
    }

    private func persist() {
        if let sharedStore {
            try? sharedStore.saveValue(records, key: "exercise-progress")
            return
        }
        guard let data = try? JSONEncoder().encode(records) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }

    private func commit(_ next: [String: ExerciseProgressRecord]) {
        do {
            if let sharedStore { try sharedStore.saveValue(next, key: "exercise-progress") }
            else { defaults.set(try JSONEncoder().encode(next), forKey: Self.storageKey) }
            records = next
            storageError = nil
        } catch { storageError = "Your exercise change could not be saved. Please try again." }
    }
}

// Drafts share the app's SwiftData container with contacts and completed assessments.
// An exercise draft contains references to Photos assets, never picker temporary URLs.
public struct ExerciseDraft: Codable, Equatable, Sendable {
    public let exerciseID: String
    public var completionToken: UUID? = nil
    public var step: Int = 0
    public var fields: [String: String] = [:]
    public var photoAssetID: String?
    public var videoAssetID: String?
    public var webURL: String?

    public init(exerciseID: String) { self.exerciseID = exerciseID }
}

public struct QuizDraft: Codable, Equatable, Sendable {
    public let topicSlug: EducationTopicSlug
    public var questionIDs: [String]
    public var questionIndex: Int
    public var selectedOptionLetter: String?
    public var hasSubmitted: Bool
    public var score: Int
    /// Completed choices keyed by stable question ID, including earlier editable steps.
    public var answeredLetters: [String: String]

    public init(topicSlug: EducationTopicSlug, questionIDs: [String], questionIndex: Int = 0, selectedOptionLetter: String? = nil, hasSubmitted: Bool = false, score: Int = 0, answeredLetters: [String: String] = [:]) {
        self.topicSlug = topicSlug
        self.questionIDs = questionIDs
        self.questionIndex = questionIndex
        self.selectedOptionLetter = selectedOptionLetter
        self.hasSubmitted = hasSubmitted
        self.score = score
        self.answeredLetters = answeredLetters
    }

    private enum CodingKeys: String, CodingKey {
        case topicSlug, questionIDs, questionIndex, selectedOptionLetter, hasSubmitted, score, answeredLetters
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        topicSlug = try values.decode(EducationTopicSlug.self, forKey: .topicSlug)
        questionIDs = try values.decode([String].self, forKey: .questionIDs)
        questionIndex = try values.decode(Int.self, forKey: .questionIndex)
        selectedOptionLetter = try values.decodeIfPresent(String.self, forKey: .selectedOptionLetter)
        hasSubmitted = try values.decode(Bool.self, forKey: .hasSubmitted)
        score = try values.decode(Int.self, forKey: .score)
        answeredLetters = try values.decodeIfPresent([String: String].self, forKey: .answeredLetters) ?? [:]
    }
}

public enum AssessmentDailyLimitError: LocalizedError, Equatable {
    case alreadyCompletedToday

    public var errorDescription: String? {
        "You already completed an assessment today. You can start another tomorrow."
    }
}

@Model
public final class StoredUserDraft {
    public var key: String = ""
    public var payload: Data = Data()
    public var updatedAt: Date = Date()

    public init(key: String, payload: Data, updatedAt: Date = .now) {
        self.key = key
        self.payload = payload
        self.updatedAt = updatedAt
    }
}

@Observable
@MainActor
public final class UserDraftStore {
    @ObservationIgnored private let container: ModelContainer
    public private(set) var exerciseDrafts: [String: ExerciseDraft] = [:]
    public private(set) var quizDrafts: [EducationTopicSlug: QuizDraft] = [:]
    public private(set) var mostRecentExerciseID: String?
    public private(set) var mostRecentQuizSlug: EducationTopicSlug?
    public private(set) var failedExerciseSaves: Set<String> = []
    public private(set) var failedQuizSaves: Set<EducationTopicSlug> = []
    public private(set) var unreadableDraftKeys: Set<String> = []

    public init(container: ModelContainer, migrateLegacyPhotos: Bool = true) throws {
        self.container = container
        let records = try container.mainContext.fetch(FetchDescriptor<StoredUserDraft>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]))
        for record in records {
            if record.key.hasPrefix("exercise:") {
                if let draft = try? JSONDecoder().decode(ExerciseDraft.self, from: record.payload) {
                    exerciseDrafts[draft.exerciseID] = draft
                    if mostRecentExerciseID == nil { mostRecentExerciseID = draft.exerciseID }
                } else { unreadableDraftKeys.insert(record.key) }
            } else if record.key.hasPrefix("quiz:") {
                if let draft = try? JSONDecoder().decode(QuizDraft.self, from: record.payload) {
                    quizDrafts[draft.topicSlug] = draft
                    if mostRecentQuizSlug == nil { mostRecentQuizSlug = draft.topicSlug }
                } else { unreadableDraftKeys.insert(record.key) }
            } else if record.key == "assessment-draft",
                      (try? JSONDecoder().decode(AssessmentSessionState.self, from: record.payload)) == nil {
                unreadableDraftKeys.insert(record.key)
            } else if record.key == "profile-edit",
                      (try? JSONDecoder().decode(ProfileEditDraft.self, from: record.payload)) == nil {
                unreadableDraftKeys.insert(record.key)
            } else if record.key.hasPrefix("contact-edit:"),
                      (try? JSONDecoder().decode(ContactEditDraft.self, from: record.payload)) == nil {
                unreadableDraftKeys.insert(record.key)
            }
        }
        if migrateLegacyPhotos { try migrateLegacyContactPhotos() }
    }

    private static let legacyPhotoPrefix = "care.contact.photo."

    private static func legacyPhotoKeys() -> [String] {
        UserDefaults.standard.dictionaryRepresentation().keys.filter { $0.hasPrefix(legacyPhotoPrefix) }
    }

    private func migrateLegacyContactPhotos() throws {
        let contacts = try container.mainContext.fetch(FetchDescriptor<StoredContact>())
        let validIDs = Set(contacts.map { $0.id.uuidString })
        for key in Self.legacyPhotoKeys() {
            let suffix = String(key.dropFirst(Self.legacyPhotoPrefix.count))
            guard validIDs.contains(suffix), let data = UserDefaults.standard.data(forKey: key) else {
                UserDefaults.standard.removeObject(forKey: key)
                continue
            }
            let destination = "contact-photo:\(suffix)"
            if try loadValue(Data.self, key: destination) == nil {
                let compact = ProfilePhotoProcessor.compactJPEG(data) ?? data
                try saveValue(compact, key: destination)
            }
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    private static func removeLegacyContactPhotos() {
        for key in legacyPhotoKeys() { UserDefaults.standard.removeObject(forKey: key) }
    }

    public func exercise(for id: String) -> ExerciseDraft? { exerciseDrafts[id] }
    public func quiz(for slug: EducationTopicSlug) -> QuizDraft? { quizDrafts[slug] }

    public func saveExercise(_ draft: ExerciseDraft) throws {
        guard !unreadableDraftKeys.contains("exercise:\(draft.exerciseID)") else {
            throw CocoaError(.fileReadCorruptFile)
        }
        var stableDraft = draft
        stableDraft.completionToken = exerciseDrafts[draft.exerciseID]?.completionToken ?? draft.completionToken ?? UUID()
        do { try save(key: "exercise:\(draft.exerciseID)", payload: JSONEncoder().encode(stableDraft)) }
        catch { failedExerciseSaves.insert(draft.exerciseID); throw error }
        failedExerciseSaves.remove(draft.exerciseID)
        exerciseDrafts[draft.exerciseID] = stableDraft
        mostRecentExerciseID = draft.exerciseID
    }

    public func saveQuiz(_ draft: QuizDraft) throws {
        guard !unreadableDraftKeys.contains("quiz:\(draft.topicSlug.rawValue)") else {
            throw CocoaError(.fileReadCorruptFile)
        }
        do { try save(key: "quiz:\(draft.topicSlug.rawValue)", payload: JSONEncoder().encode(draft)) }
        catch { failedQuizSaves.insert(draft.topicSlug); throw error }
        failedQuizSaves.remove(draft.topicSlug)
        quizDrafts[draft.topicSlug] = draft
        mostRecentQuizSlug = draft.topicSlug
    }

    public func discardExercise(_ id: String) throws {
        try remove(key: "exercise:\(id)")
        exerciseDrafts.removeValue(forKey: id)
        unreadableDraftKeys.remove("exercise:\(id)")
        failedExerciseSaves.remove(id)
        if mostRecentExerciseID == id { mostRecentExerciseID = exerciseDrafts.keys.sorted().first }
    }

    public func discardQuiz(for slug: EducationTopicSlug) throws {
        try remove(key: "quiz:\(slug.rawValue)")
        quizDrafts.removeValue(forKey: slug)
        unreadableDraftKeys.remove("quiz:\(slug.rawValue)")
        failedQuizSaves.remove(slug)
        if mostRecentQuizSlug == slug { mostRecentQuizSlug = quizDrafts.keys.sorted { $0.rawValue < $1.rawValue }.first }
    }

    public func loadValue<T: Decodable>(_ type: T.Type, key: String) throws -> T? {
        let descriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == key })
        guard let record = try container.mainContext.fetch(descriptor).first else { return nil }
        return try JSONDecoder().decode(T.self, from: record.payload)
    }

    /// Validate canonical records before any view can treat a decode failure as empty data.
    /// The caller blocks startup on failure, preserving the original bytes for recovery.
    public func validateCanonicalRecords() throws {
        _ = try loadValue(ProfileSettingsStore.Saved.self, key: "care.profile.settings.v1")
        _ = try loadValue([Person].self, key: "assessment-selection")
        _ = try loadValue([ParticipantAllocation].self, key: "assessment-allocations")
        _ = try loadValue([String: ExerciseProgressRecord].self, key: "exercise-progress")
        _ = try loadValue([String: TopicProgressRecord].self, key: "education-progress")
        _ = try loadValue(Bool.self, key: "com.careapp.security.isAppLockEnabled")
    }

    public func saveValue<T: Encodable>(_ value: T, key: String) throws {
        guard !unreadableDraftKeys.contains(key) else { throw CocoaError(.fileReadCorruptFile) }
        try save(key: key, payload: JSONEncoder().encode(value))
    }

    public func saveValueAndRemoveDraft<T: Encodable>(_ value: T, key: String, draftKey: String) throws {
        guard !unreadableDraftKeys.contains(draftKey) else { throw CocoaError(.fileReadCorruptFile) }
        let context = container.mainContext
        let valueDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == key })
        let draftDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == draftKey })
        do {
            let payload = try JSONEncoder().encode(value)
            if let record = try context.fetch(valueDescriptor).first { record.payload = payload; record.updatedAt = .now }
            else { context.insert(StoredUserDraft(key: key, payload: payload)) }
            for draft in try context.fetch(draftDescriptor) { context.delete(draft) }
            try context.save()
        } catch { context.rollback(); throw error }
    }

    public func removeValue(key: String) throws {
        try remove(key: key)
        unreadableDraftKeys.remove(key)
    }

    public func clearAllDrafts() throws {
        for id in Array(exerciseDrafts.keys) { try discardExercise(id) }
        for slug in Array(quizDrafts.keys) { try discardQuiz(for: slug) }
        try removeValue(key: "assessment-draft")
    }

    /// Discard every unfinished assessment record in one durable transaction.
    public func discardAssessmentDraft() throws {
        let context = container.mainContext
        let keys: Set<String> = ["assessment-draft", "assessment-selection", "assessment-allocations"]
        do {
            for record in try context.fetch(FetchDescriptor<StoredUserDraft>()) where keys.contains(record.key) {
                context.delete(record)
            }
            try context.save()
            unreadableDraftKeys.subtract(keys)
        } catch { context.rollback(); throw error }
    }

    public func commitContact(_ person: Person, photoData: Data?, editDraftKey: String) throws {
        guard !unreadableDraftKeys.contains(editDraftKey) else { throw CocoaError(.fileReadCorruptFile) }
        let context = container.mainContext
        let contactID = person.id
        let photoKey = "contact-photo:\(contactID.uuidString)"
        let contactDescriptor = FetchDescriptor<StoredContact>(predicate: #Predicate { $0.id == contactID })
        let photoDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == photoKey })
        let editDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == editDraftKey })
        do {
            if let existing = try context.fetch(contactDescriptor).first {
                existing.name = person.name
                existing.initials = person.initials
                existing.categoryRaw = person.category.rawValue
                existing.customCategoryName = person.customCategoryName
            } else {
                let count = try context.fetchCount(FetchDescriptor<StoredContact>())
                guard count < StorageContainerFactory.maxContactsLimit else {
                    throw StorageLimitError.contactLimitExceeded(max: StorageContainerFactory.maxContactsLimit)
                }
                context.insert(StoredContact(from: person))
            }
            if let photoData {
                let payload = try JSONEncoder().encode(photoData)
                if let photo = try context.fetch(photoDescriptor).first { photo.payload = payload; photo.updatedAt = .now }
                else { context.insert(StoredUserDraft(key: photoKey, payload: payload)) }
            }
            for record in try context.fetch(editDescriptor) { context.delete(record) }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    public func deleteRelationships() throws {
        let context = container.mainContext
        do {
            for contact in try context.fetch(FetchDescriptor<StoredContact>()) { context.delete(contact) }
            for record in try context.fetch(FetchDescriptor<StoredUserDraft>()) {
                if record.key.hasPrefix("contact-photo:") || record.key.hasPrefix("contact-edit:") ||
                   ["assessment-selection", "assessment-allocations", "assessment-draft"].contains(record.key) {
                    context.delete(record)
                }
            }
            try context.save()
            Self.removeLegacyContactPhotos()
        } catch { context.rollback(); throw error }
    }

    public func deleteContact(id: UUID) throws {
        let context = container.mainContext
        let photoKey = "contact-photo:\(id.uuidString)"
        let editKey = "contact-edit:\(id.uuidString)"
        let descriptor = FetchDescriptor<StoredContact>(predicate: #Predicate { $0.id == id })
        do {
            for contact in try context.fetch(descriptor) { context.delete(contact) }
            for record in try context.fetch(FetchDescriptor<StoredUserDraft>()) {
                switch record.key {
                case photoKey, editKey:
                    context.delete(record)
                case "assessment-selection":
                    let remaining = try JSONDecoder().decode([Person].self, from: record.payload).filter { $0.id != id }
                    if remaining.isEmpty { context.delete(record) }
                    else { record.payload = try JSONEncoder().encode(remaining) }
                case "assessment-allocations":
                    let remaining = try JSONDecoder().decode([ParticipantAllocation].self, from: record.payload).filter { $0.id != id }
                    if remaining.isEmpty { context.delete(record) }
                    else { record.payload = try JSONEncoder().encode(remaining) }
                case "assessment-draft":
                    let assessment = try JSONDecoder().decode(AssessmentSessionState.self, from: record.payload)
                    if assessment.participants.contains(where: { $0.id == id }) { context.delete(record) }
                default: break
                }
            }
            try context.save()
            UserDefaults.standard.removeObject(forKey: Self.legacyPhotoPrefix + id.uuidString)
        } catch { context.rollback(); throw error }
    }

    public func hasCompletedAssessment(on date: Date = .now, calendar: Calendar = .current) throws -> Bool {
        let stored = try container.mainContext.fetch(FetchDescriptor<StoredAssessmentSession>())
        return stored.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    public func commitAssessmentResult(_ result: AssessmentResult, calendar: Calendar = .current) throws {
        let context = container.mainContext
        let resultID = result.id
        let duplicate = FetchDescriptor<StoredAssessmentSession>(predicate: #Predicate { $0.id == resultID })
        do {
            if try context.fetch(duplicate).isEmpty {
                let all = try context.fetch(FetchDescriptor<StoredAssessmentSession>())
                guard !all.contains(where: { calendar.isDate($0.date, inSameDayAs: result.timestamp) }) else {
                    throw AssessmentDailyLimitError.alreadyCompletedToday
                }
                context.insert(StoredAssessmentSession(from: result))
            }
            let keys = ["assessment-draft", "assessment-selection", "assessment-allocations"]
            for record in try context.fetch(FetchDescriptor<StoredUserDraft>()) where keys.contains(record.key) {
                context.delete(record)
            }
            try context.save()
        } catch { context.rollback(); throw error }
    }

    public func deleteAssessments() throws {
        let context = container.mainContext
        do {
            for result in try context.fetch(FetchDescriptor<StoredAssessmentSession>()) { context.delete(result) }
            let keys = ["assessment-draft", "assessment-selection", "assessment-allocations"]
            for record in try context.fetch(FetchDescriptor<StoredUserDraft>()) where keys.contains(record.key) { context.delete(record) }
            try context.save()
        } catch { context.rollback(); throw error }
    }

    public func eraseAllUserData() throws {
        let context = container.mainContext
        do {
            for contact in try context.fetch(FetchDescriptor<StoredContact>()) { context.delete(contact) }
            for result in try context.fetch(FetchDescriptor<StoredAssessmentSession>()) { context.delete(result) }
            for record in try context.fetch(FetchDescriptor<StoredUserDraft>()) { context.delete(record) }
            try context.save()
            Self.removeLegacyContactPhotos()
            exerciseDrafts = [:]
            quizDrafts = [:]
            unreadableDraftKeys = []
            mostRecentExerciseID = nil
            mostRecentQuizSlug = nil
        } catch { context.rollback(); throw error }
    }

    public func finishExercise(_ id: String, at date: Date = .now) throws -> [String: ExerciseProgressRecord] {
        let context = container.mainContext
        let draftKey = "exercise:\(id)"
        let progressKey = "exercise-progress"
        let draftDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == draftKey })
        let progressDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == progressKey })
        do {
            guard let draftRecord = try context.fetch(draftDescriptor).first else {
                throw CocoaError(.fileNoSuchFile)
            }
            let draft = try JSONDecoder().decode(ExerciseDraft.self, from: draftRecord.payload)
            let progressRecord = try context.fetch(progressDescriptor).first
            var all = try progressRecord.map { try JSONDecoder().decode([String: ExerciseProgressRecord].self, from: $0.payload) } ?? [:]
            var progress = all[id] ?? .init()
            let token = draft.completionToken ?? UUID()
            if !(progress.completionTokens ?? []).contains(token) {
                progress.completionDates.append(date)
                progress.completionTokens = (progress.completionTokens ?? []) + [token]
                all[id] = progress
            }
            let payload = try JSONEncoder().encode(all)
            if let progressRecord { progressRecord.payload = payload; progressRecord.updatedAt = .now }
            else { context.insert(StoredUserDraft(key: progressKey, payload: payload)) }
            context.delete(draftRecord)
            try context.save()
            exerciseDrafts.removeValue(forKey: id)
            if mostRecentExerciseID == id { mostRecentExerciseID = exerciseDrafts.keys.sorted().first }
            return all
        } catch {
            context.rollback()
            throw error
        }
    }

    public func finishQuiz(slug: EducationTopicSlug, score: Int, totalQuestions: Int, at date: Date = .now) throws {
        let context = container.mainContext
        let draftKey = "quiz:\(slug.rawValue)"
        let progressKey = "education-progress"
        let draftDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == draftKey })
        let progressDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == progressKey })
        do {
            guard let draft = try context.fetch(draftDescriptor).first else { throw CocoaError(.fileNoSuchFile) }
            let progressRecord = try context.fetch(progressDescriptor).first
            var all = try progressRecord.map { try JSONDecoder().decode([String: TopicProgressRecord].self, from: $0.payload) } ?? [:]
            var record = all[slug.rawValue] ?? TopicProgressRecord(slug: slug)
            record.quizAttemptsCount += 1
            record.lastScore = score
            record.bestScore = max(record.bestScore, score)
            if score == totalQuestions && totalQuestions > 0 {
                record.quizPassed = true
                record.quizPassedAt = date
                record.isCompleted = true
                if record.completedAt == nil { record.completedAt = date }
            }
            all[slug.rawValue] = record
            let payload = try JSONEncoder().encode(all)
            if let progressRecord { progressRecord.payload = payload; progressRecord.updatedAt = date }
            else { context.insert(StoredUserDraft(key: progressKey, payload: payload, updatedAt: date)) }
            context.delete(draft)
            try context.save()
            quizDrafts.removeValue(forKey: slug)
            if mostRecentQuizSlug == slug { mostRecentQuizSlug = quizDrafts.keys.sorted { $0.rawValue < $1.rawValue }.first }
        } catch {
            context.rollback()
            throw error
        }
    }

    private func save(key: String, payload: Data) throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == key })
        do {
            if let record = try context.fetch(descriptor).first {
                record.payload = payload
                record.updatedAt = .now
            } else {
                context.insert(StoredUserDraft(key: key, payload: payload))
            }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    private func remove(key: String) throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == key })
        do {
            for record in try context.fetch(descriptor) { context.delete(record) }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

@MainActor
public enum ExercisePhotoReference {
    public static func loadImage(assetID: String) async -> UIImage? {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        guard status == .authorized || status == .limited else { return nil }
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil).firstObject else { return nil }
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 1200, height: 1200),
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                if info?[PHImageResultIsDegradedKey] as? Bool == true { return }
                continuation.resume(returning: image)
            }
        }
    }

    public static func loadVideoPlayer(assetID: String) async -> AVPlayer? {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        guard status == .authorized || status == .limited else { return nil }
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil).firstObject else { return nil }
        let video: AVAsset? = await withCheckedContinuation { continuation in
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { video, _, _ in
                continuation.resume(returning: video)
            }
        }
        guard let video else { return nil }
        return AVPlayer(playerItem: AVPlayerItem(asset: video))
    }
}
