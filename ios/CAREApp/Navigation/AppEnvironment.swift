import SwiftUI
import SwiftData

// MARK: - Swift 6 Observable Application Dependency Injection Container
@Observable
@MainActor
public final class AppEnvironment {
    public let contactsRepo: any ContactsRepositoryProtocol
    public let assessmentRepo: any AssessmentRepositoryProtocol
    public let educationRepo: any EducationProgressRepositoryProtocol
    public let notificationScheduler: any NotificationSchedulerProtocol
    public let biometricService: any BiometricAuthServiceProtocol
    public let appLockManager: AppLockManager
    public let draftStore: UserDraftStore
    
    public init(
        contactsRepo: any ContactsRepositoryProtocol = MockContactsRepository(),
        assessmentRepo: any AssessmentRepositoryProtocol = MockAssessmentRepository(),
        educationRepo: any EducationProgressRepositoryProtocol = MockEducationProgressRepository(),
        notificationScheduler: any NotificationSchedulerProtocol = MockNotificationService(),
        biometricService: any BiometricAuthServiceProtocol = BiometricAuthService(),
        appLockManager: AppLockManager? = nil,
        draftStore: UserDraftStore? = nil
    ) {
        self.contactsRepo = contactsRepo
        self.assessmentRepo = assessmentRepo
        self.educationRepo = educationRepo
        self.notificationScheduler = notificationScheduler
        self.biometricService = biometricService
        self.draftStore = draftStore ?? (try! UserDraftStore(container: StorageContainerFactory.createInMemoryContainer()))
        self.appLockManager = appLockManager ?? AppLockManager(biometricService: biometricService, sharedStore: self.draftStore)
    }
    
    /// Pre-configured environment for SwiftUI previews & unit testing
    public static var preview: AppEnvironment {
        let mockBio = MockBiometricAuthService(shouldSucceed: true)
        return AppEnvironment(
            contactsRepo: MockContactsRepository(),
            assessmentRepo: MockAssessmentRepository(),
            educationRepo: MockEducationProgressRepository(),
            notificationScheduler: MockNotificationService(),
            biometricService: mockBio,
            appLockManager: AppLockManager(biometricService: mockBio, initiallyLocked: false)
        )
    }

    public static func makeLive() throws -> AppEnvironment {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--uitesting-fresh") || arguments.contains("--uitesting-history") ||
            arguments.contains("--uitesting-assessment") || arguments.contains("--uitesting-final-assessment") ||
            arguments.contains("--uitesting-quiz") || arguments.contains("--uitesting-exercise") {
            return try makeIsolatedUITestEnvironment(
                withHistory: arguments.contains("--uitesting-history"),
                withAssessment: arguments.contains("--uitesting-assessment"),
                withFinalAssessment: arguments.contains("--uitesting-final-assessment"),
                withQuiz: arguments.contains("--uitesting-quiz"),
                withExercise: arguments.contains("--uitesting-exercise")
            )
        }
        PickedExerciseMovie.removeStaleTemporaryMovies()
        let container = try StorageContainerFactory.createLiveContainer(enableCloudKit: false)
        let repository = LocalDeviceRepository(modelContainer: container)
            let drafts = try UserDraftStore(container: container)
            try drafts.validateCanonicalRecords()
            if try drafts.loadValue([String: ExerciseProgressRecord].self, key: "exercise-progress") == nil,
               let legacy = UserDefaults.standard.data(forKey: "care.exerciseProgress.v1"),
               let records = try? JSONDecoder().decode([String: ExerciseProgressRecord].self, from: legacy) {
                try drafts.saveValue(records, key: "exercise-progress")
                UserDefaults.standard.removeObject(forKey: "care.exerciseProgress.v1")
            }
            if try drafts.loadValue([String: TopicProgressRecord].self, key: "education-progress") == nil,
               let legacy = UserDefaults.standard.data(forKey: "com.careapp.education_progress"),
               let records = try? JSONDecoder().decode([String: TopicProgressRecord].self, from: legacy) {
                try drafts.saveValue(records, key: "education-progress")
                UserDefaults.standard.removeObject(forKey: "com.careapp.education_progress")
            }
            return AppEnvironment(
                contactsRepo: repository,
                assessmentRepo: repository,
                educationRepo: SwiftDataEducationProgressRepository(store: drafts),
                notificationScheduler: NotificationService(),
                draftStore: drafts
            )
    }

    /// Explicit launch fixtures for simulator UI evaluations. Never used in a normal app launch.
    private static func makeIsolatedUITestEnvironment(withHistory: Bool, withAssessment: Bool, withFinalAssessment: Bool, withQuiz: Bool, withExercise: Bool) throws -> AppEnvironment {
        let container = StorageContainerFactory.createInMemoryContainer()
        let repository = LocalDeviceRepository(modelContainer: container)
        let drafts = try UserDraftStore(container: container, migrateLegacyPhotos: false)
        if withHistory || withAssessment || withFinalAssessment || withQuiz || withExercise {
            try ProfileSettingsStore(sharedStore: drafts).skipSetup()
        }
        if withHistory {
            let day = Calendar.current.startOfDay(for: .now)
            for (index, name, score) in [(2, "Alice History", 50.0), (1, "Bob History", 100.0)] {
                let person = Person(name: name, initials: String(name.prefix(1)), category: .friend)
                let participant = AssessmentParticipant(person: person)
                let individual = IndividualResult(
                    participant: participant,
                    normalizedScore: score / 1.25,
                    safetyTier: .healthy,
                    domainBreakdown: Dictionary(uniqueKeysWithValues: CAREDomain.allCases.map { ($0, score / 5) })
                )
                let scores = Dictionary(uniqueKeysWithValues: CAREDomain.allCases.map { domain in
                    (domain, DomainScoreBreakdown(domain: domain, earnedPoints: score, maxPossiblePoints: 125))
                })
                let result = AssessmentResult(
                    domainScores: scores,
                    safetyDistribution: RelationalSafetyDistribution(safePercentage: 1, moderatePercentage: 0, highRiskPercentage: 0),
                    individualResults: [individual],
                    timestamp: Calendar.current.date(byAdding: .day, value: -index, to: day)!
                )
                try drafts.commitAssessmentResult(result)
            }
        }
        if withAssessment || withFinalAssessment {
            let people = Person.mockFigmaContacts
            for person in people { try drafts.commitContact(person, photoData: nil, editDraftKey: "contact-edit:new") }
            let participants = people.map { AssessmentParticipant(person: $0) }
            let questions = SurveyQuestion.full20QuestionBank
            let answers: [UUID: [String: SurveyOption]]
            if withFinalAssessment {
                answers = Dictionary(uniqueKeysWithValues: people.map { person in
                    (person.id, Dictionary(uniqueKeysWithValues: questions.map { ($0.id, $0.options[0]) }))
                })
            } else {
                answers = [people[0].id: [questions[0].id: questions[0].options[0], questions[1].id: questions[1].options[0]]]
            }
            let session = AssessmentSessionState(participants: participants,
                                                 currentParticipantIndex: withFinalAssessment ? 4 : 0,
                                                 currentQuestionIndex: withFinalAssessment ? 19 : 1,
                                                 recordedAnswers: answers)
            try drafts.saveValue(session, key: "assessment-draft")
        }
        if withExercise {
            try drafts.saveExercise(ExerciseDraft(exerciseID: "watch-something-funny"))
            let people = Person.mockFigmaContacts
            let samplePhoto = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y9Z5gAAAABJRU5ErkJggg==")
            for (index, person) in people.enumerated() {
                try drafts.commitContact(person, photoData: index == 0 ? samplePhoto : nil, editDraftKey: "contact-edit:new")
            }
        }
        if withQuiz,
           let topic = try EducationManifestLoader.loadBundledManifest().first,
           let first = topic.quizBank.first {
            let questionIDs = Array(topic.quizBank.prefix(3)).map(\.id)
            let draft = QuizDraft(
                topicSlug: topic.slug,
                questionIDs: questionIDs,
                questionIndex: 1,
                score: 1,
                answeredLetters: [first.id: first.correctOptionLetter]
            )
            try drafts.saveQuiz(draft)
        }
        return AppEnvironment(
            contactsRepo: repository,
            assessmentRepo: repository,
            educationRepo: SwiftDataEducationProgressRepository(store: drafts),
            notificationScheduler: MockNotificationService(),
            draftStore: drafts
        )
    }
}
