import SwiftUI

// MARK: - Screen 6: Relationship Frequency Calibration (Figma Frame 41:4)
public struct RelationshipFrequencyView: View {
    public let router: AppRouter
    public let selectedPeople: [Person]
    @Binding public var allocations: [ParticipantAllocation]
    public let onProceed: ([AssessmentParticipant]) -> Void
    
    public init(
        router: AppRouter,
        selectedPeople: [Person],
        allocations: Binding<[ParticipantAllocation]>,
        onProceed: @escaping ([AssessmentParticipant]) -> Void
    ) {
        self.router = router
        self.selectedPeople = selectedPeople
        self._allocations = allocations
        self.onProceed = onProceed
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
            
            VStack(alignment: .leading, spacing: 14) {
                // Title Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Choose Frequency")
                        .font(Theme.Typography.poppins(.bold, size: 28))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("Drag the borders to estimate the percent time spent in each relationship.")
                        .font(Theme.Typography.poppins(.regular, size: 14))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(.top, 4)
                
                // 5-Person Vertical Partition Container (Takes flexible space in single screen)
                VerticalTimeAllocationBubble(allocations: $allocations)
                    .frame(maxHeight: .infinity)
                
                // Action Button
                Button(action: {
                    // Map allocations back to AssessmentParticipants
                    var participants: [AssessmentParticipant] = []
                    for alloc in allocations {
                        if let person = selectedPeople.first(where: { $0.id == alloc.id }) {
                            participants.append(AssessmentParticipant(person: person, percentTimeSpent: alloc.percentage))
                        } else {
                            // Fallback
                            let person = Person(name: alloc.firstName, initials: alloc.initials, category: .friend, age: 30)
                            participants.append(AssessmentParticipant(person: person, percentTimeSpent: alloc.percentage))
                        }
                    }
                    onProceed(participants)
                    router.navigate(to: .surveyQuestion)
                }) {
                    Text("Next")
                        .font(Theme.Typography.poppins(.semiBold, size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Theme.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 20)
        }
        .background(Theme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if allocations.isEmpty {
                setupInitialAllocations()
            }
        }
    }
    
    private func setupInitialAllocations() {
        let count = max(selectedPeople.count, 1)
        if count == 5 {
            // Default 80%, 5%, 5%, 5%, 5% (sum = 1.0)
            let defaultPcts = [0.80, 0.05, 0.05, 0.05, 0.05]
            allocations = selectedPeople.enumerated().map { index, person in
                ParticipantAllocation(
                    id: person.id,
                    initials: person.initials,
                    firstName: person.name.components(separatedBy: " ").first ?? person.name,
                    percentage: defaultPcts[index]
                )
            }
        } else if count > 1 {
            // First person starts with majority, others with 5%
            let othersPct = 0.05 * Double(count - 1)
            let firstPct = max(1.0 - othersPct, 0.05)
            allocations = selectedPeople.enumerated().map { index, person in
                ParticipantAllocation(
                    id: person.id,
                    initials: person.initials,
                    firstName: person.name.components(separatedBy: " ").first ?? person.name,
                    percentage: index == 0 ? firstPct : 0.05
                )
            }
        } else {
            allocations = selectedPeople.map { person in
                ParticipantAllocation(
                    id: person.id,
                    initials: person.initials,
                    firstName: person.name.components(separatedBy: " ").first ?? person.name,
                    percentage: 1.0
                )
            }
        }
    }
}

// MARK: - Previews
#Preview("Relationship Frequency View") {
    struct PreviewWrapper: View {
        @State var sampleAllocations = [
            ParticipantAllocation(initials: "SM", firstName: "Sarah", percentage: 0.30),
            ParticipantAllocation(initials: "JC", firstName: "James", percentage: 0.25),
            ParticipantAllocation(initials: "LC", firstName: "Linda", percentage: 0.20),
            ParticipantAllocation(initials: "DO", firstName: "David", percentage: 0.15),
            ParticipantAllocation(initials: "RS", firstName: "Rachel", percentage: 0.10)
        ]
        
        var body: some View {
            RelationshipFrequencyView(
                router: AppRouter(),
                selectedPeople: Person.mockFigmaContacts,
                allocations: $sampleAllocations,
                onProceed: { _ in }
            )
        }
    }
    return PreviewWrapper()
}
