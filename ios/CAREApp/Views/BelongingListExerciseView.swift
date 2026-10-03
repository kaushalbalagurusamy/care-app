import SwiftUI

// MARK: - Screen: Make a Belonging List Exercise (Figma Frame 286:4 & Node 239:8)
public struct BelongingListExerciseView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(ExerciseProgressStore.self) private var progress: ExerciseProgressStore?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    
    @State private var items: [String] = ["", "", ""]
    @State private var customItems: [String] = []
    @State private var showCancelConfirmation = false
    @State private var draftError: String?
    @State private var restoredDraft = false
    @State private var didComplete = false
    
    private let placeholders = [
        "Add a person, place, or community...",
        "A safe group, pet, or relationship...",
        "A favorite nature spot or home space..."
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
                accentColor: ExerciseCategory.accepted.accentColor,
                onBack: { showCancelConfirmation = true }
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    ExercisePageHeader(
                        item: ExerciseItem.sampleAcceptedExercises[0],
                        description: "Write down people, places, communities, or relationships where you experience some sense of belonging. Notice that belonging can exist in many forms."
                    )
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Fields List
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("My Belonging List")
                                .font(Theme.Typography.poppins(.bold, size: 16))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Text("\(completedCount) / \(items.count + customItems.count) Completed")
                                .font(Theme.Typography.poppins(.medium, size: 12))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        
                        VStack(spacing: 10) {
                            ForEach(0..<3, id: \.self) { idx in
                                itemField(index: idx + 1, placeholder: placeholders[idx], text: $items[idx])
                            }
                            
                            ForEach(customItems.indices, id: \.self) { cIdx in
                                itemField(index: 4 + cIdx, placeholder: "Add your own...", text: $customItems[cIdx])
                            }
                            
                            if customItems.count < 3 { Button(action: {
                                customItems.append("")
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Add your own...")
                                        .font(Theme.Typography.poppins(.medium, size: 14))
                                }
                                .foregroundColor(ExerciseCategory.accepted.accentColor)
                                .padding(.vertical, 8)
                            } }
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
                    isEnabled: completedCount >= 3,
                    accentColor: ExerciseCategory.accepted.accentColor,
                    action: {
                        guard !didComplete else { return }
                        do {
                            guard let progress else { throw CocoaError(.fileNoSuchFile) }
                            try progress.completeAndDiscard("belonging-list")
                            didComplete = true
                            router?.finishFlow(at: .exerciseCompleteFor("belonging-list"))
                        } catch { draftError = "Completion could not be saved. Please try again." }
                    }
                )
                
                Button(action: {
                    showCancelConfirmation = true
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
        .overlay {
            if showCancelConfirmation {
                ExerciseLeaveConfirmationView(
                    onKeepEditing: { showCancelConfirmation = false },
                    onLeave: { showCancelConfirmation = false; router?.pop() }
                )
            }
        }
        .task {
            if let draft = appEnvironment?.draftStore.exercise(for: "belonging-list") {
                items = (0..<3).map { draft.fields["item\($0)"] ?? "" }
                let count = min(max(Int(draft.fields["customCount"] ?? "0") ?? 0, 0), 3)
                customItems = (0..<count).map { draft.fields["custom\($0)"] ?? "" }
            }
            restoredDraft = true
            if appEnvironment?.draftStore.exercise(for: "belonging-list") == nil { persistDraft() }
        }
        .onChange(of: items) { _, _ in persistDraft() }
        .onChange(of: customItems) { _, _ in persistDraft() }
        .alert("Exercise progress", isPresented: Binding(get: { draftError != nil }, set: { if !$0 { draftError = nil } })) {
            Button("OK", role: .cancel) { draftError = nil }
        } message: { Text(draftError ?? "") }
    }

    private func persistDraft() {
        guard restoredDraft, let appEnvironment else { return }
        var draft = ExerciseDraft(exerciseID: "belonging-list")
        for (index, value) in items.enumerated() { draft.fields["item\(index)"] = value }
        for (index, value) in customItems.enumerated() { draft.fields["custom\(index)"] = value }
        draft.fields["customCount"] = String(customItems.count)
        do { try appEnvironment.draftStore.saveExercise(draft) }
        catch { draftError = "Your exercise progress could not be saved. Please try again before leaving." }
    }
    
    @ViewBuilder
    private func itemField(index: Int, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#EDFBF8"))
                    .frame(width: 28, height: 28)
                Text("\(index)")
                    .font(Theme.Typography.poppins(.bold, size: 13))
                    .foregroundColor(ExerciseCategory.accepted.accentColor)
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
