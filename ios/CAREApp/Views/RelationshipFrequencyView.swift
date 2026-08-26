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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title Section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Choose Frequency")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Drag the borders to estimate the percent time spent in each relationship.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, 8)
                    
                    // 5-Person Vertical Partition Container
                    VerticalTimeAllocationBubble(allocations: $allocations)
                    
                    // Action Button
                    PrimaryButton(title: "Next") {
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
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .background(Theme.Colors.background)
        .onAppear {
            if allocations.isEmpty {
                setupInitialAllocations()
            }
        }
    }
    
    private func setupInitialAllocations() {
        let count = max(selectedPeople.count, 1)
        if count == 5 {
            // Default 30, 25, 20, 15, 10
            let defaultPcts = [0.30, 0.25, 0.20, 0.15, 0.10]
            allocations = selectedPeople.enumerated().map { index, person in
                ParticipantAllocation(
                    id: person.id,
                    initials: person.initials,
                    firstName: person.name.components(separatedBy: " ").first ?? person.name,
                    percentage: defaultPcts[index]
                )
            }
        } else {
            // Equal distribution
            let equalPct = (1.0 / Double(count) * 100).rounded() / 100
            allocations = selectedPeople.map { person in
                ParticipantAllocation(
                    id: person.id,
                    initials: person.initials,
                    firstName: person.name.components(separatedBy: " ").first ?? person.name,
                    percentage: equalPct
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
