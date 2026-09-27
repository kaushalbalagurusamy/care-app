import SwiftUI

// MARK: - Screen: Watch Something Funny Exercise (Figma Frame 275:4 & Node 239:8)
public struct WatchFunnyExerciseView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @State private var selectedClipIndex: Int = 0
    
    public init() {}
    
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
                    
                    // Emoji & Badges
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text("🎬")
                                .font(.system(size: 28))
                            
                            Text("CALM")
                                .font(Theme.Typography.poppins(.bold, size: 11))
                                .foregroundColor(Color(hex: "#1E40AF"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#DBEAFE"))
                                .clipShape(Capsule())
                            
                            Text("⏱ 2–5 min")
                                .font(Theme.Typography.poppins(.medium, size: 11))
                                .foregroundColor(Theme.Colors.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#F1F5F9"))
                                .clipShape(Capsule())
                        }
                        
                        Text("Watch Something Funny")
                            .font(Theme.Typography.poppins(.bold, size: 26))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Pick a short clip that makes you smile. Laughter activates your smart vagus nerve and helps your body feel safe.")
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Clips List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose a clip")
                            .font(Theme.Typography.poppins(.bold, size: 16))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        clipCard(
                            index: 0,
                            title: "Funny Animal Compilation",
                            badge: "🔥 POPULAR",
                            duration: "⏱ 3 min",
                            subtitle: "Popular videos of funny animals and pets"
                        )
                        
                        clipCard(
                            index: 1,
                            title: "Wanda Sykes: Stand-Up Highlights",
                            badge: nil,
                            duration: "⏱ 4 min",
                            subtitle: "Stand-up comedy clips"
                        )
                        
                        uploadClipCard(index: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Pinned Bottom Actions
            VStack(spacing: 8) {
                PrimaryButton(
                    title: "Complete Exercise",
                    action: {
                        router?.navigate(to: .exerciseComplete)
                    }
                )
                
                Button(action: {
                    router?.pop()
                }) {
                    Text("Cancel")
                        .font(Theme.Typography.poppins(.medium, size: 15))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func clipCard(index: Int, title: String, badge: String?, duration: String, subtitle: String) -> some View {
        let isSelected = selectedClipIndex == index
        Button(action: {
            selectedClipIndex = index
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Theme.Colors.primary : Color(hex: "#F1F5F9"))
                        .frame(width: 44, height: 44)
                    Image(systemName: "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(isSelected ? .white : Theme.Colors.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(Theme.Typography.poppins(.semiBold, size: 14.5))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        if let badge = badge {
                            Text(badge)
                                .font(Theme.Typography.poppins(.bold, size: 9))
                                .foregroundColor(Color(hex: "#EA580C"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "#FFEDD5"))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("\(duration) • \(subtitle)")
                        .font(Theme.Typography.poppins(.regular, size: 12))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.primary)
                        .font(.system(size: 20))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Theme.Colors.primary : Color(hex: "#E2E8F0"), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func uploadClipCard(index: Int) -> some View {
        let isSelected = selectedClipIndex == index
        Button(action: {
            selectedClipIndex = index
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                        .foregroundColor(Theme.Colors.primary)
                        .frame(width: 44, height: 44)
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.Colors.primary)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Upload Your Own Video")
                        .font(Theme.Typography.poppins(.semiBold, size: 14.5))
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text("Tap to upload a video from your camera roll")
                        .font(Theme.Typography.poppins(.regular, size: 12))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Theme.Colors.primary : Color(hex: "#E2E8F0"), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WatchFunnyExerciseView()
}
