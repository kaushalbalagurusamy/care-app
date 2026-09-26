import Testing
import SwiftUI
@testable import CAREApp

@Suite("CARE Information & Relationship Management Test Suite")
struct CAREInformationAndContactsTests {
    
    @Test("CAREInformationView initializes with specified initial category")
    @MainActor
    func testCAREInformationViewInitialization() {
        let view = CAREInformationView(initialCategory: .calm)
        #expect(view.initialCategory == .calm)
    }
    
    @Test("AddRelationshipView initializes with all 12 relationship categories")
    @MainActor
    func testAddRelationshipViewDefaultInitialization() {
        let view = AddRelationshipView()
        #expect(view.relationshipTypes.count == 12)
        #expect(view.relationshipTypes.contains("Partner"))
        #expect(view.relationshipTypes.contains("Friend"))
        #expect(view.relationshipTypes.contains("Mentor / Teacher"))
    }
}
