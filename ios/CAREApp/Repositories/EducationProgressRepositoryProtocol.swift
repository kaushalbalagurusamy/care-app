import Foundation

// MARK: - Topic Progress Record
public struct TopicProgressRecord: Codable, Sendable, Equatable, Identifiable {
    public var id: String { slug.rawValue }
    public let slug: EducationTopicSlug
    public var isCompleted: Bool
    public var completedAt: Date?
    public var quizPassed: Bool
    public var quizPassedAt: Date?
    
    public init(
        slug: EducationTopicSlug,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        quizPassed: Bool = false,
        quizPassedAt: Date? = nil
    ) {
        self.slug = slug
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.quizPassed = quizPassed
        self.quizPassedAt = quizPassedAt
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
}
