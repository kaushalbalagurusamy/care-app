import Foundation
import UIKit

@MainActor
public enum ProfilePhotoProcessor {
    public static func compactJPEG(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let scale = min(1, 512 / max(image.size.width, image.size.height))
        let size = CGSize(width: max(1, image.size.width * scale), height: max(1, image.size.height * scale))
        let renderer = UIGraphicsImageRenderer(size: size)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: size)) }
        return resized.jpegData(compressionQuality: 0.75)
    }
}

public struct ProfileEditDraft: Codable, Equatable {
    public var name: String
    public var frequency: String
    public var photoData: Data?
}

@Observable
@MainActor
public final class ProfileSettingsStore {
    private static let key = "care.profile.settings.v1"

    struct Saved: Codable {
        var name: String = ""
        var frequency: String = "biweekly"
        var photoData: Data? = nil
        var completedSetup: Bool = false
    }

    private var saved: Saved
    @ObservationIgnored private let sharedStore: UserDraftStore?
    public var name: String { saved.name }
    public var frequency: String { saved.frequency }
    public var photoData: Data? { saved.photoData }
    public var completedSetup: Bool { saved.completedSetup }

    public init(sharedStore: UserDraftStore? = nil) {
        self.sharedStore = sharedStore
        if let sharedStore, let stored = try? sharedStore.loadValue(Saved.self, key: Self.key) {
            saved = stored
        } else if !ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("--uitesting-") }),
                  let data = UserDefaults.standard.data(forKey: Self.key),
                  let decoded = try? JSONDecoder().decode(Saved.self, from: data) {
            var migrated = decoded
            if let photo = decoded.photoData { migrated.photoData = ProfilePhotoProcessor.compactJPEG(photo) ?? photo }
            saved = migrated
            if let sharedStore, (try? sharedStore.saveValue(migrated, key: Self.key)) != nil {
                UserDefaults.standard.removeObject(forKey: Self.key)
            }
        } else { saved = Saved() }
    }

    public func save(name: String, frequency: String, photoData: Data?) throws {
        var next = saved
        next.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        next.frequency = frequency
        next.photoData = photoData
        next.completedSetup = true
        try persist(next, clearEditDraft: true)
    }

    public func skipSetup() throws {
        var next = saved
        next.frequency = "biweekly"
        next.completedSetup = true
        try persist(next)
    }

    public func clearProfile() throws {
        try persist(Saved(completedSetup: saved.completedSetup), clearEditDraft: true)
    }

    public func clearAll() throws {
        try persist(Saved(), clearEditDraft: true)
    }

    public func resetAfterErasure() { saved = Saved() }

    private func persist(_ next: Saved, clearEditDraft: Bool = false) throws {
        if let sharedStore {
            if clearEditDraft { try sharedStore.saveValueAndRemoveDraft(next, key: Self.key, draftKey: "profile-edit") }
            else { try sharedStore.saveValue(next, key: Self.key) }
        }
        else { UserDefaults.standard.set(try JSONEncoder().encode(next), forKey: Self.key) }
        saved = next
    }
}
