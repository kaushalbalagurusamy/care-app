import Testing
import SwiftUI
import SwiftData
@testable import CAREApp

@Suite("Phase 6.1: Repository Protocol Contracts & Dependency Injection Test Suite")
struct RepositoryTests {

    @Test("W01: a disk store with the previous contact schema opens without losing contacts")
    @MainActor
    func testPriorContactSchemaMigration() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("care-legacy-contact-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("care.sqlite")
        let id = UUID()
        let legacySchema = Schema([LegacyContactSchema.StoredContact.self])
        do {
            let legacyConfig = ModelConfiguration(schema: legacySchema, url: url, cloudKitDatabase: .none)
            let old = try ModelContainer(for: legacySchema, configurations: [legacyConfig])
            old.mainContext.insert(LegacyContactSchema.StoredContact(id: id, name: "Jordan", initials: "J", categoryRaw: "Friend", age: 31))
            try old.mainContext.save()
        }
        let config = ModelConfiguration(schema: StorageContainerFactory.schema, url: url, cloudKitDatabase: .none)
        let reopened = try ModelContainer(for: StorageContainerFactory.schema, configurations: [config])
        let contacts = try reopened.mainContext.fetch(FetchDescriptor<StoredContact>())
        #expect(contacts.count == 1)
        #expect(contacts.first?.id == id)
        #expect(contacts.first?.name == "Jordan")
        #expect(contacts.first?.toDomain().displayCategory == "Friend")
    }

    @Test("W01: prior profile record opens without age and keeps name, frequency and photo")
    @MainActor
    func testLegacyProfileWithoutAgeLoss() throws {
        let key = "care.profile.settings.v1"
        let previous = UserDefaults.standard.object(forKey: key)
        defer {
            if let previous { UserDefaults.standard.set(previous, forKey: key) }
            else { UserDefaults.standard.removeObject(forKey: key) }
        }
        let oldRecord = Data(#"{"name":"Jordan","age":"34","frequency":"monthly","photoData":"AQID","completedSetup":true}"#.utf8)
        UserDefaults.standard.set(oldRecord, forKey: key)
        let store = try UserDraftStore(container: StorageContainerFactory.createInMemoryContainer())
        let profile = ProfileSettingsStore(sharedStore: store)
        #expect(profile.name == "Jordan")
        #expect(profile.frequency == "monthly")
        #expect(profile.photoData == Data([1, 2, 3]))
        #expect(profile.completedSetup)
        #expect(UserDefaults.standard.data(forKey: key) == nil)
        let migrated = try #require(try store.loadValue(ProfileSettingsStore.Saved.self, key: key))
        let encoded = String(decoding: try JSONEncoder().encode(migrated), as: UTF8.self)
        #expect(!encoded.contains("age"))
    }

    @Test("W02: previous contact edit draft keeps its relationship and photo")
    func testLegacyContactDraftUpgrade() throws {
        let oldRecord = Data(#"{"contactID":"00000000-0000-0000-0000-000000000001","name":"Jordan","age":"31","relationshipType":"Other Relative","photoData":"AQID"}"#.utf8)
        let draft = try JSONDecoder().decode(ContactEditDraft.self, from: oldRecord)
        #expect(draft.name == "Jordan")
        #expect(draft.relationshipText == "Other")
        #expect(draft.photoData == Data([1, 2, 3]))
        let encoded = String(decoding: try JSONEncoder().encode(draft), as: UTF8.self)
        #expect(!encoded.contains("age"))
    }

    @Test("Legacy contact photos migrate into the shared store and erasure removes the old key")
    @MainActor
    func testLegacyContactPhotoMigrationAndErase() throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let person = Person(name: "Jordan", initials: "J", category: .friend)
        try UserDraftStore(container: container).commitContact(person, photoData: nil, editDraftKey: "contact-edit:new")
        let legacyKey = "care.contact.photo.\(person.id.uuidString)"
        UserDefaults.standard.set(Data([1, 2, 3]), forKey: legacyKey)
        defer { UserDefaults.standard.removeObject(forKey: legacyKey) }
        let reopened = try UserDraftStore(container: container)
        #expect(try reopened.loadValue(Data.self, key: "contact-photo:\(person.id.uuidString)") == Data([1, 2, 3]))
        #expect(UserDefaults.standard.data(forKey: legacyKey) == nil)
        UserDefaults.standard.set(Data([4]), forKey: legacyKey)
        try reopened.deleteRelationships()
        #expect(UserDefaults.standard.data(forKey: legacyKey) == nil)
    }

    @Test("Malformed exercise draft stays stored and is reported on reopen")
    @MainActor
    func testMalformedDraftIsNotSilentlyDiscarded() throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let store = try UserDraftStore(container: container)
        try store.saveValue(Data([0xFF]), key: "exercise:keep-photo-close")
        let reopened = try UserDraftStore(container: container)
        #expect(reopened.unreadableDraftKeys.contains("exercise:keep-photo-close"))
        #expect(try reopened.loadValue(Data.self, key: "exercise:keep-photo-close") == Data([0xFF]))
        #expect(throws: CocoaError.self) { try reopened.saveExercise(ExerciseDraft(exerciseID: "keep-photo-close")) }
        #expect(try reopened.loadValue(Data.self, key: "exercise:keep-photo-close") == Data([0xFF]))
    }

    @Test("Unreadable assessment draft cannot be replaced by a new session")
    @MainActor
    func testUnreadableAssessmentDraftPreserved() throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let store = try UserDraftStore(container: container)
        try store.saveValue(Data([0xFF]), key: "assessment-draft")
        let reopened = try UserDraftStore(container: container)
        #expect(reopened.unreadableDraftKeys.contains("assessment-draft"))
        #expect(throws: CocoaError.self) { try reopened.saveValue(AssessmentSessionState(), key: "assessment-draft") }
        #expect(try reopened.loadValue(Data.self, key: "assessment-draft") == Data([0xFF]))
    }

    @Test("A relaunched app removes only its abandoned exercise movie copies")
    @MainActor
    func testTemporaryExerciseMovieCleanup() throws {
        let directory = PickedExerciseMovie.temporaryMoviesDirectory
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let movie = directory.appendingPathComponent(UUID().uuidString + ".mov")
        let unrelated = directory.appendingPathComponent(UUID().uuidString + ".txt")
        try Data([1]).write(to: movie)
        try Data([2]).write(to: unrelated)
        defer { try? FileManager.default.removeItem(at: unrelated) }
        PickedExerciseMovie.removeStaleTemporaryMovies()
        #expect(!FileManager.default.fileExists(atPath: movie.path))
        #expect(FileManager.default.fileExists(atPath: unrelated.path))
    }

    @Test("App lock preference migrates to the shared store and clears with full erasure")
    @MainActor
    func testAppLockPreferenceStorage() throws {
        let key = "com.careapp.security.isAppLockEnabled"
        let prior = UserDefaults.standard.object(forKey: key)
        defer { if let prior { UserDefaults.standard.set(prior, forKey: key) } else { UserDefaults.standard.removeObject(forKey: key) } }
        UserDefaults.standard.set(true, forKey: key)
        let store = try UserDraftStore(container: StorageContainerFactory.createInMemoryContainer())
        let lock = AppLockManager(initiallyLocked: false, sharedStore: store)
        #expect(lock.isAppLockEnabled)
        #expect(try store.loadValue(Bool.self, key: key) == true)
        #expect(UserDefaults.standard.object(forKey: key) == nil)
        try store.eraseAllUserData()
        lock.resetAfterErasure()
        #expect(!lock.isAppLockEnabled)
        #expect(try store.loadValue(Bool.self, key: key) == nil)
    }

    @Test("Unreadable canonical records block startup without replacing their bytes")
    @MainActor
    func testCanonicalRecordPreflight() throws {
        for key in ["care.profile.settings.v1", "assessment-selection", "assessment-allocations",
                    "exercise-progress", "education-progress", "com.careapp.security.isAppLockEnabled"] {
            let store = try UserDraftStore(container: StorageContainerFactory.createInMemoryContainer())
            try store.saveValue(Data([0xFF]), key: key)
            #expect(throws: DecodingError.self) { try store.validateCanonicalRecords() }
            #expect(try store.loadValue(Data.self, key: key) == Data([0xFF]))
        }
    }

    @Test("A damaged app lock record fails closed")
    @MainActor
    func testDamagedAppLockFailsClosed() throws {
        let store = try UserDraftStore(container: StorageContainerFactory.createInMemoryContainer())
        try store.saveValue(Data([0xFF]), key: "com.careapp.security.isAppLockEnabled")
        let lock = AppLockManager(initiallyLocked: false, sharedStore: store)
        #expect(lock.isAppLockEnabled)
        #expect(lock.isLocked)
        #expect(lock.isShieldActive)
    }

    @Test("Unreadable profile and contact edits remain recoverable")
    @MainActor
    func testUnreadableFormDraftsCannotBeOverwritten() throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let store = try UserDraftStore(container: container)
        let contact = Person(name: "Jordan", initials: "J", category: .friend)
        let contactKey = "contact-edit:\(contact.id.uuidString)"
        try store.saveValue(Data([0xFF]), key: "profile-edit")
        try store.saveValue(Data([0xFE]), key: contactKey)
        let reopened = try UserDraftStore(container: container)
        #expect(reopened.unreadableDraftKeys.contains("profile-edit"))
        #expect(reopened.unreadableDraftKeys.contains(contactKey))
        #expect(throws: CocoaError.self) {
            try reopened.saveValueAndRemoveDraft("replacement", key: "care.profile.settings.v1", draftKey: "profile-edit")
        }
        #expect(throws: CocoaError.self) {
            try reopened.commitContact(contact, photoData: nil, editDraftKey: contactKey)
        }
        #expect(try reopened.loadValue(Data.self, key: "profile-edit") == Data([0xFF]))
        #expect(try reopened.loadValue(Data.self, key: contactKey) == Data([0xFE]))
    }

    @Test("User records and unfinished work survive closing and reopening the SQLite container")
    @MainActor
    func testPersistentContainerReopen() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("care-reopen-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let config = ModelConfiguration(schema: StorageContainerFactory.schema, url: directory.appendingPathComponent("care.sqlite"), cloudKitDatabase: .none)
        let person = Person(name: "Jordan", initials: "J", category: .friend)
        do {
            let container = try ModelContainer(for: StorageContainerFactory.schema, configurations: [config])
            let store = try UserDraftStore(container: container)
            try store.commitContact(person, photoData: Data([7]), editDraftKey: "contact-edit:new")
            try store.saveValue([person], key: "assessment-selection")
            try store.saveExercise(ExerciseDraft(exerciseID: "keep-photo-close"))
            try store.saveQuiz(QuizDraft(topicSlug: .relationalCulturalTheory, questionIDs: ["one"]))
        }
        let reopened = try ModelContainer(for: StorageContainerFactory.schema, configurations: [config])
        let store = try UserDraftStore(container: reopened)
        let contacts = try await LocalDeviceRepository(modelContainer: reopened).fetchContacts()
        #expect(contacts.map(\.id) == [person.id])
        #expect(try store.loadValue([Person].self, key: "assessment-selection")?.map(\.id) == [person.id])
        #expect(store.exercise(for: "keep-photo-close") != nil)
        #expect(store.quiz(for: .relationalCulturalTheory) != nil)
    }

    @Test("Contact retry updates one ID and commits its photo with draft removal")
    @MainActor
    func testAtomicContactSave() async throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let store = try UserDraftStore(container: container)
        let repo = LocalDeviceRepository(modelContainer: container)
        let person = Person(name: "Taylor", initials: "T", category: .friend)
        try store.saveValue("editing", key: "contact-edit:new")
        try store.commitContact(person, photoData: Data([1, 2, 3]), editDraftKey: "contact-edit:new")
        try store.commitContact(person, photoData: Data([4, 5]), editDraftKey: "contact-edit:new")
        #expect(try await repo.fetchContactCount() == 1)
        #expect(try store.loadValue(Data.self, key: "contact-photo:\(person.id.uuidString)") == Data([4, 5]))
        #expect(try store.loadValue(String.self, key: "contact-edit:new") == nil)
    }

    @Test("Deleting relationships removes contacts and dependent drafts in one store")
    @MainActor
    func testRelationshipErase() async throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let store = try UserDraftStore(container: container)
        let repo = LocalDeviceRepository(modelContainer: container)
        let person = Person(name: "Taylor", initials: "T", category: .friend)
        try store.commitContact(person, photoData: Data([1]), editDraftKey: "contact-edit:new")
        try store.saveValue([person], key: "assessment-selection")
        try store.saveValue("unfinished", key: "assessment-draft")
        try store.deleteRelationships()
        #expect(try await repo.fetchContactCount() == 0)
        #expect(try store.loadValue([Person].self, key: "assessment-selection") == nil)
        #expect(try store.loadValue(String.self, key: "assessment-draft") == nil)
        #expect(try store.loadValue(Data.self, key: "contact-photo:\(person.id.uuidString)") == nil)
    }

    @Test("Full erase removes every stored contact, result, progress and draft")
    @MainActor
    func testFullUserDataErase() async throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let store = try UserDraftStore(container: container)
        let repo = LocalDeviceRepository(modelContainer: container)
        try store.commitContact(Person(name: "Jordan", initials: "J", category: .friend), photoData: Data([1]), editDraftKey: "contact-edit:new")
        try store.commitAssessmentResult(.figmaMockResult)
        try store.saveExercise(ExerciseDraft(exerciseID: "keep-photo-close"))
        try store.saveQuiz(QuizDraft(topicSlug: .relationalCulturalTheory, questionIDs: ["one"]))
        try store.saveValue(["keep-photo-close": ExerciseProgressRecord()], key: "exercise-progress")
        try store.eraseAllUserData()
        #expect(try await repo.fetchContactCount() == 0)
        #expect(try await repo.fetchHistoryCount() == 0)
        #expect(store.exercise(for: "keep-photo-close") == nil)
        #expect(store.quiz(for: .relationalCulturalTheory) == nil)
        #expect(try store.loadValue([String: ExerciseProgressRecord].self, key: "exercise-progress") == nil)
    }

    @Test("Saving the same assessment ID twice creates one persisted result with its original maximum")
    @MainActor
    func testIdempotentAssessmentSave() async throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let repository = LocalDeviceRepository(modelContainer: container)
        let source = AssessmentResult.figmaMockResult
        try await repository.saveAssessmentResult(source)
        try await repository.saveAssessmentResult(source)
        #expect(try await repository.fetchHistoryCount() == 1)
        let restored = try #require(try await repository.fetchAssessmentHistory().first)
        #expect(restored.domainScores[.calm]?.maxPossiblePoints == 100)
    }

    @Test("Final assessment and draft removal commit together")
    @MainActor
    func testAtomicAssessmentSubmission() async throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let store = try UserDraftStore(container: container)
        let repository = LocalDeviceRepository(modelContainer: container)
        let result = AssessmentResult.figmaMockResult
        try store.saveValue("unfinished", key: "assessment-draft")
        try store.commitAssessmentResult(result)
        try store.commitAssessmentResult(result)
        #expect(try await repository.fetchHistoryCount() == 1)
        #expect(try store.loadValue(String.self, key: "assessment-draft") == nil)
    }
    
    @Test("TEST-REP-01: MockContactsRepository executes CRUD operations deterministically")
    func testContactsRepositoryCRUD() async throws {
        let initialContacts = [
            Person(name: "Sarah Mitchell", initials: "SM", category: .partner),
            Person(name: "James Cooper", initials: "JC", category: .family)
        ]
        let repo = MockContactsRepository(initialContacts: initialContacts)
        
        // 1. Fetch initial contacts
        let fetched = try await repo.fetchContacts()
        #expect(fetched.count == 2)
        #expect(try await repo.fetchContactCount() == 2)
        
        // 2. Create new contact
        let newContact = Person(name: "Alex Taylor", initials: "AT", category: .friend)
        _ = try await repo.createContact(newContact)
        #expect(try await repo.fetchContactCount() == 3)
        
        // 3. Delete contact
        try await repo.deleteContact(id: initialContacts[0].id)
        #expect(try await repo.fetchContactCount() == 2)
        
        let remaining = try await repo.fetchContacts()
        #expect(!remaining.contains(where: { $0.id == initialContacts[0].id }))
        #expect(remaining.contains(where: { $0.id == newContact.id }))
    }

    @Test("TEST-REP-02: MockAssessmentRepository saves and queries historical assessment results")
    func testAssessmentRepositoryHistory() async throws {
        let repo = MockAssessmentRepository(initialHistory: [])
        #expect(try await repo.fetchHistoryCount() == 0)
        
        // 1. Fetch question bank
        let questions = try await repo.fetchQuestionBank()
        #expect(questions.count >= 20)
        
        // 2. Save result
        let result = AssessmentResult.figmaMockResult
        try await repo.saveAssessmentResult(result)
        #expect(try await repo.fetchHistoryCount() == 1)
        
        // 3. Fetch history
        let history = try await repo.fetchAssessmentHistory()
        #expect(history.count == 1)
        #expect(history.first?.id == result.id)
        #expect(history.first?.individualResults.count == result.individualResults.count)
        #expect(history.first?.safetyDistribution.safePercentage == result.safetyDistribution.safePercentage)
        
        // 4. Delete result
        try await repo.deleteAssessmentResult(id: result.id)
        #expect(try await repo.fetchHistoryCount() == 0)
    }

    @Test("TEST-REP-03: AppEnvironment resolves protocol instances without retention cycles")
    @MainActor
    func testAppEnvironmentInjection() async throws {
        let environment = AppEnvironment(
            contactsRepo: MockContactsRepository(),
            assessmentRepo: MockAssessmentRepository()
        )
        
        let contactCount = try await environment.contactsRepo.fetchContactCount()
        #expect(contactCount > 0)
        
        let historyCount = try await environment.assessmentRepo.fetchHistoryCount()
        #expect(historyCount > 0)
    }
}

private enum LegacyContactSchema {
    @Model
    final class StoredContact {
        var id: UUID = UUID()
        var name: String = ""
        var initials: String = ""
        var categoryRaw: String = "Partner"
        var customCategoryName: String? = nil
        var age: Int = 30
        var createdAt: Date = Date()

        init(id: UUID, name: String, initials: String, categoryRaw: String, age: Int) {
            self.id = id
            self.name = name
            self.initials = initials
            self.categoryRaw = categoryRaw
            self.age = age
        }
    }
}
