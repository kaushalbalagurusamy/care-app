import PhotosUI
import SwiftUI

// Figma frames 275:1237 and 743:215.
public struct KeepPhotoExerciseView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(ExerciseProgressStore.self) private var progress: ExerciseProgressStore?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photo: UIImage?
    @State private var isReflecting = false
    @State private var firstReflection = ""
    @State private var secondReflection = ""
    @State private var showCancelConfirmation = false
    @State private var loadError: String?
    @State private var photoAssetID: String?
    @State private var restoredDraft = false
    @State private var didComplete = false

    public init() {}

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderNavBar(accentColor: ExerciseCategory.calm.accentColor, onBack: {
                    if isReflecting { isReflecting = false } else { showCancelConfirmation = true }
                })
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        ExercisePageHeader(
                            item: ExerciseItem.sampleCalmExercises[1],
                            description: "Look at someone you love and let the warmth settle in. Your smart vagus nerve responds to feelings of connection."
                        )
                        Divider()
                        if isReflecting { reflectionCard } else { uploadStep }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    .padding(.bottom, 16)
                }
                VStack(spacing: 4) {
                    if isReflecting {
                        PrimaryButton(title: "Complete Exercise", isEnabled: photo != nil) {
                            guard photo != nil else { return }
                            guard !didComplete else { return }
                            do {
                                guard let progress else { throw CocoaError(.fileNoSuchFile) }
                                try progress.completeAndDiscard("keep-photo-close")
                                didComplete = true
                                router?.finishFlow(at: .exerciseCompleteFor("keep-photo-close"))
                            } catch { loadError = "Completion could not be saved. Please try again." }
                        }
                    } else {
                        PrimaryButton(title: "Next", trailingIcon: "arrow.right", isEnabled: photo != nil) {
                            isReflecting = true
                        }
                        .accessibilityIdentifier("KeepPhotoNextArrowButton")
                    }
                    Button("Cancel") { showCancelConfirmation = true }
                        .font(Theme.Typography.poppins(.medium, size: 13))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(.white)
            }
            .background(.white)
            if showCancelConfirmation {
                ExerciseLeaveConfirmationView(
                    onKeepEditing: { showCancelConfirmation = false },
                    onLeave: { showCancelConfirmation = false; router?.pop() }
                )
            }
        }
        .onChange(of: selectedPhoto) { _, newValue in
            guard let newValue else { return }
            Task {
                do {
                    guard let data = try await newValue.loadTransferable(type: Data.self),
                          let selected = UIImage(data: data) else {
                        loadError = "This photo could not be opened. Please choose another one."
                        return
                    }
                    photo = selected
                    photoAssetID = newValue.itemIdentifier
                    persistDraft()
                } catch {
                    loadError = "This photo could not be opened. Please choose another one."
                }
            }
        }
        .task {
            if let draft = appEnvironment?.draftStore.exercise(for: "keep-photo-close") {
                isReflecting = draft.step == 1
                firstReflection = draft.fields["firstReflection"] ?? ""
                secondReflection = draft.fields["secondReflection"] ?? ""
                photoAssetID = draft.photoAssetID
                if let photoAssetID {
                    photo = await ExercisePhotoReference.loadImage(assetID: photoAssetID)
                    if photo == nil {
                        isReflecting = false
                        loadError = "The saved photo is unavailable. Choose it again to continue."
                    }
                } else if isReflecting {
                    isReflecting = false
                    loadError = "Choose the photo again to continue."
                }
            }
            restoredDraft = true
            if appEnvironment?.draftStore.exercise(for: "keep-photo-close") == nil { persistDraft() }
        }
        .onChange(of: isReflecting) { _, _ in persistDraft() }
        .onChange(of: firstReflection) { _, _ in persistDraft() }
        .onChange(of: secondReflection) { _, _ in persistDraft() }
        .alert("Photo unavailable", isPresented: Binding(get: { loadError != nil }, set: { if !$0 { loadError = nil } })) {
            Button("OK", role: .cancel) { loadError = nil }
        } message: { Text(loadError ?? "") }
    }

    private func persistDraft() {
        guard restoredDraft, let appEnvironment else { return }
        var draft = ExerciseDraft(exerciseID: "keep-photo-close")
        draft.step = isReflecting ? 1 : 0
        draft.fields = ["firstReflection": firstReflection, "secondReflection": secondReflection]
        draft.photoAssetID = photoAssetID
        do { try appEnvironment.draftStore.saveExercise(draft) }
        catch { loadError = "Your exercise progress could not be saved. Please try again before leaving." }
    }

    private var uploadStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 10) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    VStack(spacing: 9) {
                        if let photo {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 175)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 25))
                        }
                        Text(photo == nil ? "Tap to upload a photo" : "Choose a different photo")
                            .font(Theme.Typography.poppins(.semiBold, size: 13))
                    }
                    .foregroundColor(Theme.Colors.primary)
                    .frame(maxWidth: .infinity, minHeight: 170)
                    .background(Color(hex: "#EAF4FF"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.Colors.primary, style: StrokeStyle(lineWidth: 1, dash: [4, 4])))
                }
                Text("Choose a photo of someone or something you love dearly — a partner, family member, pet, friend, or a special moment together.")
                    .font(Theme.Typography.poppins(.regular, size: 12))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(14)
            .background(Color(hex: "#EAF4FF"))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 12) {
                Text("Once you've uploaded your photo")
                    .font(Theme.Typography.poppins(.bold, size: 13))
                prompt("Look at the photo for 1–2 minutes")
                prompt("Think about a happy memory you share with this person or being")
                prompt("Notice any warmth, calm, or connection you feel in your body")
                Divider()
                Text("Save this photo somewhere easy to find — your lock screen, wallet, or favorites — so it’s always there when you need it.")
                    .font(Theme.Typography.poppins(.regular, size: 11).italic())
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(15)
            .background(Color(hex: "#EAF4FF"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var reflectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pause and reflect")
                .font(Theme.Typography.poppins(.bold, size: 14))
            Text("After looking at the photo, do you notice any warmth, calm, or shift in your body?")
                .font(Theme.Typography.poppins(.semiBold, size: 12))
            TextField("Tap to write a reflection...", text: $firstReflection, axis: .vertical)
                .lineLimit(3...5)
                .padding(11)
                .background(Color(hex: "#EAF4FF"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#93C5FD")))
            Text("What did you notice?")
                .font(Theme.Typography.poppins(.semiBold, size: 12))
            TextField("Tap to write a reflection...", text: $secondReflection, axis: .vertical)
                .lineLimit(3...5)
                .padding(11)
                .background(Color(hex: "#EAF4FF"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#93C5FD")))
            Divider()
            Text("Both reflections are optional. There is no right answer.")
                .font(Theme.Typography.poppins(.regular, size: 11).italic())
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(16)
        .background(Color(hex: "#EAF4FF"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func prompt(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: "heart.fill").foregroundColor(Theme.Colors.primary)
            Text(text).foregroundColor(Theme.Colors.textPrimary)
        }
        .font(Theme.Typography.poppins(.regular, size: 12))
    }
}

#Preview { KeepPhotoExerciseView() }
