import Foundation
import SwiftData

// MARK: - SwiftData CloudKit-Compliant Persistent Contact Model
@Model
public final class StoredContact {
    public var id: UUID = UUID()
    public var name: String = ""
    public var initials: String = ""
    public var categoryRaw: String = "Partner"
    public var customCategoryName: String? = nil
    public var age: Int = 30
    public var createdAt: Date = Date()
    
    public init(
        id: UUID = UUID(),
        name: String = "",
        initials: String = "",
        categoryRaw: String = "Partner",
        customCategoryName: String? = nil,
        age: Int = 30,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.initials = initials
        self.categoryRaw = categoryRaw
        self.customCategoryName = customCategoryName
        self.age = age
        self.createdAt = createdAt
    }
    
    public convenience init(from person: Person) {
        self.init(
            id: person.id,
            name: person.name,
            initials: person.initials,
            categoryRaw: person.category.rawValue,
            customCategoryName: person.customCategoryName,
            age: person.age
        )
    }
    
    public func toDomain() -> Person {
        let category = RelationshipCategory(rawValue: categoryRaw) ?? .partner
        return Person(
            id: id,
            name: name,
            initials: initials,
            category: category,
            customCategoryName: customCategoryName,
            age: age
        )
    }
}
