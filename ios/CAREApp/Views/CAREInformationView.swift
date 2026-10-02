import SwiftUI

// MARK: - Screen: CARE Information Guide (Figma Frame 372:50 & Node 239:8)
public struct CAREInformationView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    public let initialCategory: ExerciseCategory
    @State private var selectedCategory: ExerciseCategory = .calm
    
    public init(initialCategory: ExerciseCategory = .calm) {
        self.initialCategory = initialCategory
        self._selectedCategory = State(initialValue: initialCategory)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showSparkleButton: true,
                showChartButton: true,
                showProfileButton: true,
                onBack: { router?.pop() }
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Intro
                    VStack(alignment: .leading, spacing: 6) {
                        Text("About C.A.R.E.")
                            .font(Theme.Typography.poppins(.bold, size: 28))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Explore how each C.A.R.E. category reflects safety and connection in your relationships.")
                            .font(Theme.Typography.screenSubtitle)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(3)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Category Switcher Pills
                    HStack(spacing: 8) {
                        ForEach(ExerciseCategory.allCases) { cat in
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                selectedCategory = cat
                            }) {
                                Text(cat.rawValue)
                                    .font(Theme.Typography.poppins(.semiBold, size: 14))
                                    .foregroundColor(categoryTextColor(cat))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .background(categoryBgColor(cat))
                                    .clipShape(Capsule())
                                    .overlay {
                                        Capsule().stroke(selectedCategory == cat ? cat.accentColor : .clear, lineWidth: 1.5)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Category Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text(categoryHeadline(selectedCategory))
                            .font(Theme.Typography.poppins(.bold, size: 20))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text(categoryDescription(selectedCategory))
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                    }
                    
                    // 3 Guidance Cards (High, Moderate, Low)
                    VStack(spacing: 12) {
                        guidanceCard(
                            levelColor: Color(hex: "#38B969"),
                            title: highTitle(selectedCategory),
                            description: highDescription(selectedCategory)
                        )
                        
                        guidanceCard(
                            levelColor: Color(hex: "#FABF2E"),
                            title: moderateTitle(selectedCategory),
                            description: moderateDescription(selectedCategory)
                        )
                        
                        guidanceCard(
                            levelColor: Color(hex: "#E84D4D"),
                            title: lowTitle(selectedCategory),
                            description: lowDescription(selectedCategory)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Pinned Bottom Action
            VStack(spacing: 0) {
                SecondaryButton(
                    title: "Back to Results",
                    icon: "arrow.left",
                    action: {
                        router?.pop()
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#F8FAFC").ignoresSafeArea())
    }
    
    @ViewBuilder
    private func guidanceCard(levelColor: Color, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Theme.Typography.poppins(.semiBold, size: 13))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(levelColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            Text(description)
                .font(Theme.Typography.poppins(.regular, size: 13.5))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Color & Copy Helpers
    private func categoryBgColor(_ cat: ExerciseCategory) -> Color {
        cat.badgeColor
    }
    
    private func categoryTextColor(_ cat: ExerciseCategory) -> Color {
        cat.accentColor
    }
    
    private func categoryHeadline(_ cat: ExerciseCategory) -> String {
        switch cat {
        case .calm: return "C IS FOR CALM"
        case .accepted: return "A IS FOR ACCEPTEDNESS"
        case .resonant: return "R IS FOR RESONANCE"
        case .energetic: return "E IS FOR ENERGY"
        }
    }
    
    private func categoryDescription(_ cat: ExerciseCategory) -> String {
        switch cat {
        case .calm:
            return "Calmness is related to the functioning of the smart vagus nerve and your social engagement system."
        case .accepted:
            return "Acceptance reflects how safe and included you feel in your relationships. It measures your sense of belonging."
        case .resonant:
            return "Resonance captures the depth of mutual understanding in your relationships and how well you truly connect."
        case .energetic:
            return "Energy measures how much vitality and motivation you draw from your relationships and mutual bonds."
        }
    }
    
    private func highTitle(_ cat: ExerciseCategory) -> String {
        switch cat {
        case .calm: return "Good Vagal Tone (95–125)"
        case .accepted: return "Accurate Acceptance System (95–125)"
        case .resonant: return "Strong Mirror Neuron Activity (95–125)"
        case .energetic: return "Healthy Reward System (95–125)"
        }
    }
    
    private func highDescription(_ cat: ExerciseCategory) -> String {
        switch cat {
        case .calm:
            return "Your smart vagus nerve helps calm and relax you. Your relationships help you manage the stress of day-to-day life."
        case .accepted:
            return "Your brain accurately recognizes when you are included or excluded. Most of your relationships feel safe and give you a sense of belonging."
        case .resonant:
            return "You generally feel seen and understood by others and are able to understand their feelings and intentions. Relationships tend to feel emotionally easy and connected."
        case .energetic:
            return "Connection with others tends to feel rewarding and energizing. Healthy relationships increase your motivation and support your ability to act on behalf of yourself and your relationships."
        }
    }
    
    private func moderateTitle(_ cat: ExerciseCategory) -> String {
        switch cat {
        case .calm: return "Moderate Vagal Tone (70–94)"
        case .accepted: return "Reactive Acceptance System (70–94)"
        case .resonant: return "Moderate Mirror Neuron Activity (70–94)"
        case .energetic: return "Moderate Reward System (70–94)"
        }
    }
    
    private func moderateDescription(_ cat: ExerciseCategory) -> String {
        switch cat {
        case .calm:
            return "Some relationships may trigger stress or anxiety. Past stressful relationship patterns can make it harder to feel calm and supported in your current relationships."
        case .accepted:
            return "You may sometimes feel left out, disconnected, or as though you don’t belong, even when you are with others. Past relationship patterns may influence how safe and included you feel now."
        case .resonant:
            return "Reading other people can sometimes be difficult. You may occasionally feel misunderstood or misread other people’s intentions and reactions."
        case .energetic:
            return "Relationships may sometimes feel rewarding but can also feel neutral or draining. You may feel energized by certain relationships more than others."
        }
    }
    
    private func lowTitle(_ cat: ExerciseCategory) -> String {
        switch cat {
        case .calm: return "Low Vagal Tone (Below 70)"
        case .accepted: return "Highly Reactive Acceptance System (Below 70)"
        case .resonant: return "Low Mirror Neuron Activity (Below 70)"
        case .energetic: return "Low Relational Reward (Below 70)"
        }
    }
    
    private func lowDescription(_ cat: ExerciseCategory) -> String {
        switch cat {
        case .calm:
            return "Relationships may often feel unsafe or add to your stress. Current or past difficult relationships may keep your nervous system reactive and prepared for threat."
        case .accepted:
            return "Your alarm system for rejection or exclusion may be frequently activated. This can make it difficult to feel a sense of belonging and may cause relationships to feel less safe or accepting than they are."
        case .resonant:
            return "Understanding other people’s feelings and intentions may often feel difficult or overwhelming. Misunderstandings and disconnections may occur more frequently in relationships."
        case .energetic:
            return "Relationships may rarely feel energizing or rewarding, and being alone may sometimes feel preferable. You may be more likely to seek feelings of reward or stimulation outside of relationships."
        }
    }
}

#Preview {
    CAREInformationView()
}
