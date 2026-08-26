import Foundation

// MARK: - Relationship Category Enum
public enum RelationshipCategory: String, CaseIterable, Codable, Hashable {
    case partner = "Partner"
    case family = "Family"
    case friend = "Friend"
    case coworker = "Coworker"
    case brother = "Brother"
    case mother = "Mother"
    case custom = "Custom"
}

// MARK: - Persistent Person Entity (User Address Book)
public struct Person: Identifiable, Hashable, Codable {
    public let id: UUID
    public var name: String
    public var initials: String
    public var category: RelationshipCategory
    public var age: Int
    
    public init(
        id: UUID = UUID(),
        name: String,
        initials: String,
        category: RelationshipCategory,
        age: Int
    ) {
        self.id = id
        self.name = name
        self.initials = initials
        self.category = category
        self.age = age
    }
}

// MARK: - Mock Initial Rolodex (Matching Figma Screen 5)
public extension Person {
    static let mockFigmaContacts: [Person] = [
        Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32),
        Person(name: "James Cooper", initials: "JC", category: .friend, age: 28),
        Person(name: "Linda Chen", initials: "LC", category: .coworker, age: 41),
        Person(name: "David Okafor", initials: "DO", category: .brother, age: 35),
        Person(name: "Rachel Stein", initials: "RS", category: .mother, age: 58)
    ]
}
