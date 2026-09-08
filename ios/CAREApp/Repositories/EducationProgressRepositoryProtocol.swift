import Foundation

// MARK: - Topic Progress Record
public struct TopicProgressRecord: Codable, Sendable, Equatable, Identifiable {
    public var id: String { slug.rawValue }
    public let slug: EducationTopicSlug
    public var isCompleted: Bool
    public var completedAt: Date?
    public var quizPassed: Bool
    public var quizPassedAt: Date?
    public var usedQuestionIds: [String]
    public var quizAttemptsCount: Int
    public var bestScore: Int
    public var lastScore: Int
    
    public init(
        slug: EducationTopicSlug,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        quizPassed: Bool = false,
        quizPassedAt: Date? = nil,
        usedQuestionIds: [String] = [],
        quizAttemptsCount: Int = 0,
        bestScore: Int = 0,
        lastScore: Int = 0
    ) {
        self.slug = slug
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.quizPassed = quizPassed
        self.quizPassedAt = quizPassedAt
        self.usedQuestionIds = usedQuestionIds
        self.quizAttemptsCount = quizAttemptsCount
        self.bestScore = bestScore
        self.lastScore = lastScore
    }
    
    private enum CodingKeys: String, CodingKey {
        case slug, isCompleted, completedAt, quizPassed, quizPassedAt, usedQuestionIds, quizAttemptsCount, bestScore, lastScore
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.slug = try container.decode(EducationTopicSlug.self, forKey: .slug)
        self.isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        self.completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        self.quizPassed = try container.decodeIfPresent(Bool.self, forKey: .quizPassed) ?? false
        self.quizPassedAt = try container.decodeIfPresent(Date.self, forKey: .quizPassedAt)
        self.usedQuestionIds = try container.decodeIfPresent([String].self, forKey: .usedQuestionIds) ?? []
        self.quizAttemptsCount = try container.decodeIfPresent(Int.self, forKey: .quizAttemptsCount) ?? 0
        self.bestScore = try container.decodeIfPresent(Int.self, forKey: .bestScore) ?? 0
        self.lastScore = try container.decodeIfPresent(Int.self, forKey: .lastScore) ?? 0
    }
}

// MARK: - Quiz Session Payload
public struct QuizSessionPayload: Sendable, Equatable {
    public let questions: [QuizQuestion]
    public let wasPoolReset: Bool
    public let remainingInPoolAfterSession: Int
    
    public init(
        questions: [QuizQuestion],
        wasPoolReset: Bool,
        remainingInPoolAfterSession: Int
    ) {
        self.questions = questions
        self.wasPoolReset = wasPoolReset
        self.remainingInPoolAfterSession = remainingInPoolAfterSession
    }
}

// MARK: - Education Progress Repository Protocol (Sendable & Swift 6 Compliant)
public protocol EducationProgressRepositoryProtocol: Sendable {
    func fetchProgress(for slug: EducationTopicSlug) async throws -> TopicProgressRecord
    func fetchAllProgress() async throws -> [EducationTopicSlug: TopicProgressRecord]
    func markTopicCompleted(slug: EducationTopicSlug) async throws
    func recordQuizResult(slug: EducationTopicSlug, passed: Bool) async throws
    func resetProgress() async throws
    func completedTopicsCount() async throws -> Int
    
    // Quiz Cycling & Session Methods
    func fetchNextQuizSession(
        for topic: EducationTopic,
        count: Int,
        deterministicShuffleSeed: Int?
    ) async throws -> QuizSessionPayload
    
    func recordQuizSessionResult(
        slug: EducationTopicSlug,
        questionIds: [String],
        score: Int,
        totalQuestions: Int
    ) async throws
    
    func resetQuizPool(for slug: EducationTopicSlug) async throws
}

extension EducationProgressRepositoryProtocol {
    public func fetchNextQuizSession(
        for topic: EducationTopic,
        count: Int = 3
    ) async throws -> QuizSessionPayload {
        try await fetchNextQuizSession(for: topic, count: count, deterministicShuffleSeed: nil)
    }
}

// MARK: - Thread-Safe In-Memory Mock Education Progress Repository
public final class MockEducationProgressRepository: EducationProgressRepositoryProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var records: [EducationTopicSlug: TopicProgressRecord]
    
    public init(initialRecords: [EducationTopicSlug: TopicProgressRecord] = [:]) {
        self.records = initialRecords
    }
    
    public func fetchProgress(for slug: EducationTopicSlug) async throws -> TopicProgressRecord {
        lock.lock()
        defer { lock.unlock() }
        return records[slug] ?? TopicProgressRecord(slug: slug)
    }
    
    public func fetchAllProgress() async throws -> [EducationTopicSlug: TopicProgressRecord] {
        lock.lock()
        defer { lock.unlock() }
        return records
    }
    
    public func markTopicCompleted(slug: EducationTopicSlug) async throws {
        lock.lock()
        defer { lock.unlock() }
        var current = records[slug] ?? TopicProgressRecord(slug: slug)
        current.isCompleted = true
        current.completedAt = Date()
        records[slug] = current
    }
    
    public func recordQuizResult(slug: EducationTopicSlug, passed: Bool) async throws {
        lock.lock()
        defer { lock.unlock() }
        var current = records[slug] ?? TopicProgressRecord(slug: slug)
        if passed {
            current.quizPassed = true
            current.quizPassedAt = Date()
            current.isCompleted = true
            if current.completedAt == nil {
                current.completedAt = Date()
            }
        }
        records[slug] = current
    }
    
    public func resetProgress() async throws {
        lock.lock()
        defer { lock.unlock() }
        records.removeAll()
    }
    
    public func completedTopicsCount() async throws -> Int {
        lock.lock()
        defer { lock.unlock() }
        return records.values.filter { $0.isCompleted }.count
    }
    
    public func fetchNextQuizSession(
        for topic: EducationTopic,
        count: Int = 3,
        deterministicShuffleSeed: Int? = nil
    ) async throws -> QuizSessionPayload {
        lock.lock()
        defer { lock.unlock() }
        
        let allQuestions = topic.quizBank.isEmpty ? [topic.quiz] : topic.quizBank
        var current = records[topic.slug] ?? TopicProgressRecord(slug: topic.slug)
        let usedSet = Set(current.usedQuestionIds)
        var available = allQuestions.filter { !usedSet.contains($0.id) }
        var wasReset = false
        
        if available.count < count {
            current.usedQuestionIds = []
            available = allQuestions
            wasReset = true
        }
        
        let selected: [QuizQuestion]
        if deterministicShuffleSeed != nil {
            let sorted = available.sorted(by: { $0.id < $1.id })
            selected = Array(sorted.prefix(count))
        } else {
            selected = Array(available.shuffled().prefix(count))
        }
        
        let selectedIds = selected.map(\.id)
        current.usedQuestionIds.append(contentsOf: selectedIds)
        records[topic.slug] = current
        
        let remaining = max(0, allQuestions.count - current.usedQuestionIds.count)
        return QuizSessionPayload(
            questions: selected,
            wasPoolReset: wasReset,
            remainingInPoolAfterSession: remaining
        )
    }
    
    public func recordQuizSessionResult(
        slug: EducationTopicSlug,
        questionIds: [String],
        score: Int,
        totalQuestions: Int
    ) async throws {
        lock.lock()
        defer { lock.unlock() }
        var current = records[slug] ?? TopicProgressRecord(slug: slug)
        current.quizAttemptsCount += 1
        current.lastScore = score
        if score > current.bestScore {
            current.bestScore = score
        }
        let passed = Double(score) / Double(max(1, totalQuestions)) >= 0.6
        if passed {
            current.quizPassed = true
            current.quizPassedAt = Date()
            current.isCompleted = true
            if current.completedAt == nil {
                current.completedAt = Date()
            }
        }
        records[slug] = current
    }
    
    public func resetQuizPool(for slug: EducationTopicSlug) async throws {
        lock.lock()
        defer { lock.unlock() }
        var current = records[slug] ?? TopicProgressRecord(slug: slug)
        current.usedQuestionIds.removeAll()
        records[slug] = current
    }
}

// MARK: - Local UserDefaults-Backed Persistent Repository
public final class LocalEducationProgressRepository: EducationProgressRepositoryProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private let userDefaults: UserDefaults
    private let storageKey: String
    
    public init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "com.careapp.education_progress"
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }
    
    private func loadStoredMap() -> [EducationTopicSlug: TopicProgressRecord] {
        guard let data = userDefaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: TopicProgressRecord].self, from: data) else {
            return [:]
        }
        var map: [EducationTopicSlug: TopicProgressRecord] = [:]
        for (raw, record) in decoded {
            if let slug = EducationTopicSlug(rawValue: raw) {
                map[slug] = record
            }
        }
        return map
    }
    
    private func saveStoredMap(_ map: [EducationTopicSlug: TopicProgressRecord]) {
        var encodable: [String: TopicProgressRecord] = [:]
        for (slug, record) in map {
            encodable[slug.rawValue] = record
        }
        if let data = try? JSONEncoder().encode(encodable) {
            userDefaults.set(data, forKey: storageKey)
        }
    }
    
    public func fetchProgress(for slug: EducationTopicSlug) async throws -> TopicProgressRecord {
        lock.lock()
        defer { lock.unlock() }
        let map = loadStoredMap()
        return map[slug] ?? TopicProgressRecord(slug: slug)
    }
    
    public func fetchAllProgress() async throws -> [EducationTopicSlug: TopicProgressRecord] {
        lock.lock()
        defer { lock.unlock() }
        return loadStoredMap()
    }
    
    public func markTopicCompleted(slug: EducationTopicSlug) async throws {
        lock.lock()
        defer { lock.unlock() }
        var map = loadStoredMap()
        var record = map[slug] ?? TopicProgressRecord(slug: slug)
        record.isCompleted = true
        record.completedAt = Date()
        map[slug] = record
        saveStoredMap(map)
    }
    
    public func recordQuizResult(slug: EducationTopicSlug, passed: Bool) async throws {
        lock.lock()
        defer { lock.unlock() }
        var map = loadStoredMap()
        var record = map[slug] ?? TopicProgressRecord(slug: slug)
        if passed {
            record.quizPassed = true
            record.quizPassedAt = Date()
            record.isCompleted = true
            if record.completedAt == nil {
                record.completedAt = Date()
            }
        }
        map[slug] = record
        saveStoredMap(map)
    }
    
    public func resetProgress() async throws {
        lock.lock()
        defer { lock.unlock() }
        userDefaults.removeObject(forKey: storageKey)
    }
    
    public func completedTopicsCount() async throws -> Int {
        lock.lock()
        defer { lock.unlock() }
        let map = loadStoredMap()
        return map.values.filter { $0.isCompleted }.count
    }
    
    public func fetchNextQuizSession(
        for topic: EducationTopic,
        count: Int = 3,
        deterministicShuffleSeed: Int? = nil
    ) async throws -> QuizSessionPayload {
        lock.lock()
        defer { lock.unlock() }
        
        var map = loadStoredMap()
        let allQuestions = topic.quizBank.isEmpty ? [topic.quiz] : topic.quizBank
        var current = map[topic.slug] ?? TopicProgressRecord(slug: topic.slug)
        let usedSet = Set(current.usedQuestionIds)
        var available = allQuestions.filter { !usedSet.contains($0.id) }
        var wasReset = false
        
        if available.count < count {
            current.usedQuestionIds = []
            available = allQuestions
            wasReset = true
        }
        
        let selected: [QuizQuestion]
        if deterministicShuffleSeed != nil {
            let sorted = available.sorted(by: { $0.id < $1.id })
            selected = Array(sorted.prefix(count))
        } else {
            selected = Array(available.shuffled().prefix(count))
        }
        
        let selectedIds = selected.map(\.id)
        current.usedQuestionIds.append(contentsOf: selectedIds)
        map[topic.slug] = current
        saveStoredMap(map)
        
        let remaining = max(0, allQuestions.count - current.usedQuestionIds.count)
        return QuizSessionPayload(
            questions: selected,
            wasPoolReset: wasReset,
            remainingInPoolAfterSession: remaining
        )
    }
    
    public func recordQuizSessionResult(
        slug: EducationTopicSlug,
        questionIds: [String],
        score: Int,
        totalQuestions: Int
    ) async throws {
        lock.lock()
        defer { lock.unlock() }
        var map = loadStoredMap()
        var current = map[slug] ?? TopicProgressRecord(slug: slug)
        current.quizAttemptsCount += 1
        current.lastScore = score
        if score > current.bestScore {
            current.bestScore = score
        }
        let passed = Double(score) / Double(max(1, totalQuestions)) >= 0.6
        if passed {
            current.quizPassed = true
            current.quizPassedAt = Date()
            current.isCompleted = true
            if current.completedAt == nil {
                current.completedAt = Date()
            }
        }
        map[slug] = current
        saveStoredMap(map)
    }
    
    public func resetQuizPool(for slug: EducationTopicSlug) async throws {
        lock.lock()
        defer { lock.unlock() }
        var map = loadStoredMap()
        var current = map[slug] ?? TopicProgressRecord(slug: slug)
        current.usedQuestionIds.removeAll()
        map[slug] = current
        saveStoredMap(map)
    }
}
