import SwiftUI

// MARK: - Screen: Make a Belonging List Exercise (Figma Frame 286:4 & Node 239:8)
public struct BelongingListExerciseView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    
    @State private var items: [String] = ["", "", "", "", ""]
    @State private var customItems: [String] = []
    
    private let placeholders = [
        "Add a person, place, or community...",
        "A safe group, pet, or relationship...",
        "A favorite nature spot or home space...",
        "An online forum or hobby club...",
        "Someone who truly sees and hears you..."
    ]
    
    public init() {}
    
    private var completedCount: Int {
        items.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count +
        customItems.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
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
                    
                    // Emoji & Badges
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text("🫂")
                                .font(.system(size: 28))
                            
                            Text("Accepted")
                                .font(Theme.Typography.poppins(.bold, size: 11))
                                .foregroundColor(Color(hex: "#065F46"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#D1FAE5"))
                                .clipShape(Capsule())
                            
                            Text("⏱ 3-5 min")
                                .font(Theme.Typography.poppins(.medium, size: 11))
                                .foregroundColor(Theme.Colors.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#F1F5F9"))
                                .clipShape(Capsule())
                        }
                        
                        Text("Make a Belonging List")
                            .font(Theme.Typography.poppins(.bold, size: 26))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Write down people, places, communities, or relationships where you experience some sense of belonging. Notice that belonging can exist in many forms.")
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(.top, 4)
                    
                    // Fields List
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("My Belonging List")
                                .font(Theme.Typography.poppins(.bold, size: 16))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Text("\(completedCount) / 5 Completed")
                                .font(Theme.Typography.poppins(.medium, size: 12))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        
                        VStack(spacing: 10) {
                            ForEach(0..<5, id: \.self) { idx in
                                itemField(index: idx + 1, placeholder: placeholders[idx], text: $items[idx])
                            }
                            
                            ForEach(customItems.indices, id: \.self) { cIdx in
                                itemField(index: 6 + cIdx, placeholder: "Add your own...", text: $customItems[cIdx])
                            }
                            
                            Button(action: {
                                customItems.append("")
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Add your own...")
                                        .font(Theme.Typography.poppins(.medium, size: 14))
                                }
                                .foregroundColor(Theme.Colors.primary)
                                .padding(.vertical, 8)
                            }
                        }
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
    private func itemField(index: Int, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#EFF6FF"))
                    .frame(width: 28, height: 28)
                Text("\(index)")
                    .font(Theme.Typography.poppins(.bold, size: 13))
                    .foregroundColor(Theme.Colors.primary)
            }
            
            TextField(placeholder, text: text)
                .font(Theme.Typography.poppins(.regular, size: 14))
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .padding(.horizontal, 14)
        .frame(height: 50)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
        )
    }
}

#Preview {
    BelongingListExerciseView()
}
