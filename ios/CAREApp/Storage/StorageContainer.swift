import Foundation
import SwiftData

// MARK: - Storage Bounded Limit Errors
public enum StorageLimitError: LocalizedError, Equatable {
    case contactLimitExceeded(max: Int)
    
    public var errorDescription: String? {
        switch self {
        case .contactLimitExceeded(let max):
            return "Contact limit reached (maximum \(max) contacts). Please remove unused contacts to add more."
        }
    }
}

// MARK: - SwiftData Storage Container Factory
public enum StorageContainerFactory {
    public static let schema = Schema([
        StoredContact.self,
        StoredAssessmentSession.self,
        StoredParticipantResult.self,
        StoredUserDraft.self
    ])
    
    public static let maxContactsLimit: Int = 50
    
    /// Create the local production container. CloudKit remains disabled in AppEnvironment.live.
    public static func createLiveContainer(enableCloudKit: Bool = false) throws -> ModelContainer {
        let config: ModelConfiguration
        if enableCloudKit {
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false,
                                        cloudKitDatabase: .private("iCloud.com.careapp.CAREApp"))
        } else {
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }
        return try ModelContainer(for: schema, configurations: [config])
    }
    
    /// Create in-memory container for unit tests & SwiftUI Previews
    public static func createInMemoryContainer() -> ModelContainer {
        do {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Fatal: Unable to create in-memory ModelContainer: \(error)")
        }
    }
}
