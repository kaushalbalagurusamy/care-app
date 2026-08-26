import SwiftUI
import UIKit

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

// MARK: - Vertical Time Allocation Bubble with Smooth Threshold-Based 5% Snapping (Figma Frame 41:4)
public struct VerticalTimeAllocationBubble: View {
    @Binding public var allocations: [ParticipantAllocation]
    
    // State tracking active drag threshold per divider
    @State private var activeDividerIndex: Int? = nil
    @State private var accumulatedTranslationY: CGFloat = 0.0
    @State private var lastDragTranslationY: CGFloat = 0.0
    
    private let totalHeight: CGFloat = 560.0
    private let containerCornerRadius: CGFloat = 28.0
    private let minPercentage: Double = 0.05
    private let stepThresholdPoints: CGFloat = 24.0 // Threshold in points to step 5%
    
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
                    let bandHeight = max(totalHeight * CGFloat(item.percentage), 44)
                    
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
                            .contentTransition(.numericText())
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity)
                    .frame(height: bandHeight)
                    .animation(.spring(response: 0.32, dampingFraction: 0.82), value: allocations)
                    
                    // Divider & Draggable Handle between rows
                    if index < allocations.count - 1 {
                        let isDraggingCurrent = (activeDividerIndex == index)
                        let handleVisualOffset = isDraggingCurrent ? min(max(accumulatedTranslationY * 0.4, -10), 10) : 0
                        
                        ZStack {
                            Divider()
                                .background(Theme.Colors.dividerMedium)
                            
                            // Custom Circular Drag Handle with tactile feedback
                            Image("drag_handle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(isDraggingCurrent ? 0.20 : 0.10), radius: isDraggingCurrent ? 6 : 3, x: 0, y: 2)
                                .scaleEffect(isDraggingCurrent ? 1.12 : 1.0)
                                .offset(y: handleVisualOffset)
                                .animation(.spring(response: 0.2, dampingFraction: 0.75), value: isDraggingCurrent)
                                .contentShape(Rectangle().inset(by: -15)) // generous hit test area
                                .gesture(
                                    DragGesture(minimumDistance: 2)
                                        .onChanged { value in
                                            handleThresholdDrag(dividerIndex: index, currentTranslationY: value.translation.height)
                                        }
                                        .onEnded { _ in
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                                activeDividerIndex = nil
                                                accumulatedTranslationY = 0.0
                                                lastDragTranslationY = 0.0
                                            }
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
    
    // MARK: - Smooth Threshold-Based Stepping Physics
    private func handleThresholdDrag(dividerIndex: Int, currentTranslationY: CGFloat) {
        if activeDividerIndex != dividerIndex {
            activeDividerIndex = dividerIndex
            lastDragTranslationY = currentTranslationY
            accumulatedTranslationY = 0.0
        }
        
        let delta = currentTranslationY - lastDragTranslationY
        lastDragTranslationY = currentTranslationY
        accumulatedTranslationY += delta
        
        // Downward drag past threshold -> Upper gains 5%, Lower loses 5%
        if accumulatedTranslationY >= stepThresholdPoints {
            let steps = Int(accumulatedTranslationY / stepThresholdPoints)
            if applyStep(dividerIndex: dividerIndex, stepDirection: 1, stepCount: steps) {
                accumulatedTranslationY -= CGFloat(steps) * stepThresholdPoints
                triggerHapticTick()
            } else {
                // Clamped at limit
                accumulatedTranslationY = min(accumulatedTranslationY, stepThresholdPoints * 0.6)
            }
        }
        // Upward drag past negative threshold -> Upper loses 5%, Lower gains 5%
        else if accumulatedTranslationY <= -stepThresholdPoints {
            let steps = Int(abs(accumulatedTranslationY) / stepThresholdPoints)
            if applyStep(dividerIndex: dividerIndex, stepDirection: -1, stepCount: steps) {
                accumulatedTranslationY += CGFloat(steps) * stepThresholdPoints
                triggerHapticTick()
            } else {
                // Clamped at limit
                accumulatedTranslationY = max(accumulatedTranslationY, -stepThresholdPoints * 0.6)
            }
        }
    }
    
    // MARK: - Apply Discrete 5% Step
    private func applyStep(dividerIndex: Int, stepDirection: Int, stepCount: Int) -> Bool {
        guard dividerIndex < allocations.count - 1 else { return false }
        
        let deltaPercentage = Double(stepDirection * stepCount) * 0.05
        let currentUpper = allocations[dividerIndex].percentage
        let currentLower = allocations[dividerIndex + 1].percentage
        
        let proposedUpper = (currentUpper + deltaPercentage)
        let proposedLower = (currentLower - deltaPercentage)
        
        // Prevent either participant from going below the 5% minimum
        guard proposedUpper >= (minPercentage - 0.001),
              proposedLower >= (minPercentage - 0.001) else {
            return false
        }
        
        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
            allocations[dividerIndex].percentage = (proposedUpper * 100).rounded() / 100
            allocations[dividerIndex + 1].percentage = (proposedLower * 100).rounded() / 100
        }
        return true
    }
    
    private func triggerHapticTick() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
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
