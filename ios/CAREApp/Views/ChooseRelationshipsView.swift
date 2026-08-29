import SwiftUI

// MARK: - Screen 5: Choose Relationships View (Figma Frame 17:4)
public struct ChooseRelationshipsView: View {
    public let router: AppRouter
    @Binding public var selectedPeople: [Person]
    @Environment(AppEnvironment.self) private var appEnvironment
    
    @State private var availablePeople: [Person] = Person.mockRolodex
    @State private var isShowingAddPersonSheet: Bool = false
    @State private var newPersonFirstName: String = ""
    @State private var newPersonLastName: String = ""
    @State private var newPersonCategory: RelationshipCategory = .partner
    @State private var customCategoryText: String = ""
    @State private var newPersonAgeText: String = "30"
    
    public init(router: AppRouter, selectedPeople: Binding<[Person]>) {
        self.router = router
        self._selectedPeople = selectedPeople
    }
    
    private var isSelectionFull: Bool {
        selectedPeople.count >= 5
    }
    
    private var isAddPersonFormValid: Bool {
        let trimmedFirst = newPersonFirstName.trimmingCharacters(in: .whitespaces)
        guard !trimmedFirst.isEmpty else { return false }
        if newPersonCategory == .custom {
            return !customCategoryText.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return true
    }
    
    private func resetAddPersonForm() {
        newPersonFirstName = ""
        newPersonLastName = ""
        newPersonCategory = .partner
        customCategoryText = ""
        newPersonAgeText = "30"
        isShowingAddPersonSheet = false
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HeaderNavBar()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Title Section
                    Text("Choose Relationships")
                        .font(Theme.Typography.poppins(.bold, size: 30))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, 8)
                    
                    // "+ Add Person" Outlined Action Button (Figma Frame 17:4)
                    Button(action: {
                        isShowingAddPersonSheet = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .bold))
                            
                            Text("Add Person")
                                .font(Theme.Typography.poppins(.semiBold, size: 16))
                        }
                        .foregroundColor(Theme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Theme.Colors.primary, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Chosen Relationship Cards (Figma Frame 17:4)
                    VStack(spacing: 12) {
                        ForEach(availablePeople) { person in
                            HStack(spacing: 16) {
                                // Pure White Circular Initials Badge
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Text(person.initials)
                                            .font(Theme.Typography.poppins(.bold, size: 17))
                                            .foregroundColor(Theme.Colors.primary)
                                    )
                                
                                // Name and Category/Age
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(person.name)
                                        .font(Theme.Typography.poppins(.bold, size: 17))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    
                                    Text("\(person.category.rawValue), \(person.age)")
                                        .font(Theme.Typography.poppins(.regular, size: 14))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.Colors.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                    
                    // Action Button (Matching Figma Frame 5 "Next")
                    Button(action: {
                        router.navigate(to: .relationshipFrequency)
                    }) {
                        Text("Next")
                            .font(Theme.Typography.poppins(.semiBold, size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Theme.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Theme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if let loaded = try? await appEnvironment.contactsRepo.fetchContacts(), !loaded.isEmpty {
                availablePeople = loaded
            }
            if selectedPeople.isEmpty {
                selectedPeople = Array(availablePeople.prefix(5))
            }
        }
        .sheet(isPresented: $isShowingAddPersonSheet) {
            NavigationStack {
                Form {
                    Section("Contact Information") {
                        TextField("First Name", text: $newPersonFirstName)
                            .textContentType(.givenName)
                            .autocorrectionDisabled()
                        
                        TextField("Last Name", text: $newPersonLastName)
                            .textContentType(.familyName)
                            .autocorrectionDisabled()
                        
                        Picker("Relationship", selection: $newPersonCategory) {
                            ForEach(RelationshipCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        
                        if newPersonCategory == .custom {
                            TextField("Custom Relationship (e.g. Mentor)", text: $customCategoryText)
                                .autocorrectionDisabled()
                        }
                        
                        TextField("Age", text: $newPersonAgeText)
                            .keyboardType(.numberPad)
                    }
                }
                .navigationTitle("Add Relationship")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            resetAddPersonForm()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let trimmedFirst = newPersonFirstName.trimmingCharacters(in: .whitespaces)
                            let trimmedLast = newPersonLastName.trimmingCharacters(in: .whitespaces)
                            guard !trimmedFirst.isEmpty else { return }
                            
                            let fullName = trimmedLast.isEmpty ? trimmedFirst : "\(trimmedFirst) \(trimmedLast)"
                            let firstInitial = trimmedFirst.first.map { String($0) } ?? ""
                            let lastInitial = trimmedLast.first.map { String($0) } ?? ""
                            let initials = (firstInitial + lastInitial).uppercased()
                            
                            let customName = (newPersonCategory == .custom) ? customCategoryText.trimmingCharacters(in: .whitespaces) : nil
                            let age = Int(newPersonAgeText.filter { $0.isNumber }) ?? 30
                            
                            let person = Person(
                                name: fullName,
                                initials: initials.isEmpty ? "CO" : initials,
                                category: newPersonCategory,
                                customCategoryName: customName,
                                age: age
                            )
                            
                            Task {
                                _ = try? await appEnvironment.contactsRepo.createContact(person)
                                if let refreshed = try? await appEnvironment.contactsRepo.fetchContacts() {
                                    availablePeople = refreshed
                                }
                            }
                            resetAddPersonForm()
                        }
                        .disabled(!isAddPersonFormValid)
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Previews
#Preview("Choose Relationships View") {
    struct PreviewWrapper: View {
        @State var selected: [Person] = Array(Person.mockFigmaContacts.prefix(3))
        var body: some View {
            ChooseRelationshipsView(router: AppRouter(), selectedPeople: $selected)
        }
    }
    return PreviewWrapper()
}
