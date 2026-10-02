import SwiftUI

// MARK: - Screen 5: Choose Relationships View (Figma Frame 17:4)
public struct ChooseRelationshipsView: View {
    public let router: AppRouter
    @Binding public var selectedPeople: [Person]
    public let refreshToken: Int
    @Environment(AppEnvironment.self) private var appEnvironment
    
    @State private var availablePeople: [Person] = []
    @State private var showSelectionLimit = false
    @State private var hasInitializedSelection = false
    @State private var autoSelectNewContacts = false
    
    public init(router: AppRouter, selectedPeople: Binding<[Person]>, refreshToken: Int = 0) {
        self.router = router
        self._selectedPeople = selectedPeople
        self.refreshToken = refreshToken
    }
    
    static func toggledSelection(_ selected: [Person], person: Person) -> [Person]? {
        if selected.contains(where: { $0.id == person.id }) {
            return selected.filter { $0.id != person.id }
        }
        guard selected.count < AssessmentSessionState.requiredParticipantCount else { return nil }
        return selected + [person]
    }

    static func initialSelection(contacts: [Person], previousIDs: [UUID]?, draft: [Person]) -> [Person] {
        let byID = Dictionary(uniqueKeysWithValues: contacts.map { ($0.id, $0) })
        if !draft.isEmpty { return draft.compactMap { byID[$0.id] } }
        if let previousIDs {
            return Array(previousIDs.compactMap { byID[$0] }.prefix(AssessmentSessionState.requiredParticipantCount))
        }
        return Array(contacts.prefix(AssessmentSessionState.requiredParticipantCount))
    }
    
    private func refreshContacts() async {
        guard let loaded = try? await appEnvironment.contactsRepo.fetchContacts() else { return }
        if !hasInitializedSelection {
            let history = try? await appEnvironment.assessmentRepo.fetchAssessmentHistory()
            let previousIDs = history?.first.map { $0.individualResults.map(\.id) }
            autoSelectNewContacts = previousIDs == nil && selectedPeople.isEmpty
            selectedPeople = Self.initialSelection(contacts: loaded, previousIDs: previousIDs, draft: selectedPeople)
            hasInitializedSelection = true
        } else if autoSelectNewContacts {
            selectedPeople = Array(loaded.prefix(AssessmentSessionState.requiredParticipantCount))
        } else {
            let byID = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
            selectedPeople = selectedPeople.compactMap { byID[$0.id] }
        }
        availablePeople = loaded
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HeaderNavBar()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Title Section (Figma Frame 17:4)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Choose Relationships")
                            .font(Theme.Typography.poppins(.bold, size: 28))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Add at least five people to start the assessment.")
                            .font(Theme.Typography.screenSubtitle)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // "+ Add Person" Outlined Action Button (Figma Frame 17:4)
                    Button(action: {
                        router.navigate(to: .addRelationship)
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
                    
                    HStack {
                        Text("Choose five")
                            .font(Theme.Typography.poppins(.semiBold, size: 16))
                        Spacer()
                        Text("\(selectedPeople.count)/5")
                            .font(Theme.Typography.poppins(.semiBold, size: 16))
                            .accessibilityIdentifier("SelectedRelationshipCount")
                    }
                    .foregroundStyle(Theme.Colors.textPrimary)

                    Text("Tap the five contacts you want to select. You can change your selection before continuing.")
                        .font(Theme.Typography.screenSubtitle)
                        .foregroundColor(Theme.Colors.textSecondary)

                    // Chosen Relationship Cards (Figma Frame 17:4)
                    VStack(spacing: 12) {
                        ForEach(availablePeople) { person in
                            let isSelected = selectedPeople.contains(where: { $0.id == person.id })
                            HStack(spacing: 16) {
                                Button {
                                    autoSelectNewContacts = false
                                    if let updated = Self.toggledSelection(selectedPeople, person: person) {
                                        selectedPeople = updated
                                    } else { showSelectionLimit = true }
                                } label: {
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
                                    .overlay {
                                        Circle().stroke(isSelected ? Theme.Colors.primary : Color.clear, lineWidth: 2)
                                    }
                                
                                // Name and optional relationship
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(person.name)
                                        .font(Theme.Typography.poppins(.bold, size: 17))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    
                                    if !person.displayCategory.isEmpty {
                                        Text(person.displayCategory)
                                            .font(Theme.Typography.poppins(.regular, size: 14))
                                            .foregroundColor(Theme.Colors.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                }
                                .padding(.leading, 16)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("\(isSelected ? "Deselect" : "Select") \(person.name)")
                                .accessibilityAddTraits(isSelected ? .isSelected : [])
                                Button {
                                    router.navigate(to: .editContact(person.id))
                                } label: {
                                    Image("icon_contact_edit")
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(Theme.Colors.primary)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Edit \(person.name)")
                                .padding(.trailing, 16)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "#E1EFFE"))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(isSelected ? Theme.Colors.primary : Theme.Colors.primary.opacity(0.28), lineWidth: isSelected ? 2 : 1)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Pinned Bottom Action Bar (Matching ProfileView)
            VStack(spacing: 0) {
                Divider()
                    .background(Theme.Colors.dividerSubtle)
                
                PrimaryButton(
                    title: "Next",
                    trailingIcon: "arrow.right",
                    isEnabled: AssessmentSessionState.canStart(with: selectedPeople.count),
                    action: {
                        router.navigate(to: .relationshipFrequency)
                    }
                )
                .accessibilityIdentifier("ChooseRelationshipsNextButton")
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 10)
            }
            .background(Theme.Colors.background)
        }
        .background(Theme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await refreshContacts()
        }
        .onChange(of: refreshToken) { _, _ in Task { await refreshContacts() } }
        .alert("Choose exactly five relationships", isPresented: $showSelectionLimit) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Deselect someone before adding another person to this assessment.")
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
