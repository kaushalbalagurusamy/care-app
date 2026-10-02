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
    
    @Test("W02: name and optional free-text relationship replace category pills")
    @MainActor
    func testAddRelationshipViewDefaultInitialization() {
        let view = AddRelationshipView()
        #expect(view.editingContactID == nil)
        #expect(ContactEditDraft.isValidName("Jordan"))
    }
}
