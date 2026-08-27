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
    @State private var dragStartUpperPct: Double = 0.0
    @State private var dragStartLowerPct: Double = 0.0
    
    private let containerCornerRadius: CGFloat = 20.0
    private let minPercentage: Double = 0.15
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
                        
                        HStack(spacing: 14) {
                            // Fixed Avatar Circle (No resizing with 15% min)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Text(item.initials)
                                        .font(Theme.Typography.poppins(.bold, size: 16))
                                        .foregroundColor(Theme.Colors.primary)
                                )
                                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                            
                            // First Name
                            Text(item.firstName)
                                .font(Theme.Typography.poppins(.bold, size: 17))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            // Percentage Readout
                            Text("\(Int(round(item.percentage * 100)))%")
                                .font(Theme.Typography.poppins(.bold, size: 17))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .contentTransition(.numericText())
                        }
                        .padding(.horizontal, 18)
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
                                    .frame(width: 22, height: 22)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(isDraggingCurrent ? 0.20 : 0.10), radius: isDraggingCurrent ? 6 : 3, x: 0, y: 2)
                                    .scaleEffect(isDraggingCurrent ? 1.15 : 1.0)
                                    .animation(.spring(response: 0.2, dampingFraction: 0.75), value: isDraggingCurrent)
                                    .contentShape(Rectangle().inset(by: -18)) // generous hit test area
                                    .gesture(
                                        DragGesture(minimumDistance: 1)
                                            .onChanged { value in
                                                handleFreeDrag(
                                                    dividerIndex: index,
                                                    translationY: value.translation.height,
                                                    totalHeight: totalHeight
                                                )
                                            }
                                            .onEnded { value in
                                                handleDragEnd(
                                                    dividerIndex: index,
                                                    translationY: value.translation.height,
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
    }
    
    // MARK: - Free Fluid Dragging (1:1 Continuous Movement)
    private func handleFreeDrag(dividerIndex: Int, translationY: CGFloat, totalHeight: CGFloat) {
        guard totalHeight > 0, dividerIndex < allocations.count - 1 else { return }
        
        if dragDividerIndex != dividerIndex {
            dragDividerIndex = dividerIndex
            dragStartUpperPct = allocations[dividerIndex].percentage
            dragStartLowerPct = allocations[dividerIndex + 1].percentage
        }
        
        let deltaPct = Double(translationY / totalHeight)
        let totalPairPct = dragStartUpperPct + dragStartLowerPct
        
        var proposedUpper = dragStartUpperPct + deltaPct
        var proposedLower = dragStartLowerPct - deltaPct
        
        // Clamp to minimum 15% (0.15)
        if proposedUpper < minPercentage {
            proposedUpper = minPercentage
            proposedLower = totalPairPct - minPercentage
        } else if proposedLower < minPercentage {
            proposedLower = minPercentage
            proposedUpper = totalPairPct - minPercentage
        }
        
        allocations[dividerIndex].percentage = proposedUpper
        allocations[dividerIndex + 1].percentage = proposedLower
    }
    
    // MARK: - Snap to Closest 5% Interval on Release
    private func handleDragEnd(dividerIndex: Int, translationY: CGFloat, totalHeight: CGFloat) {
        guard totalHeight > 0, dividerIndex < allocations.count - 1 else { return }
        
        let rawDeltaPct = Double(translationY / totalHeight)
        let totalPairPct = dragStartUpperPct + dragStartLowerPct
        
        // Step delta to closest 5% (0.05) increment
        let steppedDelta = (rawDeltaPct / 0.05).rounded() * 0.05
        
        var snappedUpper = ((dragStartUpperPct + steppedDelta) * 20.0).rounded() / 20.0
        var snappedLower = ((dragStartLowerPct - steppedDelta) * 20.0).rounded() / 20.0
        
        // Clamp to minimum 15% (0.15)
        if snappedUpper < minPercentage {
            snappedUpper = minPercentage
            snappedLower = ((totalPairPct - minPercentage) * 20.0).rounded() / 20.0
        } else if snappedLower < minPercentage {
            snappedLower = minPercentage
            snappedUpper = ((totalPairPct - minPercentage) * 20.0).rounded() / 20.0
        }
        
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            allocations[dividerIndex].percentage = (snappedUpper * 100).rounded() / 100
            allocations[dividerIndex + 1].percentage = (snappedLower * 100).rounded() / 100
            dragDividerIndex = nil
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
