import AVKit
import MessageUI
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import WebKit

// Bundle rendered color glyphs so the exercise artwork does not depend on the
// active text font's emoji fallback (which can display a missing-glyph box).
enum ExerciseEmojiAsset {
    static let names: [String: String] = [
        "🎬": "clapper", "📷": "camera", "👥": "people", "💬": "chat",
        "🎥": "video", "💡": "bulb", "⌛": "hourglass", "😂": "laugh",
        "💭": "thought", "🫶": "heart_hands", "✨": "sparkles", "➕": "plus",
        "🍲": "stew", "🎵": "music", "💃": "dancer", "📸": "camera_flash",
        "😄": "smile", "🔥": "fire"
    ]

    static func name(for emoji: String) -> String? {
        if let name = names[emoji] { return "ExerciseEmoji_\(name)" }
        let codepoints = emoji.unicodeScalars
            .map { String($0.value, radix: 16) }
            .joined(separator: "_")
        let generated = "ExerciseEmoji_u\(codepoints)"
        return UIImage(named: generated) == nil ? nil : generated
    }
}

struct ExerciseEmojiView: View {
    let emoji: String
    let size: CGFloat

    var body: some View {
        Group {
            if let asset = ExerciseEmojiAsset.name(for: emoji) {
                Image(asset).resizable().scaledToFit()
            } else {
                Text(emoji)
                    .font(.system(size: size))
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel(emoji)
    }
}

struct ExercisePageHeader: View {
    let item: ExerciseItem
    let description: String
    var isFavorite = false
    var onFavorite: (() -> Void)? = nil

    private var accent: Color { item.category.exerciseAccent }
    private var soft: Color { accent.opacity(0.08) }
    private var showsPRM: Bool {
        item.id == "keep-photo-close" || item.id == "accepted-moments-library"
            || item.id == "save-a-resonant-moment" || item.id == "revisit-an-early-spark"
            || item.id == "recall-a-warm-connection"
    }
    private var prmColors: (fill: Color, text: Color, border: Color) {
        switch item.id {
        case "keep-photo-close":
            return (Color(hex: "#DCEEFF"), Color(hex: "#1F66B1"), Color(hex: "#A8D2FF"))
        case "accepted-moments-library":
            return (Color(hex: "#DFF7EE"), Color(hex: "#1F8065"), Color(hex: "#A8E6D1"))
        case "save-a-resonant-moment":
            return (Color(hex: "#F0EBFF"), Color(hex: "#6652A8"), Color(hex: "#CFC2F2"))
        case "revisit-an-early-spark", "recall-a-warm-connection":
            return (Color(hex: "#FFF0DB"), Color(hex: "#A65C1F"), Color(hex: "#F5D1A8"))
        default:
            return (accent, .white, accent)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ExerciseEmojiView(emoji: item.emoji, size: 36)
                .frame(width: 56, height: 56)
                .background(soft, in: Circle())
                .overlay(Circle().stroke(accent.opacity(0.35)))
                .accessibilityIdentifier("ExerciseHeaderEmoji")
            HStack(spacing: 8) {
                Text(item.category.rawValue.uppercased())
                    .foregroundStyle(accent)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(soft, in: Capsule())
                Text("◷ \(item.durationMinutesRange)")
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color(hex: "#F8FAFC"), in: Capsule())
                if showsPRM {
                    Text("PRM")
                        .foregroundStyle(prmColors.text)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(prmColors.fill, in: Capsule())
                        .overlay(Capsule().stroke(prmColors.border, lineWidth: 1))
                }
            }
            .font(Theme.Typography.poppins(.semiBold, size: 11))
            ZStack(alignment: .trailing) {
                Text(item.title)
                    .font(Theme.Typography.poppins(.bold, size: 26))
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, onFavorite == nil ? 0 : 36)
                if let onFavorite {
                    Button(action: onFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(accent)
                            .frame(width: 32, height: 32)
                            .background(soft, in: Circle())
                    }
                    .accessibilityLabel("Favorite \(item.title)")
                }
            }
            Text(description)
                .font(Theme.Typography.poppins(.regular, size: 14))
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("ExerciseDescription")
        }
        .frame(maxWidth: .infinity)
    }
}

// Shared layout for the Figma exercise pages: 530, 556, 568, 569 and 574.
private struct ExerciseFlowPage<Content: View>: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(ExerciseProgressStore.self) private var progress: ExerciseProgressStore?
    let item: ExerciseItem
    let description: String
    let actionTitle: String
    let actionEnabled: Bool
    let onBack: () -> Void
    let onAction: () -> Void
    @Binding var showCancel: Bool
    @ViewBuilder let content: Content

    private var accent: Color { item.category.exerciseAccent }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderNavBar(accentColor: accent, onBack: onBack)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        ExercisePageHeader(
                            item: item,
                            description: description,
                            isFavorite: progress?.record(for: item.id).isFavorite == true,
                            onFavorite: { progress?.toggleFavorite(item.id) }
                        )
                        Divider()
                        content
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    .padding(.bottom, 22)
                }
                VStack(spacing: 6) {
                    PrimaryButton(title: actionTitle, trailingIcon: actionTitle == "Next" ? "arrow.right" : nil,
                                  isEnabled: actionEnabled, accentColor: accent, action: onAction)
                        .accessibilityIdentifier("ExerciseFlowAction")
                    Button("Cancel") { showCancel = true }
                        .font(Theme.Typography.poppins(.medium, size: 14))
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .frame(maxWidth: .infinity).frame(height: 38)
                }
                .padding(.horizontal, 20).padding(.vertical, 8)
                .background(.white)
            }
            .background(.white)
            if showCancel {
                ExerciseLeaveConfirmationView(onKeepEditing: { showCancel = false }, onLeave: {
                    showCancel = false
                    router?.pop()
                })
            }
        }
    }
}

private extension ExerciseCategory {
    var exerciseAccent: Color { accentColor }
}

public enum ShareExerciseKind { case small, new }

private struct ShareChoice: Identifiable {
    let title: String
    let emoji: String
    let description: String
    let messageTitle: String
    let messagePrompt: String
    let mediaPrompt: String
    let requiredMedia: MediaRequirement
    var id: String { title }

    enum MediaRequirement { case none, photo, video }
}

// Figma 530:94 → 534:107 / 542:102 and 569:94 → 570:94 / 574:95.
public struct ShareExerciseView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(ExerciseProgressStore.self) private var progress: ExerciseProgressStore?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    public let kind: ShareExerciseKind
    @State private var step = 0
    @State private var selectedIndex: Int?
    @State private var customIdea = ""
    @State private var message = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photo: UIImage?
    @State private var selectedVideo: PhotosPickerItem?
    @State private var videoURL: URL?
    @State private var showCancel = false
    @State private var showMessageComposer = false
    @State private var messageUnavailable = false
    @State private var mediaError: String?
    @State private var photoAssetID: String?
    @State private var videoAssetID: String?
    @State private var videoAssetAvailable = false
    @State private var restoredDraft = false
    @State private var didComplete = false

    public init(kind: ShareExerciseKind) { self.kind = kind }

    private var item: ExerciseItem {
        ExerciseItem.allExercises.first { $0.id == (kind == .small ? "share-something-small" : "share-something-new") }!
    }
    private var selected: ShareChoice? {
        guard let selectedIndex, choices.indices.contains(selectedIndex) else { return nil }
        return choices[selectedIndex]
    }
    private var canComplete: Bool {
        guard let selected else { return false }
        if selected.requiredMedia == .photo { return photo != nil }
        if selected.requiredMedia == .video { return videoURL != nil || videoAssetAvailable }
        return !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var accent: Color { item.category.exerciseAccent }
    private var soft: Color { accent.opacity(0.08) }
    private var draftSnapshot: ExerciseDraft {
        var draft = ExerciseDraft(exerciseID: item.id)
        draft.step = step
        draft.fields = ["selectedIndex": selectedIndex.map(String.init) ?? "", "customIdea": customIdea, "message": message]
        draft.photoAssetID = photoAssetID
        draft.videoAssetID = videoAssetID
        return draft
    }
    private var choices: [ShareChoice] {
        if kind == .small {
            return [
                .init(title: "A photo from your day", emoji: "📷", description: "Share a photo from your day with someone you trust.", messageTitle: "Write a few words", messagePrompt: "Write a few words to go with your photo…", mediaPrompt: "Choose a photo from your day or one that shows what you’d like to share.", requiredMedia: .photo),
                .init(title: "Something that made you laugh", emoji: "😂", description: "Tell someone about a moment that made you laugh.", messageTitle: "Craft your message", messagePrompt: "Write a few words about what made you laugh…", mediaPrompt: "Choose a photo of the funny moment or something that makes you smile.", requiredMedia: .none),
                .init(title: "A thought you’ve been having", emoji: "💭", description: "Let someone into a thought you’ve been having.", messageTitle: "Share your thought", messagePrompt: "Write a few words about what’s been on your mind…", mediaPrompt: "Choose a photo that connects to your thought or helps bring it to life.", requiredMedia: .none),
                .init(title: "A recent interaction that moved you", emoji: "🫶", description: "Share an interaction that stayed with you.", messageTitle: "Share what happened", messagePrompt: "Write a few words about the interaction and what stayed with you…", mediaPrompt: "Choose a photo that reminds you of the moment or the person you shared it with.", requiredMedia: .none),
                .init(title: "A tiny win or something exciting", emoji: "✨", description: "Invite someone into a small win or exciting moment.", messageTitle: "Share your moment", messagePrompt: "Write a few words about your win or something you’re excited about…", mediaPrompt: "Choose a photo that captures the moment or what you’re celebrating.", requiredMedia: .none),
                .init(title: "Add another idea", emoji: "➕", description: "Share any small part of your world.", messageTitle: "Share what’s on your mind", messagePrompt: "Write a few words about whatever you’d like to share…", mediaPrompt: "Choose a photo that goes along with what you want to share.", requiredMedia: .none)
            ]
        }
        return [
            .init(title: "A recipe you enjoyed or want to share", emoji: "🍲", description: "Share a recipe you tried, saved, or want to make. Tell them why you thought of them.", messageTitle: "Write a few words", messagePrompt: "What makes this recipe worth sharing?", mediaPrompt: "Choose a photo of the dish or recipe you want to share.", requiredMedia: .photo),
            .init(title: "A song or lyrics you’ve been enjoying", emoji: "🎵", description: "Share a song or lyric that has stayed with you and the feeling it brings up.", messageTitle: "Share what you enjoy", messagePrompt: "What song or lyric stayed with you, and why?", mediaPrompt: "Add a photo if it helps tell the story.", requiredMedia: .none),
            .init(title: "A dance or skill you’re learning", emoji: "💃", description: "Share something new you are practicing or exploring.", messageTitle: "Tell them about it", messagePrompt: "What are you learning, and how does it feel?", mediaPrompt: "Add a photo or short clip of your progress.", requiredMedia: .none),
            .init(title: "A photo of a new look or outfit", emoji: "📸", description: "Share a haircut, outfit, or look that makes you feel like yourself.", messageTitle: "Write a few words", messagePrompt: "What do you like about this look?", mediaPrompt: "Choose a photo of your new look or outfit.", requiredMedia: .photo),
            .init(title: "Something interesting you discovered", emoji: "💡", description: "Share a fact, article, place, meme, or idea that made you curious.", messageTitle: "Share your discovery", messagePrompt: "What did you discover, and why did it catch your attention?", mediaPrompt: "Add a photo if you have one.", requiredMedia: .none),
            .init(title: "A funny moment or video", emoji: "😄", description: "Share something that made you laugh and invite someone else into the moment.", messageTitle: "Tell them why it’s funny", messagePrompt: "What made this moment so funny?", mediaPrompt: "Add a photo or video of the moment.", requiredMedia: .none),
            .init(title: "A video of something new you tried", emoji: "🎬", description: "Share a short clip of something you made, learned, tried, or experienced for the first time.", messageTitle: "Write a few words", messagePrompt: "What was new or memorable about this video?", mediaPrompt: "Choose a short clip of something new you tried.", requiredMedia: .video),
            .init(title: "Add your own idea", emoji: "➕", description: "Share any small discovery, change, or moment you would enjoy letting someone else see.", messageTitle: "Share your idea", messagePrompt: "What would you like someone to know?", mediaPrompt: "Add a photo or short video if you like.", requiredMedia: .none)
        ]
    }

    public var body: some View {
        ExerciseFlowPage(item: item,
                         description: step == 0 ? (kind == .small ? "What’s one small part of your world you could let someone into today? Choose something simple to share." : "Share something you discovered, tried, or enjoyed with someone who might love it too.") : (selected?.description ?? ""),
                         actionTitle: step == 0 ? "Next" : "Complete Exercise",
                         actionEnabled: step == 0 ? selected != nil && (!(selected?.title.hasPrefix("Add ") ?? false) || !customIdea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) : canComplete,
                         onBack: { if step == 1 { step = 0 } else { showCancel = true } },
                         onAction: {
                             if step == 0 { step = 1 }
                             else {
                                 guard !didComplete else { return }
                                 do {
                                     guard let progress else { throw CocoaError(.fileNoSuchFile) }
                                     try progress.completeAndDiscard(item.id)
                                     didComplete = true
                                     router?.finishFlow(at: .exerciseCompleteFor(item.id))
                                 } catch { mediaError = "Completion could not be saved. Please try again." }
                             }
                         }, showCancel: $showCancel) {
            if step == 0 { choiceStep } else if let selected { composeStep(selected) }
        }
        .onChange(of: selectedPhoto) { _, selection in
            Task {
                guard let selection else { return }
                do {
                    guard let data = try await selection.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { throw CocoaError(.fileReadCorruptFile) }
                    photo = image
                    photoAssetID = selection.itemIdentifier
                } catch { mediaError = "This photo could not be opened. Please choose another one." }
            }
        }
        .onChange(of: selectedVideo) { _, selection in
            Task {
                guard let selection else { return }
                do {
                    guard let newURL = try await selection.loadTransferable(type: PickedExerciseMovie.self)?.url else { throw CocoaError(.fileReadCorruptFile) }
                    if let videoURL { try? FileManager.default.removeItem(at: videoURL) }
                    videoURL = newURL
                    videoAssetID = selection.itemIdentifier
                    videoAssetAvailable = videoAssetID != nil
                } catch { mediaError = "This video could not be opened. Please choose another one." }
            }
        }
        .sheet(isPresented: $showMessageComposer) {
            ExerciseMessageComposer(body: message, photo: photo, videoURL: videoURL) { _ in
                showMessageComposer = false
            }
        }
        .alert("Messages unavailable", isPresented: $messageUnavailable) {
            Button("OK", role: .cancel) {}
        } message: { Text("Text messaging is not available on this device. You can still complete the exercise after preparing your message or media.") }
        .alert("Media unavailable", isPresented: Binding(get: { mediaError != nil }, set: { if !$0 { mediaError = nil } })) {
            Button("OK", role: .cancel) { mediaError = nil }
        } message: { Text(mediaError ?? "") }
        .task {
            if let draft = appEnvironment?.draftStore.exercise(for: item.id) {
                step = draft.step
                selectedIndex = Int(draft.fields["selectedIndex"] ?? "")
                customIdea = draft.fields["customIdea"] ?? ""
                message = draft.fields["message"] ?? ""
                photoAssetID = draft.photoAssetID
                videoAssetID = draft.videoAssetID
                if let photoAssetID {
                    photo = await ExercisePhotoReference.loadImage(assetID: photoAssetID)
                    if photo == nil { mediaError = "The saved photo is unavailable. Choose it again to continue." }
                }
                if let videoAssetID {
                    videoAssetAvailable = await ExercisePhotoReference.loadVideoPlayer(assetID: videoAssetID) != nil
                    if !videoAssetAvailable { mediaError = "The saved video is unavailable. Choose it again to continue." }
                }
            }
            restoredDraft = true
            if appEnvironment?.draftStore.exercise(for: item.id) == nil {
                do { try appEnvironment?.draftStore.saveExercise(draftSnapshot) }
                catch { mediaError = "Your exercise progress could not be saved. Please try again." }
            }
        }
        .onChange(of: draftSnapshot) { _, draft in
            guard restoredDraft, !didComplete, let appEnvironment else { return }
            do { try appEnvironment.draftStore.saveExercise(draft) }
            catch { mediaError = "Your exercise progress could not be saved. Please try again before leaving." }
        }
        .onDisappear {
            if let videoURL { try? FileManager.default.removeItem(at: videoURL) }
            videoURL = nil
        }
    }

    private var choiceStep: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Pick one to share").font(Theme.Typography.poppins(.semiBold, size: 14))
                Spacer()
                Text("Choose one").font(Theme.Typography.poppins(.regular, size: 12)).foregroundStyle(accent)
            }
            ForEach(Array(choices.enumerated()), id: \.offset) { index, choice in
                Button {
                    if selectedIndex != index {
                        message = ""
                        photo = nil
                        selectedPhoto = nil
                        photoAssetID = nil
                        videoURL = nil
                        selectedVideo = nil
                        videoAssetID = nil
                        videoAssetAvailable = false
                        customIdea = ""
                    }
                    selectedIndex = index
                } label: {
                    HStack(spacing: 12) {
                        ExerciseEmojiView(emoji: choice.emoji, size: 19)
                            .frame(width: 30, height: 30).background(accent.opacity(0.13), in: Circle())
                        Text(choice.title).font(Theme.Typography.poppins(.regular, size: 13))
                        Spacer()
                        Image(systemName: selectedIndex == index ? "checkmark" : "chevron.right")
                    }
                    .foregroundStyle(selectedIndex == index ? accent : Theme.Colors.textSecondary)
                    .padding(.horizontal, 12).frame(height: 52)
                    .background(selectedIndex == index ? soft : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(accent.opacity(selectedIndex == index ? 1 : 0.45)))
                }
                .buttonStyle(.plain)
            }
            if let selected, selected.title.hasPrefix("Add ") {
                TextField("What would you like to share?", text: $customIdea)
                    .font(Theme.Typography.poppins(.regular, size: 13))
                    .padding(12).background(soft, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func composeStep(_ selected: ShareChoice) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ExerciseEmojiView(emoji: selected.emoji, size: 22)
                    .frame(width: 34, height: 34).background(.white, in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("YOU CHOSE").font(Theme.Typography.poppins(.bold, size: 9)).foregroundStyle(accent)
                    Text(customIdea.isEmpty ? selected.title : customIdea)
                        .font(Theme.Typography.poppins(.semiBold, size: 13))
                }
                Spacer()
            }
            .padding(11).background(soft, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(accent.opacity(0.4)))

            if selected.requiredMedia == .photo || selected.requiredMedia == .video {
                mediaSection(selected, number: 1)
                messageSection(selected, number: 2, optional: true)
            } else {
                messageSection(selected, number: 1, optional: false)
                mediaSection(selected, number: 2)
            }
            Text("Step 3: Share with someone you trust")
                .font(Theme.Typography.poppins(.semiBold, size: 13))
            Button {
                if videoAssetAvailable && videoURL == nil {
                    mediaError = "Choose your video again to attach it to a message. Your exercise progress is saved."
                } else if MFMessageComposeViewController.canSendText() { showMessageComposer = true }
                else { messageUnavailable = true }
            } label: {
                HStack(spacing: 11) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17))
                        .frame(width: 39, height: 39)
                        .overlay(Circle().stroke(accent))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Choose someone to share with")
                            .font(Theme.Typography.poppins(.semiBold, size: 12))
                        Text("Send your message or media directly")
                            .font(Theme.Typography.poppins(.regular, size: 10))
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(accent)
                .padding(10)
                .background(soft, in: RoundedRectangle(cornerRadius: 13))
                .overlay(RoundedRectangle(cornerRadius: 13).stroke(accent.opacity(0.45)))
            }
            .buttonStyle(.plain)
            Text(selected.requiredMedia == .photo ? "A photo is required. Your message is optional." : selected.requiredMedia == .video ? "A video is required. Your message is optional." : "A message is required. Media is optional.")
                .font(Theme.Typography.poppins(.regular, size: 11))
                .foregroundStyle(accent).frame(maxWidth: .infinity)
        }
    }

    private func messageSection(_ choice: ShareChoice, number: Int, optional: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Step \(number): \(choice.messageTitle)")
                    .font(Theme.Typography.poppins(.semiBold, size: 13))
                Spacer()
                if optional { Text("Optional").font(Theme.Typography.poppins(.regular, size: 11).italic()).foregroundStyle(Theme.Colors.textSecondary) }
            }
            TextField(choice.messagePrompt, text: $message, axis: .vertical)
                .lineLimit(3...5)
                .font(Theme.Typography.poppins(.regular, size: 12))
                .padding(12).background(soft, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(accent.opacity(0.35)))
        }
    }

    private func mediaSection(_ choice: ShareChoice, number: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Step \(number): \(choice.requiredMedia == .video ? "Upload your video" : choice.requiredMedia == .photo ? "Upload your photo" : kind == .small ? "Add a photo" : "Add a photo or video")")
                    .font(Theme.Typography.poppins(.semiBold, size: 13))
                Spacer()
                if choice.requiredMedia == .none { Text("Optional").font(Theme.Typography.poppins(.regular, size: 11).italic()).foregroundStyle(Theme.Colors.textSecondary) }
            }
            VStack(spacing: 9) {
                if choice.requiredMedia != .video {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        mediaPickerLabel(photo == nil ? "Tap to upload a photo" : "Photo selected", image: photo, systemName: "photo")
                    }
                }
                if choice.requiredMedia == .video || (kind == .new && choice.requiredMedia == .none) {
                    PhotosPicker(selection: $selectedVideo, matching: .videos) {
                        mediaPickerLabel(videoURL == nil && !videoAssetAvailable ? "Tap to upload a video" : "Video selected", image: nil, systemName: "video")
                    }
                }
                Text(choice.mediaPrompt)
                    .font(Theme.Typography.poppins(.regular, size: 11))
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(13).background(soft, in: RoundedRectangle(cornerRadius: 15))
        }
    }

    private func mediaPickerLabel(_ title: String, image: UIImage?, systemName: String) -> some View {
        VStack(spacing: 7) {
            if let image {
                Image(uiImage: image).resizable().scaledToFit().frame(maxHeight: 145)
            } else {
                Image(systemName: systemName == "video" ? "video.badge.plus" : "plus")
                    .font(.system(size: 22, weight: .medium))
                    .frame(width: 44, height: 44)
                    .background(.white, in: Circle())
            }
            Text(title).font(Theme.Typography.poppins(.semiBold, size: 12))
        }
        .foregroundStyle(accent)
        .frame(maxWidth: .infinity, minHeight: image == nil ? 130 : 170)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(accent, style: StrokeStyle(lineWidth: 1, dash: [5, 4])))
    }
}

private struct ExerciseMessageComposer: UIViewControllerRepresentable {
    let body: String
    let photo: UIImage?
    let videoURL: URL?
    let onFinish: (MessageComposeResult) -> Void

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.body = body
        if MFMessageComposeViewController.canSendAttachments() {
            if let photo, let data = photo.jpegData(compressionQuality: 0.8) {
                controller.addAttachmentData(data, typeIdentifier: UTType.jpeg.identifier, filename: "care-photo.jpeg")
            }
            if let videoURL {
                controller.addAttachmentURL(videoURL, withAlternateFilename: "care-video.mov")
            }
        }
        return controller
    }
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(onFinish: onFinish) }

    final class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let onFinish: (MessageComposeResult) -> Void
        init(onFinish: @escaping (MessageComposeResult) -> Void) { self.onFinish = onFinish }
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            onFinish(result)
        }
    }
}

public enum MirrorExerciseKind { case emotion, lovedOne }

// Figma 556:94 → 556:253 and 568:94 → 568:178.
public struct MirrorExerciseView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(ExerciseProgressStore.self) private var progress: ExerciseProgressStore?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    public let kind: MirrorExerciseKind
    @State private var step = 0
    @State private var showCancel = false
    @State private var showVideo = false
    @State private var selectedVideo: PhotosPickerItem?
    @State private var videoURL: URL?
    @State private var videoPlayer: AVPlayer?
    @State private var videoAssetID: String?
    @State private var videoError: String?
    @State private var reflectionOne = ""
    @State private var reflectionTwo = ""
    @State private var reflectionThree = ""
    @State private var connectionWhen: String?
    @State private var restoredDraft = false
    @State private var didComplete = false

    public init(kind: MirrorExerciseKind) { self.kind = kind }
    private var item: ExerciseItem {
        ExerciseItem.allExercises.first { $0.id == (kind == .emotion ? "mirror-emotion" : "mirror-loved-one") }!
    }
    private var accent: Color { item.category.exerciseAccent }
    private var soft: Color { accent.opacity(0.08) }
    private var draftSnapshot: ExerciseDraft {
        var draft = ExerciseDraft(exerciseID: item.id)
        draft.step = step
        draft.fields = ["reflectionOne": reflectionOne, "reflectionTwo": reflectionTwo, "reflectionThree": reflectionThree, "connectionWhen": connectionWhen ?? ""]
        draft.videoAssetID = videoAssetID
        return draft
    }
    private var intro: String {
        if kind == .emotion { return "Watch a few short expressions, mirror them gently, and notice what shifts in your mood or body." }
        return step == 0 ? "Upload a video of someone you love, then watch their expression and notice what shifts in you." : "Watch someone you love and notice what shifts in your own expression, feelings, or sense of connection."
    }

    public var body: some View {
        ExerciseFlowPage(item: item, description: intro,
                         actionTitle: step == 0 ? "Next" : "Complete Exercise",
                         actionEnabled: kind == .emotion || videoURL != nil || videoPlayer != nil,
                         onBack: { if step == 1 { step = 0 } else { showCancel = true } },
                         onAction: {
                             if step == 0 { step = 1 }
                             else {
                                 guard !didComplete else { return }
                                 do {
                                     guard let progress else { throw CocoaError(.fileNoSuchFile) }
                                     try progress.completeAndDiscard(item.id)
                                     didComplete = true
                                     router?.finishFlow(at: .exerciseCompleteFor(item.id))
                                 } catch { videoError = "Completion could not be saved. Please try again." }
                             }
                         }, showCancel: $showCancel) {
            if step == 0 {
                if kind == .emotion { emotionVideoCard } else { lovedOneUploadCard }
            } else {
                reflectionCard
            }
        }
        .fullScreenCover(isPresented: $showVideo) {
            ZStack(alignment: .topLeading) {
                Color.black.ignoresSafeArea()
                if kind == .emotion {
                    MirrorYouTubePlayer(videoID: "XS7cC4rj1VU") { showVideo = false }
                        .ignoresSafeArea()
                } else if let videoPlayer {
                    VideoPlayer(player: videoPlayer).ignoresSafeArea().onAppear { videoPlayer.play() }
                } else if let videoURL {
                    ExerciseLocalVideoPlayer(url: videoURL).ignoresSafeArea()
                }
                Button { showVideo = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 31))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(.black.opacity(0.5), in: Circle())
                }
                .padding(.leading, 12)
                .padding(.top, 8)
                .accessibilityLabel("Close video")
                .accessibilityIdentifier("MirrorVideoCloseButton")
            }
        }
        .onChange(of: selectedVideo) { _, selection in
            Task {
                guard let selection else { return }
                do {
                    if let id = selection.itemIdentifier {
                        guard let player = await ExercisePhotoReference.loadVideoPlayer(assetID: id) else { throw CocoaError(.fileReadCorruptFile) }
                        videoAssetID = id
                        videoPlayer = player
                    } else {
                        guard let newURL = try await selection.loadTransferable(type: PickedExerciseMovie.self)?.url else { throw CocoaError(.fileReadCorruptFile) }
                        if let videoURL { try? FileManager.default.removeItem(at: videoURL) }
                        videoURL = newURL
                        videoAssetID = nil
                    }
                } catch { videoError = "This video could not be opened. Please choose another one." }
            }
        }
        .alert("Video unavailable", isPresented: Binding(get: { videoError != nil }, set: { if !$0 { videoError = nil } })) {
            Button("OK", role: .cancel) { videoError = nil }
        } message: { Text(videoError ?? "") }
        .task {
            if let draft = appEnvironment?.draftStore.exercise(for: item.id) {
                step = draft.step
                reflectionOne = draft.fields["reflectionOne"] ?? ""
                reflectionTwo = draft.fields["reflectionTwo"] ?? ""
                reflectionThree = draft.fields["reflectionThree"] ?? ""
                connectionWhen = draft.fields["connectionWhen"].flatMap { $0.isEmpty ? nil : $0 }
                videoAssetID = draft.videoAssetID
                if let videoAssetID {
                    videoPlayer = await ExercisePhotoReference.loadVideoPlayer(assetID: videoAssetID)
                    if videoPlayer == nil {
                        step = 0
                        videoError = "The saved video is unavailable. Choose it again to continue."
                    }
                } else if kind != .emotion && step == 1 {
                    step = 0
                    videoError = "Choose the video again to continue."
                }
            }
            restoredDraft = true
            if appEnvironment?.draftStore.exercise(for: item.id) == nil {
                do { try appEnvironment?.draftStore.saveExercise(draftSnapshot) }
                catch { videoError = "Your exercise progress could not be saved. Please try again." }
            }
        }
        .onChange(of: draftSnapshot) { _, draft in
            guard restoredDraft, !didComplete, let appEnvironment else { return }
            do { try appEnvironment.draftStore.saveExercise(draft) }
            catch { videoError = "Your exercise progress could not be saved. Please try again before leaving." }
        }
        .onDisappear {
            videoPlayer?.pause()
            if let videoURL { try? FileManager.default.removeItem(at: videoURL) }
            videoURL = nil
        }
    }

    private var emotionVideoCard: some View {
        let cardWidth = min(350, UIScreen.main.bounds.width - 40)
        let scale = cardWidth / 350
        return HStack {
            Spacer(minLength: 0)
            Button { showVideo = true } label: {
                VStack(spacing: 16 * scale) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 318 * scale, height: 424 * scale)
                        .overlay {
                            Image("exercise_mirror_emotion")
                                .resizable()
                                .scaledToFill()
                                .accessibilityHidden(true)
                        }
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 14 * scale))
                        .overlay {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20 * scale))
                                .foregroundStyle(accent)
                                .frame(width: 48 * scale, height: 48 * scale)
                                .background(.white, in: Circle())
                                .overlay(Circle().stroke(Color(hex: "#D8B4FE"), lineWidth: 1))
                        }
                    Text("Tap to play the video")
                        .font(Theme.Typography.poppins(.regular, size: 12 * scale))
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .frame(height: 21 * scale)
                }
                .padding(16 * scale)
                .frame(width: cardWidth, height: 493 * scale)
                .background(soft, in: RoundedRectangle(cornerRadius: 18 * scale))
            }
            .buttonStyle(.plain)
            .frame(width: cardWidth, height: 493 * scale)
            .contentShape(RoundedRectangle(cornerRadius: 18 * scale))
            .clipped()
            .accessibilityIdentifier("MirrorEmotionPreviewButton")
            Spacer(minLength: 0)
        }
    }

    private var lovedOneUploadCard: some View {
        VStack(spacing: 11) {
            PhotosPicker(selection: $selectedVideo, matching: .videos) {
                VStack(spacing: 12) {
                    Image(systemName: videoURL == nil && videoPlayer == nil ? "plus" : "checkmark")
                        .font(.system(size: 22, weight: .medium))
                        .frame(width: 48, height: 48)
                        .background(.white, in: Circle())
                    Text(videoURL == nil && videoPlayer == nil ? "Tap to upload a video" : "Video selected — tap to change")
                        .font(Theme.Typography.poppins(.semiBold, size: 13))
                }
                .foregroundStyle(accent)
                .frame(maxWidth: .infinity).frame(height: 195)
                .overlay(RoundedRectangle(cornerRadius: 13).stroke(accent.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [5, 5])))
            }
            Text("Choose a short video of someone you love — a partner, family member, pet, or friend — in a moment that feels meaningful to you.")
                .font(Theme.Typography.poppins(.regular, size: 12))
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .padding(15).background(soft, in: RoundedRectangle(cornerRadius: 16))
    }

    private var reflectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            if kind == .lovedOne, videoURL != nil || videoPlayer != nil {
                Button { showVideo = true } label: {
                    Label("Watch your selected video", systemImage: "play.circle.fill")
                        .font(Theme.Typography.poppins(.semiBold, size: 13))
                        .foregroundStyle(accent)
                        .frame(maxWidth: .infinity, minHeight: 70)
                        .background(soft, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            Text("Pause and reflect")
                .font(Theme.Typography.poppins(.bold, size: 16))
            reflectionField(kind == .emotion ? "Did you notice a shift in your mood?" : "What emotion do you notice in their face?", text: $reflectionOne)
            reflectionField(kind == .emotion ? "Where did you feel the emotion in your body?" : "What do you notice in your own face or body?", text: $reflectionTwo)
            reflectionField(kind == .emotion ? "How did mirroring feel: natural, energizing, calming, or uncomfortable?" : "Did mirroring bring warmth, softness, or another shift?", text: $reflectionThree)
            if kind == .lovedOne {
                Text("When do you expect to connect?")
                    .font(Theme.Typography.poppins(.semiBold, size: 13))
                HStack(spacing: 7) {
                    ForEach(["Today", "Tomorrow", "This week", "Later"], id: \.self) { option in
                        Button(option) { connectionWhen = option }
                            .font(Theme.Typography.poppins(.medium, size: 11))
                            .foregroundStyle(connectionWhen == option ? .white : accent)
                            .padding(.horizontal, 9).frame(height: 31)
                            .background(connectionWhen == option ? accent : .white, in: Capsule())
                            .overlay(Capsule().stroke(accent))
                    }
                }
            }
            Divider()
            Text(kind == .emotion ? "There are no right or wrong answers. Simply notice what changed for you." : "The goal is simply to notice how a familiar expression affects your own state.")
                .font(Theme.Typography.poppins(.regular, size: 11).italic())
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .padding(16).background(soft, in: RoundedRectangle(cornerRadius: 16))
    }

    private func reflectionField(_ question: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question).font(Theme.Typography.poppins(.semiBold, size: 12))
            TextField("Tap to write a reflection…", text: text, axis: .vertical)
                .lineLimit(2...4)
                .font(Theme.Typography.poppins(.regular, size: 12))
                .padding(11).background(.white, in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(accent.opacity(0.4)))
        }
    }
}

private struct ExerciseLocalVideoPlayer: View {
    let url: URL
    @State private var player: AVPlayer?
    var body: some View {
        Group {
            if let player { VideoPlayer(player: player) }
            else { ProgressView() }
        }
        .onAppear { player = AVPlayer(url: url); player?.play() }
        .onDisappear { player?.pause(); player = nil }
    }
}

private struct MirrorYouTubePlayer: UIViewRepresentable {
    let videoID: String
    let onEnded: () -> Void
    func makeCoordinator() -> Coordinator { Coordinator(onEnded: onEnded) }
    func makeUIView(context: Context) -> WKWebView {
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "videoEnded")
        let config = WKWebViewConfiguration()
        config.userContentController = controller
        config.allowsInlineMediaPlayback = true
        let view = WKWebView(frame: .zero, configuration: config)
        view.isOpaque = false
        view.backgroundColor = .black
        let origin = "https://\((Bundle.main.bundleIdentifier ?? "com.careapp.CAREApp").lowercased())"
        let html = """
        <!doctype html><html><head><meta name="viewport" content="width=device-width, initial-scale=1"></head>
        <body style="margin:0;background:black;display:flex;align-items:center;justify-content:center;height:100vh"><div id="player" style="width:100vw;aspect-ratio:16/9"></div>
        <script src="https://www.youtube.com/iframe_api"></script><script>
        function onYouTubeIframeAPIReady(){new YT.Player('player',{videoId:'\(videoID)',width:'100%',height:'100%',playerVars:{controls:1,playsinline:1,origin:'\(origin)'},events:{onStateChange:function(e){if(e.data===YT.PlayerState.ENDED)window.webkit.messageHandlers.videoEnded.postMessage(true)}}});}
        </script></body></html>
        """
        view.loadHTMLString(html, baseURL: URL(string: origin))
        return view
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "videoEnded")
        uiView.stopLoading()
    }
    final class Coordinator: NSObject, WKScriptMessageHandler {
        let onEnded: () -> Void
        init(onEnded: @escaping () -> Void) { self.onEnded = onEnded }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "videoEnded" { onEnded() }
        }
    }
}

// Figma 574:204.
public struct ConnectionCountdownExerciseView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(ExerciseProgressStore.self) private var progress: ExerciseProgressStore?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    @State private var when: String?
    @State private var lookingForward = ""
    @State private var experience = ""
    @State private var showCancel = false
    @State private var draftError: String?
    @State private var restoredDraft = false
    @State private var didComplete = false
    private let item = ExerciseItem.sampleEnergeticExercises.first { $0.id == "connection-countdown" }!
    public init() {}

    private var draftSnapshot: ExerciseDraft {
        var draft = ExerciseDraft(exerciseID: item.id)
        draft.fields = ["when": when ?? "", "lookingForward": lookingForward, "experience": experience]
        return draft
    }

    public var body: some View {
        ExerciseFlowPage(item: item, description: "Look forward to a small moment with someone you care about.",
                         actionTitle: "Complete Exercise", actionEnabled: when != nil && !lookingForward.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                         onBack: { showCancel = true },
                         onAction: {
                             guard !didComplete else { return }
                             do {
                                 guard let progress else { throw CocoaError(.fileNoSuchFile) }
                                 try progress.completeAndDiscard(item.id)
                                 didComplete = true
                                 router?.finishFlow(at: .exerciseCompleteFor(item.id))
                             } catch { draftError = "Completion could not be saved. Please try again." }
                         },
                         showCancel: $showCancel) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Picture the moment")
                    .font(Theme.Typography.poppins(.bold, size: 15))
                Text("When do you expect to connect?")
                    .font(Theme.Typography.poppins(.semiBold, size: 13))
                HStack(spacing: 7) {
                    ForEach(["Today", "Tomorrow", "This week", "Later"], id: \.self) { option in
                        Button(option) { when = option }
                            .font(Theme.Typography.poppins(.medium, size: 11))
                            .foregroundStyle(when == option ? .white : item.category.exerciseAccent)
                            .padding(.horizontal, 9).frame(height: 31)
                            .background(when == option ? item.category.exerciseAccent : .white, in: Capsule())
                            .overlay(Capsule().stroke(item.category.exerciseAccent))
                    }
                }
                countdownField("What are you looking forward to?", placeholder: "A conversation, a laugh, or seeing their face…", text: $lookingForward, identifier: "CountdownLookingForwardField")
                countdownField("What are you most excited to experience together?", placeholder: "Talking, laughing, sharing, feeling understood…", text: $experience)
                Divider()
                Text("Take a moment to picture the connection and enjoy looking forward to it.")
                    .font(Theme.Typography.poppins(.regular, size: 11).italic())
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            .padding(16)
            .background(item.category.exerciseAccent.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
        }
        .task {
            if let draft = appEnvironment?.draftStore.exercise(for: item.id) {
                when = draft.fields["when"].flatMap { $0.isEmpty ? nil : $0 }
                lookingForward = draft.fields["lookingForward"] ?? ""
                experience = draft.fields["experience"] ?? ""
            }
            restoredDraft = true
            if appEnvironment?.draftStore.exercise(for: item.id) == nil {
                do { try appEnvironment?.draftStore.saveExercise(draftSnapshot) }
                catch { draftError = "Your exercise progress could not be saved. Please try again." }
            }
        }
        .onChange(of: draftSnapshot) { _, draft in
            guard restoredDraft, !didComplete, let appEnvironment else { return }
            do { try appEnvironment.draftStore.saveExercise(draft) }
            catch { draftError = "Your exercise progress could not be saved. Please try again before leaving." }
        }
        .alert("Exercise progress", isPresented: Binding(get: { draftError != nil }, set: { if !$0 { draftError = nil } })) {
            Button("OK", role: .cancel) { draftError = nil }
        } message: { Text(draftError ?? "") }
    }

    private func countdownField(_ title: String, placeholder: String, text: Binding<String>, identifier: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(Theme.Typography.poppins(.semiBold, size: 13))
            TextField(placeholder, text: text, axis: .vertical)
                .accessibilityIdentifier(identifier ?? placeholder)
                .lineLimit(2...4)
                .font(Theme.Typography.poppins(.regular, size: 12))
                .padding(11).background(.white, in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(item.category.exerciseAccent.opacity(0.4)))
        }
    }
}
