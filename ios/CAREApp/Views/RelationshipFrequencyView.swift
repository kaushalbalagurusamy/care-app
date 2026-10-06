import SwiftUI

// MARK: - Screen 6: Relationship Frequency Calibration (Figma Frame 41:4)
public struct RelationshipFrequencyView: View {
    public let router: AppRouter
    public let selectedPeople: [Person]
    @Binding public var allocations: [ParticipantAllocation]
    public let onProceed: ([AssessmentParticipant]) -> Bool
    
    public init(
        router: AppRouter,
        selectedPeople: [Person],
        allocations: Binding<[ParticipantAllocation]>,
        onProceed: @escaping ([AssessmentParticipant]) -> Bool
    ) {
        self.router = router
        self.selectedPeople = selectedPeople
        self._allocations = allocations
        self.onProceed = onProceed
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HeaderNavBar()
            
            VStack(alignment: .leading, spacing: 14) {
                // Title Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Choose Frequency")
                        .font(Theme.Typography.screenTitle)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("Drag the borders to estimate the percent time spent in each relationship.")
                        .font(Theme.Typography.poppins(.regular, size: 14))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(.top, Theme.Spacing.headerTitleSpacing)
                
                // 5-Person Vertical Partition Container (Takes flexible space in single screen)
                VerticalTimeAllocationBubble(allocations: $allocations)
                    .frame(maxHeight: .infinity)
            }
            .padding(.horizontal, 20)
            
            // Pinned Bottom Action Bar (Matching ProfileView)
            VStack(spacing: 0) {
                Divider()
                    .background(Theme.Colors.dividerSubtle)
                    
                    PrimaryButton(
                        title: "Next",
                        trailingIcon: "arrow.right",
                        isEnabled: AssessmentSessionState.canStart(with: selectedPeople.count) && allocations.count == AssessmentSessionState.requiredParticipantCount,
                        action: {
                            // Map allocations back to AssessmentParticipants
                            var participants: [AssessmentParticipant] = []
                            for alloc in allocations {
                                if let person = selectedPeople.first(where: { $0.id == alloc.id }) {
                                    participants.append(AssessmentParticipant(person: person, percentTimeSpent: alloc.percentage))
                                }
                            }
                            guard AssessmentSessionState.canStart(with: participants) else { return }
                            guard onProceed(participants) else { return }
                            router.navigate(to: .personTransition)
                        }
                    )
                    .accessibilityIdentifier("RelationshipFrequencyNextButton")
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                }
                .background(Theme.Colors.background)
            }
            .background(Theme.Colors.background)
            .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if Set(allocations.map(\.id)) != Set(selectedPeople.map(\.id)) {
                setupInitialAllocations()
            }
        }
    }
    
    private func setupInitialAllocations() {
        let initialPercentage = 1.0 / Double(max(selectedPeople.count, 1))
        allocations = selectedPeople.map { person in
            ParticipantAllocation(
                id: person.id,
                initials: person.initials,
                firstName: person.name.components(separatedBy: " ").first ?? person.name,
                percentage: initialPercentage
            )
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
                onProceed: { _ in true }
            )
        }
    }
    return PreviewWrapper()
}
