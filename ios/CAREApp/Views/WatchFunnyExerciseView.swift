import AVKit
import CoreTransferable
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import WebKit

// Figma frame 275:4. Watching a suggested clip is optional; playback is never a completion gate.
public struct WatchFunnyExerciseView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(ExerciseProgressStore.self) private var progress: ExerciseProgressStore?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    @State private var activeClip: ExerciseVideoClip?
    @State private var clipAwaitingConsent: ExerciseVideoClip?
    @State private var consentedClip: ExerciseVideoClip?
    @State private var selectedVideo: PhotosPickerItem?
    @State private var uploadedPlayer: AVPlayer?
    @State private var uploadedVideoURL: URL?
    @State private var showUploadedPlayer = false
    @State private var showCancelConfirmation = false
    @State private var uploadError: String?
    @State private var videoAssetID: String?
    @State private var restoredDraft = false
    @State private var didComplete = false

    public init() {}

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderNavBar(accentColor: ExerciseCategory.calm.accentColor, onBack: { showCancelConfirmation = true })
                GeometryReader { viewport in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        ExercisePageHeader(
                            item: ExerciseItem.sampleCalmExercises[0],
                            description: "Pick a short clip that makes you smile. Laughter activates your smart vagus nerve and helps your body feel safe."
                        )
                        Divider()
                        Text("Choose a clip")
                            .font(Theme.Typography.poppins(.semiBold, size: 16))
                        ForEach(ExerciseVideoClip.allCases) { clip in
                            clipCard(clip)
                        }
                        PhotosPicker(selection: $selectedVideo, matching: .videos) {
                            VStack(spacing: 9) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 25))
                                Text("Tap to upload a video")
                                    .font(Theme.Typography.poppins(.semiBold, size: 13))
                                Text("Choose a short video that makes you laugh or smile.")
                                    .font(Theme.Typography.poppins(.regular, size: 11))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            .foregroundColor(Theme.Colors.primary)
                            .frame(maxWidth: .infinity, minHeight: 125)
                            .background(Color(hex: "#EAF4FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.Colors.primary, style: StrokeStyle(lineWidth: 1, dash: [4, 4])))
                        }
                        Text("When you're ready, tap Complete Exercise.")
                            .font(Theme.Typography.poppins(.regular, size: 12))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .frame(width: max(0, viewport.size.width - 40))
                    .padding(.horizontal, 20)
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    .padding(.bottom, 18)
                }
                }
                VStack(spacing: 4) {
                    PrimaryButton(title: "Complete Exercise") {
                        guard !didComplete else { return }
                        do {
                            guard let progress else { throw CocoaError(.fileNoSuchFile) }
                            try progress.completeAndDiscard("watch-something-funny")
                            didComplete = true
                            router?.finishFlow(at: .exerciseCompleteFor("watch-something-funny"))
                        } catch { uploadError = "Completion could not be saved. Please try again." }
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
            .frame(width: UIScreen.main.bounds.width)
            .background(.white)
            if showCancelConfirmation {
                ExerciseLeaveConfirmationView(
                    onKeepEditing: { showCancelConfirmation = false },
                    onLeave: { showCancelConfirmation = false; router?.pop() }
                )
            }
        }
        .onChange(of: selectedVideo) { _, newValue in
            guard let newValue else { return }
            Task {
                do {
                    if let assetID = newValue.itemIdentifier {
                        guard let player = await ExercisePhotoReference.loadVideoPlayer(assetID: assetID) else {
                            throw CocoaError(.fileReadCorruptFile)
                        }
                        videoAssetID = assetID
                        uploadedPlayer = player
                    } else {
                        guard let movie = try await newValue.loadTransferable(type: PickedExerciseMovie.self) else { return }
                        if let uploadedVideoURL { try? FileManager.default.removeItem(at: uploadedVideoURL) }
                        uploadedVideoURL = movie.url
                        uploadedPlayer = AVPlayer(url: movie.url)
                        videoAssetID = nil
                    }
                    persistDraft()
                    showUploadedPlayer = true
                } catch {
                    uploadError = "This video could not be opened. Please choose another one."
                }
            }
        }
        .task {
            if let draft = appEnvironment?.draftStore.exercise(for: "watch-something-funny") {
                videoAssetID = draft.videoAssetID
                if let videoAssetID {
                    uploadedPlayer = await ExercisePhotoReference.loadVideoPlayer(assetID: videoAssetID)
                    if uploadedPlayer == nil { uploadError = "The saved video is unavailable. Choose it again to continue." }
                }
            }
            restoredDraft = true
            if appEnvironment?.draftStore.exercise(for: "watch-something-funny") == nil { persistDraft() }
        }
        .onDisappear {
            uploadedPlayer?.pause()
            if let uploadedVideoURL { try? FileManager.default.removeItem(at: uploadedVideoURL) }
            uploadedVideoURL = nil
        }
        .alert("Video unavailable", isPresented: Binding(get: { uploadError != nil }, set: { if !$0 { uploadError = nil } })) {
            Button("OK", role: .cancel) { uploadError = nil }
        } message: { Text(uploadError ?? "") }
        .sheet(item: $clipAwaitingConsent, onDismiss: {
            if let consentedClip {
                activeClip = consentedClip
                self.consentedClip = nil
            }
        }) { clip in
            YouTubePlaybackConsentSheet(
                onPlay: { consentedClip = clip; clipAwaitingConsent = nil },
                onCancel: { clipAwaitingConsent = nil }
            )
        }
        .fullScreenCover(item: $activeClip) { clip in
            ZStack(alignment: .topTrailing) {
                Color.black.ignoresSafeArea()
                YouTubeExercisePlayer(clip: clip) { activeClip = nil }
                .ignoresSafeArea()
                Button { activeClip = nil } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding(20)
                }
                .accessibilityLabel("Close video")
            }
        }
        .fullScreenCover(isPresented: $showUploadedPlayer) {
            ZStack(alignment: .topTrailing) {
                Color.black.ignoresSafeArea()
                if let uploadedPlayer {
                    VideoPlayer(player: uploadedPlayer).ignoresSafeArea()
                        .onAppear { uploadedPlayer.play() }
                        .onDisappear {
                            uploadedPlayer.pause()
                            if let uploadedVideoURL { try? FileManager.default.removeItem(at: uploadedVideoURL) }
                            uploadedVideoURL = nil
                            self.uploadedPlayer = nil
                            selectedVideo = nil
                        }
                }
                Button { showUploadedPlayer = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding(20)
                }
                .accessibilityLabel("Close video")
            }
            .onReceive(NotificationCenter.default.publisher(for: AVPlayerItem.didPlayToEndTimeNotification)) { notification in
                guard let ended = notification.object as? AVPlayerItem, ended === uploadedPlayer?.currentItem else { return }
                showUploadedPlayer = false
            }
        }
    }

    private func persistDraft() {
        guard restoredDraft, let appEnvironment else { return }
        var draft = ExerciseDraft(exerciseID: "watch-something-funny")
        draft.videoAssetID = videoAssetID
        do { try appEnvironment.draftStore.saveExercise(draft) }
        catch { uploadError = "Your exercise progress could not be saved. Please try again before leaving." }
    }

    private func clipCard(_ clip: ExerciseVideoClip) -> some View {
        Button { clipAwaitingConsent = clip } label: {
            VStack(alignment: .center, spacing: 8) {
                GeometryReader { geometry in
                    Image(clip.thumbnailAsset)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: 180)
                        .clipped()
                        .overlay {
                            Image(systemName: "play.fill")
                                .font(.system(size: 17))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .frame(width: 40, height: 40)
                                .background(.white.opacity(0.9), in: Circle())
                        }
                }
                .frame(height: 180)
                Text(clip.title)
                    .font(Theme.Typography.poppins(.bold, size: 14))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Text(clip.detail)
                    .font(Theme.Typography.poppins(.regular, size: 12))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .frame(width: UIScreen.main.bounds.width - 40)
            .padding(.bottom, 12)
            .background(Color(hex: "#EAF4FF"))
            .clipShape(RoundedRectangle(cornerRadius: 13))
        }
        .buttonStyle(.plain)
        .frame(width: UIScreen.main.bounds.width - 40)
        .clipped()
        .accessibilityLabel("Play \(clip.title)")
    }
}

// The YouTube iframe is loaded only after the user chooses to open it. This
// disclosure leaves exercise completion available when the user declines.
struct YouTubePlaybackConsentSheet: View {
    let onPlay: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Before playing this video")
                .font(Theme.Typography.poppins(.bold, size: 20))
                .foregroundStyle(Theme.Colors.textPrimary)
            Text("The embedded YouTube player connects to Google and may share device, network, and playback information. Watching is optional; you can still complete the exercise without it.")
                .font(Theme.Typography.poppins(.regular, size: 14))
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 18) {
                Link("CARE Privacy Policy", destination: PrivacyDetailsView.policyURL)
                Link("YouTube Terms", destination: URL(string: "https://www.youtube.com/t/terms")!)
            }
            .font(Theme.Typography.poppins(.medium, size: 13))
            Text("By choosing Agree & Play, you agree to the linked CARE Privacy Policy and YouTube Terms of Service.")
                .font(Theme.Typography.poppins(.regular, size: 12))
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            PrimaryButton(title: "Agree & Play Video", action: onPlay)
                .accessibilityIdentifier("YouTubeAgreeAndPlayButton")
            Button("Not Now", action: onCancel)
                .font(Theme.Typography.poppins(.medium, size: 14))
                .foregroundStyle(Theme.Colors.textSecondary)
                .accessibilityIdentifier("YouTubeNotNowButton")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .presentationDetents([.height(390)])
        .presentationDragIndicator(.visible)
    }
}

private enum ExerciseVideoClip: String, CaseIterable, Identifiable {
    case animals
    case comedy
    var id: String { rawValue }
    var title: String { self == .animals ? "Funny Animal Compilation" : "When Life Throws You Earthquakes" }
    var detail: String { self == .animals ? "About 10 min • Funny animals and pets" : "About 7 min • Wanda Sykes stand-up" }
    var thumbnailAsset: String { self == .animals ? "exercise_animals" : "exercise_comedy" }
    var videoID: String { self == .animals ? "A1CVa6NrPpk" : "dbj85TIYyrQ" }
}

private struct YouTubeExercisePlayer: UIViewRepresentable {
    let clip: ExerciseVideoClip
    let onEnded: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onEnded: onEnded) }

    func makeUIView(context: Context) -> WKWebView {
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "videoEnded")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .black
        let appOrigin = "https://\((Bundle.main.bundleIdentifier ?? "com.careapp.CAREApp").lowercased())"
        let html = """
        <!doctype html><html><head><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="referrer" content="strict-origin-when-cross-origin"></head>
        <body style="margin:0;background:#000;display:flex;align-items:center;height:100vh"><div style="width:100vw;aspect-ratio:16/9"><div id="player" style="width:100%;height:100%"></div></div>
        <script src="https://www.youtube.com/iframe_api"></script><script>
        function onYouTubeIframeAPIReady() {
          new YT.Player('player', { videoId: '\(clip.videoID)', width: '100%', height: '100%',
            playerVars: { controls: 1, rel: 0, playsinline: 1, origin: '\(appOrigin)' },
            events: { onStateChange: function(e) {
              if (e.data === YT.PlayerState.ENDED) window.webkit.messageHandlers.videoEnded.postMessage(true);
            } }
          });
        }
        </script></body></html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: appOrigin))
        return webView
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

struct PickedExerciseMovie: Transferable {
    let url: URL
    static var temporaryMoviesDirectory: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("care-exercise-movies", isDirectory: true)
    }

    static func removeStaleTemporaryMovies() {
        let directory = temporaryMoviesDirectory
        guard let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return }
        for file in files where file.pathExtension == "mov" { try? FileManager.default.removeItem(at: file) }
    }

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let directory = temporaryMoviesDirectory
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let destination = directory.appendingPathComponent(UUID().uuidString + ".mov")
            try FileManager.default.copyItem(at: received.file, to: destination)
            return Self(url: destination)
        }
    }
}

#Preview { WatchFunnyExerciseView() }
