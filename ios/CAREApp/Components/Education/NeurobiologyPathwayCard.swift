import SwiftUI

// MARK: - Neurobiology Pathway Card (Figma Frame 12: 146:5 / Node 146:27)
public struct NeurobiologyPathwayCard: View {
    public let pathway: NeuralPathwayItem
    public let onExerciseTap: (() -> Void)?
    
    public var domainColor: Color {
        pathway.domain.themeColor
    }
    
    public init(
        pathway: NeuralPathwayItem,
        onExerciseTap: (() -> Void)? = nil
    ) {
        self.pathway = pathway
        self.onExerciseTap = onExerciseTap
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row: Domain pill, Pathway Name, Disclosure
            HStack(alignment: .center, spacing: 10) {
                // Domain Pill Badge (e.g. "C - Calm")
                HStack(spacing: 5) {
                    Circle()
                        .fill(domainColor)
                        .frame(width: 10, height: 10)
                    
                    Text(pathway.domain.title.uppercased())
                        .font(Theme.Typography.poppins(.bold, size: 11))
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
                )
                
                Spacer()
                
                // Brain Region Callout
                Text(pathway.brainRegion)
                    .font(Theme.Typography.poppins(.medium, size: 12))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Pathway Name Title
            Text(pathway.name)
                .font(Theme.Typography.poppins(.bold, size: 18))
                .foregroundColor(Theme.Colors.textPrimary)
            
            // Function Description
            Text(pathway.function)
                .font(Theme.Typography.poppins(.regular, size: 14))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
            
            // Strengthening Exercises Action Button (Routes to upcoming Exercises flow)
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                onExerciseTap?()
            }) {
                Text("Strengthening Exercises")
                    .font(Theme.Typography.poppins(.semiBold, size: 14))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(Theme.Colors.primary)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Theme.Colors.primary, lineWidth: 1.2)
                    )
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pathway.domain.title) pathway: \(pathway.name), \(pathway.brainRegion). \(pathway.function)")
    }
}

// MARK: - Previews
#Preview("Neurobiology Pathway Cards") {
    VStack(spacing: 16) {
        NeurobiologyPathwayCard(
            pathway: NeuralPathwayItem(
                id: "np-calm",
                domain: .calm,
                name: "Smart Vagus Nerve",
                brainRegion: "Parasympathetic 10th Cranial",
                function: "By dampening the body's acute stress response and signaling physiological safety, this pathway shifts us into a state of calm.",
                exerciseSuggestion: "Practice extended exhale breathing (4 seconds in, 7 seconds out) to stimulate the ventral vagal brake."
            )
        )
        
        NeurobiologyPathwayCard(
            pathway: NeuralPathwayItem(
                id: "np-accepted",
                domain: .accepted,
                name: "Dorsal Anterior Cingulate Cortex",
                brainRegion: "DACC & Insula",
                function: "Functioning as the brain's social pain alarm, this region processes relational exclusion along the exact same pathways as physical injury.",
                exerciseSuggestion: "Validate relational pain with self-compassion mantras to soothe the dorsal ACC."
            )
        )
    }
    .padding(20)
    .background(Theme.Colors.background)
}
