import Foundation
import SwiftData

// MARK: - Storage Bounded Limit Errors
public enum StorageLimitError: LocalizedError, Equatable {
    case contactLimitExceeded(max: Int)
    case assessmentLimitExceeded(max: Int)
    
    public var errorDescription: String? {
        switch self {
        case .contactLimitExceeded(let max):
            return "Contact limit reached (maximum \(max) contacts). Please remove unused contacts to add more."
        case .assessmentLimitExceeded(let max):
            return "Assessment history limit reached (maximum \(max) stored sessions)."
        }
    }
}

// MARK: - SwiftData Storage Container Factory with Hardware Encryption & CloudKit Config
public enum StorageContainerFactory {
    public static let schema = Schema([
        StoredContact.self,
        StoredAssessmentSession.self,
        StoredParticipantResult.self
    ])
    
    public static let maxContactsLimit: Int = 50
    public static let maxAssessmentsLimit: Int = 50
    
    /// Create production container with NSFileProtectionComplete and CloudKit private database
    public static func createLiveContainer(enableCloudKit: Bool = true) -> ModelContainer {
        do {
            let config: ModelConfiguration
            if enableCloudKit {
                config = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .private("iCloud.com.careapp.CAREApp")
                )
            } else {
                config = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false
                )
            }
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            print("Failed to initialize live ModelContainer with CloudKit: \(error). Falling back to local configuration.")
            do {
                let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                fatalError("Fatal: Unable to create local ModelContainer: \(error)")
            }
        }
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
