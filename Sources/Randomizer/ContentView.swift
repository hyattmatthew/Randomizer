import SwiftUI
import AppKit

// MARK: - Shared State

enum RandomMode: Hashable {
    case numbers
    case options
    case yesNo
}

enum Screen: Hashable {
    case modeSelect
    case modeConfig(RandomMode)
    case spinner(RandomMode, Int) // mode + spinCount
}

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var minNumber: Int = 1
    @Published var maxNumber: Int = 100
    @Published var customOptions: [String] = ["Вариант А", "Вариант Б", "Вариант В"]
    @Published var spinCount: Int = 1
}

// MARK: - Brand Colors (from palette)

struct BrandColors {
    static let yellow = Color(red: 252/255, green: 176/255, blue: 24/255)   // #FCB018
    static let orange = Color(red: 255/255, green: 118/255, blue: 13/255)   // #FF760D
    static let dark = Color(red: 51/255, green: 51/255, blue: 51/255)       // #333333
    static let gray = Color(red: 100/255, green: 100/255, blue: 100/255)    // #646464
    static let lightGray = Color(red: 167/255, green: 167/255, blue: 167/255) // #A7A7A7
    static let teal = Color(red: 0/255, green: 148/255, blue: 121/255)      // #009479
}

// MARK: - NSVisualEffectView wrapper for real translucency

struct VisualEffectBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.wantsLayer = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - ContentView (Root Navigation)

struct ContentView: View {
    @StateObject private var state = AppState.shared
    @State private var currentScreen: Screen = .modeSelect
    @State private var screenID = UUID()

    var body: some View {
        ZStack {
            // Semi-transparent dark background — desktop shows through
            Color.black
                .opacity(0.45)
                .ignoresSafeArea()

            // Subtle blue tint
            Color(red: 0.25, green: 0.45, blue: 0.70)
                .opacity(0.10)
                .ignoresSafeArea()

            // Soft bokeh circles
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.03))
                        .frame(width: 200, height: 200)
                        .offset(x: -60, y: -40)
                        .blur(radius: 40)

                    Circle()
                        .fill(.white.opacity(0.02))
                        .frame(width: 160, height: 160)
                        .offset(x: 100, y: 200)
                        .blur(radius: 50)

                    Circle()
                        .fill(BrandColors.yellow.opacity(0.03))
                        .frame(width: 120, height: 120)
                        .offset(x: 80, y: -80)
                        .blur(radius: 30)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }

            // Screen content
            Group {
                switch currentScreen {
                case .modeSelect:
                    ModeSelectScreen(navigate: navigateTo)
                case .modeConfig(let mode):
                    ModeConfigScreen(mode: mode, navigate: navigateTo)
                case .spinner(let mode, let count):
                    SpinnerScreen(mode: mode, spinCount: count, navigate: navigateTo)
                }
            }
            .id(screenID)
            .transition(.opacity.combined(with: .scale(scale: 0.97)))
        }
        .frame(width: 340, height: 460)
        .environmentObject(state)
    }

    private func navigateTo(_ screen: Screen) {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentScreen = screen
            screenID = UUID()
        }
    }
}
