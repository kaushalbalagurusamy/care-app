import SwiftUI

struct GuidedExerciseStep {
    let heading: String
    let instructions: [String]
    let prompts: [String]
    let options: [String]
}

struct GuidedExerciseView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    @Environment(ExerciseProgressStore.self) private var progress: ExerciseProgressStore?
    let exerciseID: String
    @State private var stepIndex = 0
    @State private var fields: [String: String] = [:]
    @State private var restored = false
    @State private var finished = false
    @State private var showCancel = false
    @State private var saveError: String?

    private var item: ExerciseItem { ExerciseItem.additionalExercises.first { $0.id == exerciseID }! }
    private var steps: [GuidedExerciseStep] { GuidedExerciseContent.steps[exerciseID]! }
    private var step: GuidedExerciseStep { steps[min(stepIndex, steps.count - 1)] }
    private var accent: Color { item.category.accentColor }
    private var draftSnapshot: ExerciseDraft {
        var draft = ExerciseDraft(exerciseID: exerciseID)
        draft.step = stepIndex
        draft.fields = fields
        return draft
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(accentColor: accent, onBack: {
                if stepIndex > 0 { stepIndex -= 1 } else { showCancel = true }
            })
            if let figmaScreen = FigmaExerciseScreenCatalog.screen(
                for: exerciseID, step: stepIndex, selection: fields["mirror-clip-choice"]) {
                FigmaExerciseScreenView(
                    screen: figmaScreen,
                    accent: accent,
                    fields: $fields,
                    onNext: nextStep,
                    onCancel: { showCancel = true },
                    onFavorite: { progress?.toggleFavorite(exerciseID) }
                )
            } else {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    ExercisePageHeader(item: item, description: item.subtitle,
                        isFavorite: progress?.record(for: exerciseID).isFavorite == true,
                        onFavorite: { progress?.toggleFavorite(exerciseID) })
                    Divider()
                    Text("STEP \(stepIndex + 1) OF \(steps.count)")
                        .font(Theme.Typography.poppins(.semiBold, size: 11))
                        .foregroundStyle(accent)
                    Text(step.heading)
                        .font(Theme.Typography.poppins(.semiBold, size: 21))
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .accessibilityIdentifier("GuidedExerciseStepHeading")
                    ForEach(Array(step.instructions.enumerated()), id: \.offset) { _, instruction in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "heart.fill").font(.system(size: 11))
                                .foregroundStyle(accent).padding(.top, 5)
                            Text(instruction).font(Theme.Typography.poppins(.regular, size: 14))
                                .foregroundStyle(Theme.Colors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    if !step.options.isEmpty {
                        Text("Choose one").font(Theme.Typography.poppins(.semiBold, size: 15))
                        ForEach(step.options, id: \.self) { option in
                            Button {
                                fields["choice:\(stepIndex)"] = option
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: fields["choice:\(stepIndex)"] == option ? "largecircle.fill.circle" : "circle")
                                        .foregroundStyle(accent)
                                    Text(option).foregroundStyle(Theme.Colors.textPrimary)
                                    Spacer()
                                }
                                .font(Theme.Typography.poppins(.regular, size: 14))
                                .padding(14)
                                .background(accent.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    ForEach(Array(step.prompts.enumerated()), id: \.offset) { index, prompt in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(prompt).font(Theme.Typography.poppins(.medium, size: 14))
                            TextField("Write your thoughts (optional)", text: answerBinding(index), axis: .vertical)
                                .lineLimit(3...6)
                                .font(Theme.Typography.poppins(.regular, size: 14))
                                .padding(12)
                                .background(Color(hex: "#F8FAFC"), in: RoundedRectangle(cornerRadius: 12))
                                .accessibilityIdentifier("GuidedExerciseAnswer_\(index)")
                        }
                    }
                    if step.instructions.isEmpty && step.prompts.isEmpty && step.options.isEmpty {
                        Text(item.subtitle).font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, Theme.Spacing.headerTitleSpacing)
                .padding(.bottom, 24)
            }
            VStack(spacing: 6) {
                PrimaryButton(title: stepIndex == steps.count - 1 ? "Complete Exercise" : "Next",
                    trailingIcon: stepIndex == steps.count - 1 ? nil : "arrow.right",
                    accentColor: accent, action: nextStep)
                .accessibilityIdentifier("ExerciseFlowAction")
                Button("Cancel") { showCancel = true }
                    .font(Theme.Typography.poppins(.medium, size: 14))
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .frame(maxWidth: .infinity).frame(height: 38)
            }
            .padding(.horizontal, 20).padding(.vertical, 8)
            .background(.white)
            }
        }
        .background(.white)
        .overlay {
            if showCancel {
                ExerciseLeaveConfirmationView(onKeepEditing: { showCancel = false }, onLeave: {
                    showCancel = false
                    router?.pop()
                })
            }
        }
        .alert("Could not save exercise", isPresented: Binding(
            get: { saveError != nil }, set: { if !$0 { saveError = nil } }
        )) {
            Button("OK", role: .cancel) { saveError = nil }
        } message: { Text(saveError ?? "") }
        .task {
            if let draft = appEnvironment?.draftStore.exercise(for: exerciseID) {
                stepIndex = min(max(0, draft.step), steps.count - 1)
                fields = draft.fields
            }
            restored = true
            if appEnvironment?.draftStore.exercise(for: exerciseID) == nil {
                saveDraft(draftSnapshot)
            }
        }
        .onChange(of: draftSnapshot) { _, draft in
            if restored && !finished { saveDraft(draft) }
        }
    }

    private func answerBinding(_ index: Int) -> Binding<String> {
        let key = "answer:\(stepIndex):\(index)"
        return Binding(get: { fields[key] ?? "" }, set: { fields[key] = $0 })
    }

    private func saveDraft(_ draft: ExerciseDraft) {
        do { try appEnvironment?.draftStore.saveExercise(draft) }
        catch { saveError = "Your progress could not be saved. Please try again." }
    }

    private func complete() {
        do {
            try progress?.completeAndDiscard(exerciseID)
            finished = true
            router?.finishFlow(at: .exerciseCompleteFor(exerciseID))
        } catch {
            saveError = "Your exercise could not be completed. Please try again."
        }
    }

    private func nextStep() {
        if stepIndex < steps.count - 1 { stepIndex += 1 }
        else { complete() }
    }
}
