import Foundation

// MARK: - Relationship Category Enum
public enum RelationshipCategory: String, CaseIterable, Codable, Hashable {
    case partner = "Partner"
    case friend = "Friend"
    case sibling = "Sibling"
    case parent = "Parent"
    case extendedFamily = "Extended Family"
    case colleague = "Colleague"
    case custom = "Custom"
    
    // Backwards-compatible aliases
    public static var coworker: RelationshipCategory { .colleague }
    public static var brother: RelationshipCategory { .sibling }
    public static var mother: RelationshipCategory { .parent }
    public static var family: RelationshipCategory { .extendedFamily }
}

// MARK: - Persistent Person Entity (User Address Book)
public struct Person: Identifiable, Hashable, Codable {
    public let id: UUID
    public var name: String
    public var initials: String
    public var category: RelationshipCategory
    public var customCategoryName: String?
    public var age: Int
    
    public var displayCategory: String {
        if category == .custom, let custom = customCategoryName, !custom.isEmpty {
            return custom
        }
        return category.rawValue
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        initials: String,
        category: RelationshipCategory,
        customCategoryName: String? = nil,
        age: Int
    ) {
        self.id = id
        self.name = name
        self.initials = initials
        self.category = category
        self.customCategoryName = customCategoryName
        self.age = age
    }
}

// MARK: - Mock Initial Rolodex (Matching Figma Screen 5)
public extension Person {
    static let mockFigmaContacts: [Person] = [
        Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32),
        Person(name: "James Cooper", initials: "JC", category: .friend, age: 28),
        Person(name: "Linda Chen", initials: "LC", category: .colleague, age: 41),
        Person(name: "David Okafor", initials: "DO", category: .sibling, age: 35),
        Person(name: "Rachel Stein", initials: "RS", category: .parent, age: 58)
    ]
    
    static let mockRolodex: [Person] = mockFigmaContacts
}
