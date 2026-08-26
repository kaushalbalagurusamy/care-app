import SwiftUI

// MARK: - Screen 5: Choose Relationships View (Figma Frame 17:4)
public struct ChooseRelationshipsView: View {
    public let router: AppRouter
    @Binding public var selectedPeople: [Person]
    
    private let availablePeople: [Person] = Person.mockRolodex
    
    public init(router: AppRouter, selectedPeople: Binding<[Person]>) {
        self.router = router
        self._selectedPeople = selectedPeople
    }
    
    private var isSelectionFull: Bool {
        selectedPeople.count >= 5
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showChartButton: true,
                showProfileButton: true,
                onBack: { router.pop() },
                onHome: { router.popToRoot() },
                onChart: { router.navigate(to: .pastResults) },
                onProfile: {}
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title Section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Choose Relationships")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Select up to 5 people you spend the most time with.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, 8)
                    
                    // Selection Counter Pill
                    HStack {
                        Spacer()
                        Text("\(selectedPeople.count) of 5 Selected")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.Colors.buttonSurfaceMuted)
                            .clipShape(Capsule())
                    }
                    
                    // Contact List
                    VStack(spacing: 12) {
                        ForEach(availablePeople) { person in
                            let isSelected = selectedPeople.contains(where: { $0.id == person.id })
                            
                            RelationshipSelectionPill(
                                initials: person.initials,
                                name: person.name,
                                subtitle: "\(person.category.rawValue), \(person.age)",
                                isSelected: isSelected,
                                onToggle: {
                                    if isSelected {
                                        selectedPeople.removeAll(where: { $0.id == person.id })
                                    } else if selectedPeople.count < 5 {
                                        selectedPeople.append(person)
                                    }
                                }
                            )
                        }
                    }
                    
                    // Action Button
                    PrimaryButton(
                        title: "Next",
                        isEnabled: selectedPeople.count >= 1
                    ) {
                        router.navigate(to: .relationshipFrequency)
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .background(Theme.Colors.background)
        .onAppear {
            if selectedPeople.isEmpty {
                // Pre-populate with first 5 Figma contacts if empty
                selectedPeople = Array(Person.mockFigmaContacts.prefix(5))
            }
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
