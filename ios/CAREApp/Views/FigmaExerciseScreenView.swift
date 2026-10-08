import SwiftUI
import PhotosUI

#if !DEBUG && !CARE_INTERNAL_TESTFLIGHT
#error("Paid CARE preview: complete the StoreKit, entitlement, media-rights, and App Review gates in docs/PAID_RELEASE_HANDOFF.md before making a distribution build.")
#endif

// A native SwiftUI rendering of the individual Figma components. The JSON is
// exported from the four CARE exercise pages, excluding only the app top bar.
struct FigmaColor: Decodable {
    let r: Double
    let g: Double
    let b: Double
    var swiftUI: Color { Color(red: r, green: g, blue: b) }
}
struct FigmaPaint: Decodable {
    let t: String
    let c: FigmaColor?
    let o: Double?
    let v: Bool?
    let h: String?
}
struct FigmaFont: Decodable {
    let family: String
    let style: String
}
struct FigmaExerciseNode: Decodable, Identifiable {
    let id: String
    let t: String
    let n: String
    let x: CGFloat
    let y: CGFloat
    let w: CGFloat
    let h: CGFloat
    let f: [FigmaPaint]?
    let s: [FigmaPaint]?
    let sw: CGFloat?
    let r: CGFloat?
    let txt: String?
    let fs: CGFloat?
    let fn: FigmaFont?
    let a: String?
    let semantic: String?
    let path: [String]?

    var imageAsset: String? {
        guard let hash = f?.first(where: { $0.t == "IMAGE" })?.h else { return nil }
        switch hash {
        case "9faf725e6e9ad1ab2d6840545b2b5d11a4af7a89": return "FigmaReadCharacterClip"
        case "6aeac22d2f406f19e5deab3aff147bbf4afba5d9": return "FigmaShareIcon"
        case "6941379a35337829adbeab7e6b76732ddaaa4423": return "FigmaBreathingArt"
        case "08c13ca33d9edfe16cf76c203d7e728a2438b244": return "FigmaMirrorGestureOne"
        case "699a7c1095ff6415a923bee6923275a2629d5a13": return "FigmaHugCompilation"
        default: return nil
        }
    }
    var fill: Color? {
        guard let paint = f?.first(where: { $0.v != false && $0.t == "SOLID" }), let color = paint.c else { return nil }
        return color.swiftUI.opacity(paint.o ?? 1)
    }
    var stroke: Color? {
        guard let paint = s?.first(where: { $0.v != false && $0.t == "SOLID" }), let color = paint.c else { return nil }
        return color.swiftUI.opacity(paint.o ?? 1)
    }
}
struct FigmaExerciseScreen: Decodable {
    let id: String
    let name: String
    let w: CGFloat
    let h: CGFloat
    let nodes: [FigmaExerciseNode]
}

enum FigmaExerciseScreenCatalog {
    private static let screens: [String: FigmaExerciseScreen] = {
        guard let url = Bundle.main.url(forResource: "FigmaExerciseScreens", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([FigmaExerciseScreen].self, from: data) else { return [:] }
        return Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })
    }()
    private static let frames: [String: [String]] = {
        guard let url = Bundle.main.url(forResource: "FigmaExerciseFrameMap", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let map = try? JSONDecoder().decode([String: [String]].self, from: data) else { return [:] }
        return map
    }()
    static func screen(for exerciseID: String, step: Int, selection: String? = nil) -> FigmaExerciseScreen? {
        guard let ids = frames[exerciseID], ids.indices.contains(step),
              let screen = screens[exerciseID == "mirror-a-gentle-gesture" && step == 1 && selection == "hug"
                  ? "880:105" : ids[step]],
              !screen.nodes.contains(where: { node in
                  node.f?.contains(where: { $0.t == "IMAGE" }) == true && node.imageAsset == nil
              }) else { return nil }
        return screen
    }
}

struct FigmaExerciseScreenView: View {
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    let screen: FigmaExerciseScreen
    let accent: Color
    @Binding var fields: [String: String]
    let onNext: () -> Void
    let onCancel: () -> Void
    let onFavorite: () -> Void
    @State private var editingListItem: String?
    @State private var listEntry = ""
    @State private var showingRelationshipPicker = false
    @State private var assessedPeople: [Person] = []
    @State private var selectedPhoto: PhotosPickerItem?

    private var photoKey: String { "photo:\(screen.id)" }

    private var exerciseVideoURL: URL? {
        switch screen.id {
        case "840:499":
            return URL(string: "https://www.youtube.com/watch?v=dOkyKyVFnSs")
        case "840:839":
            return URL(string: "https://www.tiktok.com/@selfiequeen1977/video/7406052816931933482")
        case "880:105":
            return URL(string: "https://www.youtube.com/watch?v=0Bk5yoFJDo4")
        default:
            return nil
        }
    }

    private var savedPhoto: UIImage? {
        guard let filename = fields[photoKey],
              let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return UIImage(contentsOfFile: directory.appendingPathComponent("ExercisePhotos")
            .appendingPathComponent(filename).path)
    }

    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / CGFloat(screen.w)
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    ForEach(screen.nodes) { node in
                        if node.y >= 64, node.id != screen.id {
                            layer(node, scale: scale)
                                .frame(width: max(0, node.w * scale), height: max(0, node.h * scale))
                                .position(x: (node.x + node.w / 2) * scale,
                                          y: (node.y - 64 + node.h / 2) * scale)
                        }
                    }
                    ForEach(screen.nodes.filter { $0.n == "reflection-input" }) { node in
                        TextField("Tap to write a reflection…",
                                  text: Binding(
                                    get: { fields[node.id] ?? "" },
                                    set: { fields[node.id] = $0 }
                                  ), axis: .vertical)
                            .lineLimit(2...4)
                            .font(.custom("Poppins-Regular", size: 12 * scale))
                            .foregroundStyle(Color(red: 0.118, green: 0.161, blue: 0.231))
                            .padding(.horizontal, 11 * scale)
                            .frame(width: node.w * scale, height: node.h * scale)
                            .background(node.fill ?? Color.white,
                                        in: RoundedRectangle(cornerRadius: (node.r ?? 10) * scale))
                            .overlay(RoundedRectangle(cornerRadius: (node.r ?? 10) * scale)
                                .stroke(node.stroke ?? accent.opacity(0.4), lineWidth: 1))
                            .position(x: (node.x + node.w / 2) * scale,
                                      y: (node.y - 64 + node.h / 2) * scale)
                            .accessibilityIdentifier("FigmaReflection_\(node.id)")
                    }
                    if ["792:357", "844:1664", "845:3034"].contains(screen.id),
                       let node = screen.nodes.first(where: { $0.n == "upload-dashed-area" }) {
                        if let photo = savedPhoto {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: node.w * scale, height: node.h * scale)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: (node.r ?? 12) * scale))
                                .position(x: (node.x + node.w / 2) * scale,
                                          y: (node.y - 64 + node.h / 2) * scale)
                        }
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Color.clear.contentShape(Rectangle())
                        }
                        .frame(width: node.w * scale, height: node.h * scale)
                        .position(x: (node.x + node.w / 2) * scale,
                                  y: (node.y - 64 + node.h / 2) * scale)
                        .accessibilityLabel("Add an optional photo")
                    }
                    ForEach(screen.nodes.filter {
                        $0.n.hasPrefix("list-item") || $0.n.hasPrefix("optional-support")
                        || $0.n.hasPrefix("choice-bubble") || $0.n.hasPrefix("multi-select-option")
                        || $0.n.hasPrefix("stress-choice-")
                    }) { node in
                        Button {
                            if screen.name.contains("safe-support-plan")
                                || node.n.contains("custom") || node.n.contains("Add your own")
                                || node.path?.contains(where: { $0.contains("make-list") }) == true {
                                editingListItem = node.id
                                listEntry = fields[node.id] ?? ""
                            } else {
                                fields[node.id] = fields[node.id] == "selected" ? "" : "selected"
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: (node.r ?? 14) * scale)
                                .fill(.clear)
                                .overlay {
                                    if fields[node.id] == "selected" {
                                        RoundedRectangle(cornerRadius: (node.r ?? 14) * scale)
                                            .stroke(accent, lineWidth: 2 * scale)
                                    }
                                }
                                .contentShape(Rectangle())
                        }
                        .frame(width: node.w * scale, height: node.h * scale)
                        .position(x: (node.x + node.w / 2) * scale,
                                  y: (node.y - 64 + node.h / 2) * scale)
                        .accessibilityIdentifier("FigmaChoice_\(node.id)")
                    }
                    ForEach(screen.nodes.filter { $0.n == "relationship-picker" }) { node in
                        Button {
                            Task { await showAssessedRelationships() }
                        } label: {
                            Color.clear.contentShape(Rectangle())
                        }
                        .frame(width: node.w * scale, height: node.h * scale)
                        .position(x: (node.x + node.w / 2) * scale,
                                  y: (node.y - 64 + node.h / 2) * scale)
                        .accessibilityLabel("Choose a relationship from your assessments")
                    }
                    if screen.id == "840:729" {
                        ForEach(screen.nodes.filter { $0.n == "choose-clip" }) { node in
                            Button {
                                fields["mirror-clip-choice"] = node.path?.contains("exercise-2-card") == true
                                    ? "hug" : "smile"
                                onNext()
                            } label: { Color.clear.contentShape(Rectangle()) }
                                .frame(width: node.w * scale, height: node.h * scale)
                                .position(x: (node.x + node.w / 2) * scale,
                                          y: (node.y - 64 + node.h / 2) * scale)
                                .accessibilityLabel(node.path?.contains("exercise-2-card") == true
                                    ? "Choose hug compilation" : "Choose warm smile")
                        }
                    }
                    if let video = exerciseVideoURL,
                       let node = screen.nodes.first(where: { $0.n == "upload-dashed-area" }) {
                        Link(destination: video) { Color.clear.contentShape(Rectangle()) }
                            .frame(width: node.w * scale, height: node.h * scale)
                            .position(x: (node.x + node.w / 2) * scale,
                                      y: (node.y - 64 + node.h / 2) * scale)
                            .accessibilityLabel(screen.id == "840:499" ? "Watch the character feelings video on YouTube"
                                : screen.id == "840:839" ? "Watch a warm smile on TikTok"
                                : "Watch the hug compilation on YouTube")
                    }
                    ForEach(screen.nodes.filter { $0.n == "btn-complete-exercise" }) { node in
                        Button {
                            if screen.id == "839:235" && (fields["relationship-person-id"] ?? "").isEmpty {
                                Task { await showAssessedRelationships() }
                            } else {
                                onNext()
                            }
                        } label: { Color.clear.contentShape(Rectangle()) }
                            .frame(width: node.w * scale, height: node.h * scale)
                            .position(x: (node.x + node.w / 2) * scale,
                                      y: (node.y - 64 + node.h / 2) * scale)
                            .accessibilityIdentifier("ExerciseFlowAction")
                    }
                    ForEach(screen.nodes.filter { $0.n == "btn-back-to-exercises" || $0.n == "btn-cancel" }) { node in
                        Button(action: onCancel) { Color.clear.contentShape(Rectangle()) }
                            .frame(width: node.w * scale, height: node.h * scale)
                            .position(x: (node.x + node.w / 2) * scale,
                                      y: (node.y - 64 + node.h / 2) * scale)
                    }
                    ForEach(screen.nodes.filter { $0.n == "fav-button" }) { node in
                        Button(action: onFavorite) { Color.clear.contentShape(Rectangle()) }
                            .frame(width: node.w * scale, height: node.h * scale)
                            .position(x: (node.x + node.w / 2) * scale,
                                      y: (node.y - 64 + node.h / 2) * scale)
                    }
                }
                .frame(width: geometry.size.width, height: max(geometry.size.height, (screen.h - 64) * scale),
                       alignment: .topLeading)
            }
            .background(.white)
        }
        .alert("Add to your list", isPresented: Binding(
            get: { editingListItem != nil },
            set: { if !$0 { editingListItem = nil } }
        )) {
            TextField("Your answer", text: $listEntry)
            Button("Save") {
                if let editingListItem { fields[editingListItem] = listEntry }
                editingListItem = nil
            }
            Button("Cancel", role: .cancel) { editingListItem = nil }
        }
        .sheet(isPresented: $showingRelationshipPicker) {
            NavigationStack {
                Group {
                    if assessedPeople.isEmpty {
                        VStack(spacing: 12) {
                            Text("No assessed relationships yet")
                                .font(Theme.Typography.poppins(.semiBold, size: 18))
                            Text("Complete an assessment with someone to choose them here.")
                                .font(Theme.Typography.poppins(.regular, size: 14))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Theme.Colors.textSecondary)
                        }
                        .padding(24)
                    } else {
                        List(assessedPeople) { person in
                            Button(person.name) {
                                fields["relationship-person-id"] = person.id.uuidString
                                fields["relationship-person-name"] = person.name
                                showingRelationshipPicker = false
                            }
                        }
                    }
                }
                .navigationTitle("Choose a relationship")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingRelationshipPicker = false }
                    }
                }
            }
        }
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task { await savePhoto(item) }
        }
    }

    @MainActor
    private func savePhoto(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data),
              let jpeg = image.jpegData(compressionQuality: 0.8),
              let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let directory = documents.appendingPathComponent("ExercisePhotos", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let filename = UUID().uuidString + ".jpg"
            try jpeg.write(to: directory.appendingPathComponent(filename), options: .atomic)
            fields[photoKey] = filename
        } catch {
            return
        }
    }

    @MainActor
    private func showAssessedRelationships() async {
        if let history = try? await appEnvironment?.assessmentRepo.fetchAssessmentHistory() {
            var seen = Set<UUID>()
            assessedPeople = history.flatMap(\.individualResults)
                .map(\.participant.person)
                .filter { seen.insert($0.id).inserted }
        } else {
            assessedPeople = []
        }
        showingRelationshipPicker = true
    }

    @ViewBuilder
    private func layer(_ node: FigmaExerciseNode, scale: CGFloat) -> some View {
        if let imageAsset = node.imageAsset {
            Image(imageAsset)
                .resizable()
                .scaledToFill()
                .frame(width: node.w * scale, height: node.h * scale)
                .clipShape(RoundedRectangle(cornerRadius: (node.r ?? 0) * scale))
        } else if node.t == "TEXT", let value = node.txt {
            if value == "0 / 3 Completed" &&
                (screen.name.contains("safe-support-plan") || screen.id == "792:357") {
                let required = screen.nodes.filter { ["list-item-1", "list-item-2", "list-item-3"].contains($0.n) }
                Text("\(required.filter { !(fields[$0.id] ?? "").isEmpty }.count) / 3 Completed")
                    .font(.custom(fontName(node.fn), size: (node.fs ?? 12) * scale))
                    .foregroundStyle(node.fill ?? accent)
            } else if value.hasPrefix("⏱ ") {
                HStack(spacing: 3 * scale) {
                    Image(systemName: "stopwatch")
                        .font(.system(size: (node.fs ?? 11) * scale))
                    Text(String(value.dropFirst(2)))
                        .font(.custom(fontName(node.fn), size: (node.fs ?? 11) * scale))
                }
                .foregroundStyle(node.fill ?? Color(red: 0.392, green: 0.455, blue: 0.545))
                .fixedSize(horizontal: true, vertical: false)
            } else if value == "▶" || value == "♥" || value == "✓" {
                Image(systemName: value == "▶" ? "play.fill" : value == "♥" ? "heart.fill" : "checkmark")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(node.fill ?? accent)
            } else if isEmoji(value) {
                ExerciseEmojiView(emoji: value, size: min(node.w, node.h) * scale)
            } else {
                Text(savedListValue(for: node) ?? value)
                    .font(.custom(fontName(node.fn), size: (node.fs ?? 13) * scale))
                    .foregroundStyle(node.fill ?? Color(red: 0.118, green: 0.161, blue: 0.231))
                    .multilineTextAlignment(node.a == "CENTER" ? .center : node.a == "RIGHT" ? .trailing : .leading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity,
                           alignment: node.a == "CENTER" ? .center : node.a == "RIGHT" ? .trailing : .leading)
                    .fixedSize(horizontal: false, vertical: false)
            }
        } else if node.t == "VECTOR", let symbol = symbolName(node.semantic) {
            Image(systemName: symbol)
                .resizable()
                .scaledToFit()
                .foregroundStyle(node.stroke ?? node.fill ?? accent)
        } else if node.t == "LINE" {
            Rectangle().fill(node.stroke ?? Color.clear)
                .frame(height: max(0.5, (node.sw ?? 1) * scale))
        } else if node.t == "ELLIPSE" {
            Circle()
                .fill(node.fill ?? Color.clear)
                .overlay(Circle().stroke(node.stroke ?? Color.clear, lineWidth: (node.sw ?? 1) * scale))
        } else if (node.n.hasPrefix("optional-support-") || node.n == "upload-dashed-area")
                    && node.t == "FRAME" {
            RoundedRectangle(cornerRadius: (node.r ?? 14) * scale)
                .fill(node.fill ?? Color.clear)
                .overlay(RoundedRectangle(cornerRadius: (node.r ?? 14) * scale)
                    .stroke(node.stroke ?? Color.clear,
                            style: StrokeStyle(lineWidth: (node.sw ?? 1) * scale,
                                               dash: [6 * scale, 4 * scale])))
        } else if node.fill != nil || node.stroke != nil {
            RoundedRectangle(cornerRadius: (node.r ?? 0) * scale)
                .fill(node.fill ?? Color.clear)
                .overlay(RoundedRectangle(cornerRadius: (node.r ?? 0) * scale)
                    .stroke(node.stroke ?? Color.clear, lineWidth: (node.sw ?? 1) * scale))
        } else {
            Color.clear
        }
    }

    private func fontName(_ font: FigmaFont?) -> String {
        guard font?.family == "Poppins" else { return "Poppins-Regular" }
        switch font?.style {
        case "Bold": return "Poppins-Bold"
        case "SemiBold": return "Poppins-SemiBold"
        case "Medium": return "Poppins-Medium"
        default: return "Poppins-Regular"
        }
    }
    private func isEmoji(_ value: String) -> Bool {
        value.count <= 2 && value.unicodeScalars.contains { $0.value > 0x2600 }
    }
    private func symbolName(_ semantic: String?) -> String? {
        switch semantic {
        case "heart": return "heart"
        case "plus": return "plus"
        case "chevron-right": return "chevron.right"
        case "arrow-right": return "arrow.right"
        case "selected-check": return "checkmark"
        case "empty-selection-circle": return "circle"
        case "share-icon-circle": return "square.and.arrow.up"
        default: return nil
        }
    }

    private func savedListValue(for node: FigmaExerciseNode) -> String? {
        if node.n == "placeholder", node.path?.contains("relationship-picker") == true {
            return fields["relationship-person-name"]
        }
        guard node.n == "placeholder" || node.n.contains("support") else { return nil }
        let listItem = screen.nodes
            .filter { ($0.n.hasPrefix("list-item") || $0.n.hasPrefix("optional-support"))
                && $0.x <= node.x && $0.y <= node.y
                && $0.x + $0.w >= node.x + node.w
                && $0.y + $0.h >= node.y + node.h }
            .last
        guard let listItem else { return nil }
        return fields[listItem.id].flatMap { $0.isEmpty ? nil : $0 }
    }
}
