import SwiftUI

// MARK: - Single Participant Allocation Item
public struct ParticipantAllocation: Identifiable, Equatable {
    public let id: UUID
    public let initials: String
    public let firstName: String
    public var percentage: Double // 0.05 to 0.80 (sum = 1.0)
    
    public init(id: UUID = UUID(), initials: String, firstName: String, percentage: Double) {
        self.id = id
        self.initials = initials
        self.firstName = firstName
        self.percentage = percentage
    }
}

// MARK: - Vertical Time Allocation Bubble (Figma Frame 41:4)
public struct VerticalTimeAllocationBubble: View {
    @Binding public var allocations: [ParticipantAllocation]
    @State private var dragInitialAllocations: [ParticipantAllocation]? = nil
    
    private let totalHeight: CGFloat = 560.0
    private let containerCornerRadius: CGFloat = 28.0
    private let minPercentage: Double = 0.05
    private let snapStep: Double = 0.05
    
    public init(allocations: Binding<[ParticipantAllocation]>) {
        self._allocations = allocations
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Background Container Box
            RoundedRectangle(cornerRadius: containerCornerRadius, style: .continuous)
                .fill(Theme.Colors.cardSurface)
                .frame(maxWidth: .infinity)
                .frame(height: totalHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: containerCornerRadius, style: .continuous)
                        .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
                )
            
            // Stacked Partition Bands
            VStack(spacing: 0) {
                ForEach(0..<allocations.count, id: \.self) { index in
                    let item = allocations[index]
                    let bandHeight = max(totalHeight * CGFloat(item.percentage), 40)
                    
                    HStack(spacing: 16) {
                        // Avatar Circle
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text(item.initials)
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Colors.primary)
                            )
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        
                        // First Name
                        Text(item.firstName)
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Spacer()
                        
                        // Percentage Readout
                        Text("\(Int(round(item.percentage * 100)))%")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity)
                    .frame(height: bandHeight)
                    
                    // Divider & Draggable Handle between rows
                    if index < allocations.count - 1 {
                        ZStack {
                            Divider()
                                .background(Theme.Colors.dividerMedium)
                            
                            // Custom Circular Drag Handle
                            Image("drag_handle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                                .gesture(
                                    DragGesture(minimumDistance: 1)
                                        .onChanged { value in
                                            handleDrag(dividerIndex: index, translationY: value.translation.height)
                                        }
                                        .onEnded { _ in
                                            dragInitialAllocations = nil
                                        }
                                )
                        }
                        .frame(height: 1)
                        .zIndex(10)
                    }
                }
            }
            .frame(height: totalHeight)
        }
        .clipShape(RoundedRectangle(cornerRadius: containerCornerRadius, style: .continuous))
    }
    
    // MARK: - 5% Snapping Drag Logic
    private func handleDrag(dividerIndex: Int, translationY: CGFloat) {
        if dragInitialAllocations == nil {
            dragInitialAllocations = allocations
        }
        guard let initials = dragInitialAllocations,
              dividerIndex < initials.count - 1 else { return }
        
        let deltaPercentageRaw = Double(translationY / totalHeight)
        let snappedDelta = (deltaPercentageRaw / snapStep).rounded() * snapStep
        
        var newAllocations = initials
        let currentUpper = initials[dividerIndex].percentage
        let currentLower = initials[dividerIndex + 1].percentage
        
        var proposedUpper = currentUpper + snappedDelta
        var proposedLower = currentLower - snappedDelta
        
        // Clamp to minPercentage
        if proposedUpper < minPercentage {
            let diff = minPercentage - proposedUpper
            proposedUpper = minPercentage
            proposedLower -= diff
        }
        if proposedLower < minPercentage {
            let diff = minPercentage - proposedLower
            proposedLower = minPercentage
            proposedUpper -= diff
        }
        
        newAllocations[dividerIndex].percentage = (proposedUpper * 100).rounded() / 100
        newAllocations[dividerIndex + 1].percentage = (proposedLower * 100).rounded() / 100
        
        // Assign with haptic feedback trigger
        if allocations != newAllocations {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            allocations = newAllocations
        }
    }
}

// MARK: - Previews
#Preview("Vertical Time Allocation Bubble") {
    struct PreviewWrapper: View {
        @State var sampleAllocations = [
            ParticipantAllocation(initials: "SM", firstName: "Sarah", percentage: 0.30),
            ParticipantAllocation(initials: "JC", firstName: "James", percentage: 0.25),
            ParticipantAllocation(initials: "LC", firstName: "Linda", percentage: 0.20),
            ParticipantAllocation(initials: "DO", firstName: "David", percentage: 0.15),
            ParticipantAllocation(initials: "RS", firstName: "Rachel", percentage: 0.10)
        ]
        
        var body: some View {
            VStack(spacing: 20) {
                VerticalTimeAllocationBubble(allocations: $sampleAllocations)
            }
            .padding(20)
            .background(Theme.Colors.background)
        }
    }
    return PreviewWrapper()
}
