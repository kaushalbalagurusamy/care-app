import SwiftUI
import PhotosUI

struct ContactEditDraft: Codable, Equatable {
    var contactID: UUID?
    var name: String
    var relationshipText: String
    var photoData: Data?

    static func isValidName(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func makePerson() -> Person? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.isValidName(trimmedName) else { return nil }
        let initials = trimmedName.split(separator: " ").compactMap { $0.first.map(String.init) }.joined().uppercased()
        let relationship = relationshipText.trimmingCharacters(in: .whitespacesAndNewlines)
        let category: RelationshipCategory = switch relationship {
        case "Partner": .partner
        case "Friend": .friend
        case "Sibling": .sibling
        case "Parent / Guardian": .parent
        case "Coworker": .colleague
        case "Cousin": .extendedFamily
        default: .custom
        }
        return Person(id: contactID ?? UUID(), name: trimmedName,
                      initials: initials.isEmpty ? "C" : initials,
                      category: category,
                      customCategoryName: relationship.isEmpty ? nil : relationship)
    }

    enum CodingKeys: String, CodingKey { case contactID, name, relationshipText, relationshipType, photoData }
    init(contactID: UUID?, name: String, relationshipText: String, photoData: Data?) {
        self.contactID = contactID
        self.name = name
        self.relationshipText = relationshipText
        self.photoData = photoData
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        contactID = try values.decodeIfPresent(UUID.self, forKey: .contactID)
        name = try values.decode(String.self, forKey: .name)
        let previous = try values.decodeIfPresent(String.self, forKey: .relationshipType)
        relationshipText = try values.decodeIfPresent(String.self, forKey: .relationshipText)
            ?? (previous == "Other Relative" ? "Other" : previous ?? "")
        photoData = try values.decodeIfPresent(Data.self, forKey: .photoData)
    }
    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encodeIfPresent(contactID, forKey: .contactID)
        try values.encode(name, forKey: .name)
        try values.encode(relationshipText, forKey: .relationshipText)
        try values.encodeIfPresent(photoData, forKey: .photoData)
    }
}

// MARK: - Screen: Add Relationship (Figma Frame 281:4 & Node 239:8)
public struct AddRelationshipView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(AppEnvironment.self) private var environment: AppEnvironment?
    
    @State private var fullName: String = ""
    @State private var relationshipText: String = ""
    @State private var showCancelConfirmation: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var photoSelection: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var existingPerson: Person?
    @State private var errorMessage: String?
    @State private var draftLoaded = false
    @State private var newContactID = UUID()
    public let editingContactID: UUID?
    public let onChanged: () -> Void
    public let onDeleted: (UUID) -> Void
    
    public init(editingContactID: UUID? = nil, onChanged: @escaping () -> Void = {}, onDeleted: @escaping (UUID) -> Void = { _ in }) {
        self.editingContactID = editingContactID
        self.onChanged = onChanged
        self.onDeleted = onDeleted
    }
    
    private var hasUnsavedEdits: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !relationshipText.isEmpty || photoData != nil
    }

    private var draftKey: String { "contact-edit:\(editingContactID?.uuidString ?? "new")" }
    private var draftSnapshot: ContactEditDraft {
        ContactEditDraft(contactID: editingContactID ?? newContactID, name: fullName, relationshipText: relationshipText, photoData: photoData)
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderNavBar(
                    showBackButton: true,
                    showHomeButton: true,
                    showChartButton: true,
                    showProfileButton: true,
                    onBack: { handleBackOrCancel() }
                )
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Title Section
                        VStack(alignment: .leading, spacing: 4) {
                        Text(editingContactID == nil ? "Add Relationship" : "Edit Contact Information")
                                .font(Theme.Typography.poppins(.bold, size: 28))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Text(editingContactID == nil ? "Add someone you'd like to reflect on in your C.A.R.E. assessment." : "Update your relationship details.")
                                .font(Theme.Typography.screenSubtitle)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .lineSpacing(2)
                        }
                        .padding(.top, Theme.Spacing.headerTitleSpacing)
                        
                        // Photo Upload Trigger (Dashed Circle)
                        PhotosPicker(selection: $photoSelection, matching: .images) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                    .foregroundColor(Theme.Colors.primary.opacity(0.8))
                                    .frame(width: 80, height: 80)
                                
                                if let photoData, let image = UIImage(data: photoData) {
                                    Image(uiImage: image).resizable().scaledToFill()
                                        .frame(width: 76, height: 76).clipShape(Circle())
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Theme.Colors.primary.opacity(0.7))
                                }
                                
                                ZStack {
                                    Circle()
                                        .fill(Theme.Colors.primary)
                                        .frame(width: 24, height: 24)
                                    Image(systemName: "plus")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: 28, y: 28)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(photoData == nil ? "Upload Photo" : "Change Photo")
                                    .font(Theme.Typography.poppins(.semiBold, size: 15))
                                    .foregroundColor(Theme.Colors.primary)
                                
                                Text("An avatar helps personalize your relational journey.")
                                    .font(Theme.Typography.poppins(.regular, size: 12.5))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .lineSpacing(2)
                            }
                        }
                        .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        
                        // Form Fields
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Full Name")
                                .font(Theme.Typography.poppins(.semiBold, size: 14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            TextField("e.g., Alex Johnson", text: $fullName)
                                .accessibilityIdentifier("RelationshipNameField")
                                .font(Theme.Typography.poppins(.regular, size: 15))
                                .padding(.horizontal, 16)
                                .frame(height: 52)
                                .background(Color(hex: "#F1F5F9"))
                                .cornerRadius(14)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Relationship to You (Optional)")
                                .font(Theme.Typography.poppins(.semiBold, size: 14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            TextField("e.g., Friend", text: $relationshipText)
                                .accessibilityIdentifier("RelationshipToYouField")
                                .font(Theme.Typography.poppins(.regular, size: 15))
                                .padding(.horizontal, 16)
                                .frame(height: 52)
                                .background(Color(hex: "#F1F5F9"))
                                .cornerRadius(14)
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                
                // Pinned Bottom Actions
                VStack(spacing: 8) {
                    PrimaryButton(
                        title: "Save Relationship",
                        isEnabled: ContactEditDraft.isValidName(fullName),
                        action: {
                            saveRelationship()
                        }
                    )

                    if editingContactID != nil {
                        Button { showDeleteConfirmation = true } label: {
                            Text("Delete Contact")
                                .font(Theme.Typography.poppins(.semiBold, size: 15))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity).frame(height: 46)
                                .overlay(Capsule().stroke(.red, lineWidth: 1.5))
                        }
                    }
                    
                    Button(action: {
                        handleBackOrCancel()
                    }) {
                        Text("Cancel")
                            .font(Theme.Typography.poppins(.medium, size: 15))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white.ignoresSafeArea(edges: .bottom))
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            
            // Cancel Changes Modal
            if showCancelConfirmation {
                CancelChangesConfirmationView(
                    onKeepEditing: {
                        showCancelConfirmation = false
                    },
                    onCancelWithoutSaving: {
                        do { try environment?.draftStore.removeValue(key: draftKey) }
                        catch { errorMessage = "Your draft could not be discarded. Please try again."; return }
                        showCancelConfirmation = false
                        router?.pop()
                    }
                )
                .transition(.opacity)
            }
            if showDeleteConfirmation {
                ZStack {
                    Color.black.opacity(0.18).ignoresSafeArea()
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Delete contact?")
                            .font(Theme.Typography.poppins(.bold, size: 20))
                        Text("Are you sure you want to delete this contact information? This cannot be undone.")
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundStyle(Theme.Colors.textSecondary)
                        PrimaryButton(title: "Keep Contact") { showDeleteConfirmation = false }
                        Button("Delete Contact", role: .destructive) { deleteContact() }
                            .font(Theme.Typography.poppins(.semiBold, size: 16))
                            .frame(maxWidth: .infinity).frame(height: 44)
                    }
                    .padding(22).frame(maxWidth: 350)
                    .background(RoundedRectangle(cornerRadius: 28).fill(Color(hex: "#FAFAFA")))
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showCancelConfirmation)
        .task {
            if let editingContactID,
               let people = try? await environment?.contactsRepo.fetchContacts(),
               let person = people.first(where: { $0.id == editingContactID }) {
                existingPerson = person
                fullName = person.name
                relationshipText = Self.typeName(for: person)
                let key = "contact-photo:\(editingContactID.uuidString)"
                photoData = try? environment?.draftStore.loadValue(Data.self, key: key)
                if photoData == nil, let legacy = UserDefaults.standard.data(forKey: "care.contact.photo.\(editingContactID.uuidString)") {
                    let compact = ProfilePhotoProcessor.compactJPEG(legacy) ?? legacy
                    if (try? environment?.draftStore.saveValue(compact, key: key)) != nil {
                        photoData = compact
                        UserDefaults.standard.removeObject(forKey: "care.contact.photo.\(editingContactID.uuidString)")
                    }
                }
            }
            if let draft = try? environment?.draftStore.loadValue(ContactEditDraft.self, key: draftKey) {
                if editingContactID == nil, let id = draft.contactID { newContactID = id }
                fullName = draft.name
                relationshipText = draft.relationshipText
                photoData = draft.photoData
            }
            draftLoaded = true
        }
        .onChange(of: draftSnapshot) { _, draft in
            guard draftLoaded else { return }
            do { try environment?.draftStore.saveValue(draft, key: draftKey) }
            catch { errorMessage = "Your relationship edits could not be saved. Please try again before leaving." }
        }
        .onChange(of: photoSelection) { _, selection in
            Task {
                guard let data = try? await selection?.loadTransferable(type: Data.self) else { return }
                photoData = ProfilePhotoProcessor.compactJPEG(data)
            }
        }
        .alert("Could not save contact", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }
    
    private func handleBackOrCancel() {
        showCancelConfirmation = true
    }
    
    private func saveRelationship() {
        guard let newPerson = draftSnapshot.makePerson() else { return }
        
        Task { @MainActor in
            do {
                guard let environment else { throw CocoaError(.fileNoSuchFile) }
                try environment.draftStore.commitContact(newPerson, photoData: photoData, editDraftKey: draftKey)
                onChanged()
                router?.pop()
            } catch { errorMessage = error.localizedDescription }
        }
    }

    private func deleteContact() {
        guard let editingContactID else { return }
        Task { @MainActor in
            do {
                try environment?.draftStore.deleteContact(id: editingContactID)
                try environment?.draftStore.removeValue(key: draftKey)
                UserDefaults.standard.removeObject(forKey: "care.contact.photo.\(editingContactID.uuidString)")
                onDeleted(editingContactID)
                onChanged()
                router?.pop()
            } catch { errorMessage = error.localizedDescription }
        }
    }

    private static func typeName(for person: Person) -> String {
        if let custom = person.customCategoryName, !custom.isEmpty { return custom == "Other Relative" ? "Other" : custom }
        return switch person.category {
        case .partner: "Partner"
        case .parent: "Parent / Guardian"
        case .sibling: "Sibling"
        case .friend: "Friend"
        case .colleague: "Coworker"
        case .extendedFamily: "Other"
        case .custom: person.customCategoryName ?? ""
        }
    }
}

#Preview {
    AddRelationshipView()
}
