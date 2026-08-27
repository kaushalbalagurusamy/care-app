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
    
    // State tracking active drag per divider
    @State private var dragDividerIndex: Int? = nil
    @State private var initialPercentages: [Double] = []
    
    private let containerCornerRadius: CGFloat = 20.0
    private let minPercentage: Double = 0.05
    private let outlineColor = Color(hex: "#94A2B8")
    
    public init(allocations: Binding<[ParticipantAllocation]>) {
        self._allocations = allocations
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            
            ZStack(alignment: .top) {
                // Background Container Box
                RoundedRectangle(cornerRadius: containerCornerRadius, style: .continuous)
                    .fill(Theme.Colors.cardSurface)
                    .frame(maxWidth: .infinity)
                    .frame(height: totalHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: containerCornerRadius, style: .continuous)
                            .stroke(outlineColor, lineWidth: 1.5)
                    )
                
                // Stacked Partition Bands
                VStack(spacing: 0) {
                    ForEach(0..<allocations.count, id: \.self) { index in
                        let item = allocations[index]
                        let bandHeight = totalHeight * CGFloat(item.percentage)
                        
                        HStack(spacing: 10) {
                            // Uniform Avatar Circle (Constant across all percentages)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Text(item.initials)
                                        .font(Theme.Typography.poppins(.bold, size: 11.5))
                                        .foregroundColor(Theme.Colors.primary)
                                )
                                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                            
                            // First Name
                            Text(item.firstName)
                                .font(Theme.Typography.poppins(.semiBold, size: 14.5))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            // Percentage Readout
                            Text("\(Int(round(item.percentage * 100)))%")
                                .font(Theme.Typography.poppins(.bold, size: 14.5))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .contentTransition(.numericText())
                        }
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .frame(height: bandHeight)
                        
                        // Divider & Draggable Handle between rows
                        if index < allocations.count - 1 {
                            let isDraggingCurrent = (dragDividerIndex == index)
                            
                            ZStack {
                                Rectangle()
                                    .fill(outlineColor)
                                    .frame(height: 1.5)
                                
                                // Custom Circular Drag Handle with tactile feedback
                                Image("drag_handle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(isDraggingCurrent ? 0.25 : 0.10), radius: isDraggingCurrent ? 6 : 3, x: 0, y: 2)
                                    .scaleEffect(isDraggingCurrent ? 1.15 : 1.0)
                                    .animation(.spring(response: 0.2, dampingFraction: 0.75), value: isDraggingCurrent)
                                    .contentShape(Rectangle().inset(by: -20)) // generous hit test area
                                    .gesture(
                                        DragGesture(minimumDistance: 0, coordinateSpace: .named("AllocationContainer"))
                                            .onChanged { value in
                                                handleFreeDrag(
                                                    dividerIndex: index,
                                                    fingerY: value.location.y,
                                                    totalHeight: totalHeight
                                                )
                                            }
                                            .onEnded { value in
                                                handleDragEnd(
                                                    dividerIndex: index,
                                                    fingerY: value.location.y,
                                                    totalHeight: totalHeight
                                                )
                                            }
                                    )
                            }
                            .frame(height: 1.5)
                            .zIndex(10)
                        }
                    }
                }
                .frame(height: totalHeight)
            }
            .clipShape(RoundedRectangle(cornerRadius: containerCornerRadius, style: .continuous))
        }
        .coordinateSpace(name: "AllocationContainer")
    }
    
    // MARK: - Free Fluid Dragging (Tracks Finger's Y Position 1:1 Instantaneously)
    private func handleFreeDrag(dividerIndex: Int, fingerY: CGFloat, totalHeight: CGFloat) {
        guard totalHeight > 0, dividerIndex < allocations.count - 1 else { return }
        
        if dragDividerIndex != dividerIndex || initialPercentages.isEmpty {
            dragDividerIndex = dividerIndex
            initialPercentages = allocations.map { $0.percentage }
        }
        
        // Sum of percentages preceding the active pair
        let prevSumPct = initialPercentages.prefix(dividerIndex).reduce(0.0, +)
        let topY = prevSumPct * totalHeight
        
        // Pair combined percentage
        let pairPct = initialPercentages[dividerIndex] + initialPercentages[dividerIndex + 1]
        let bottomY = (prevSumPct + pairPct) * totalHeight
        
        let minHeight = minPercentage * totalHeight
        
        // Clamp finger Y between top bound + minHeight and bottom bound - minHeight
        let clampedY = min(max(fingerY, topY + minHeight), bottomY - minHeight)
        
        let newUpperPct = (clampedY - topY) / totalHeight
        let newLowerPct = (bottomY - clampedY) / totalHeight
        
        allocations[dividerIndex].percentage = newUpperPct
        allocations[dividerIndex + 1].percentage = newLowerPct
    }
    
    // MARK: - Snap to Closest 5% Interval ONLY on Release
    private func handleDragEnd(dividerIndex: Int, fingerY: CGFloat, totalHeight: CGFloat) {
        guard totalHeight > 0, dividerIndex < allocations.count - 1 else { return }
        
        if initialPercentages.isEmpty {
            initialPercentages = allocations.map { $0.percentage }
        }
        
        let prevSumPct = initialPercentages.prefix(dividerIndex).reduce(0.0, +)
        let topY = prevSumPct * totalHeight
        let pairPct = initialPercentages[dividerIndex] + initialPercentages[dividerIndex + 1]
        let bottomY = (prevSumPct + pairPct) * totalHeight
        
        let minHeight = minPercentage * totalHeight
        let clampedY = min(max(fingerY, topY + minHeight), bottomY - minHeight)
        
        let rawUpperPct = (clampedY - topY) / totalHeight
        
        // Step to nearest 5% (0.05) interval
        var snappedUpper = (rawUpperPct / 0.05).rounded() * 0.05
        var snappedLower = ((pairPct - snappedUpper) * 20.0).rounded() / 20.0
        
        // Enforce 5% minimum
        if snappedUpper < minPercentage {
            snappedUpper = minPercentage
            snappedLower = ((pairPct - minPercentage) * 20.0).rounded() / 20.0
        } else if snappedLower < minPercentage {
            snappedLower = minPercentage
            snappedUpper = ((pairPct - minPercentage) * 20.0).rounded() / 20.0
        }
        
        snappedUpper = (snappedUpper * 100).rounded() / 100
        snappedLower = (snappedLower * 100).rounded() / 100
        
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            allocations[dividerIndex].percentage = snappedUpper
            allocations[dividerIndex + 1].percentage = snappedLower
            dragDividerIndex = nil
            initialPercentages = []
        }
        
        triggerHapticTick()
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
