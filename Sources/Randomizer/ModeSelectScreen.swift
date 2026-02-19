import SwiftUI

struct ModeSelectScreen: View {
    let navigate: (Screen) -> Void
    @State private var hoveredMode: RandomMode? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header with app icon
            VStack(spacing: 6) {
                // App icon from resources
                if let img = loadImage("icon_app") {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                }

                Text("Рандом Рандомыч")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Выбери режим")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.top, 20)
            .padding(.bottom, 20)

            // Mode cards
            VStack(spacing: 12) {
                modeCard(
                    iconName: "icon_numbers",
                    title: "Числа",
                    subtitle: "Случайное число в диапазоне",
                    mode: .numbers,
                    tint: Color.cyan.opacity(0.15)
                )

                modeCard(
                    iconName: "icon_options",
                    title: "Варианты",
                    subtitle: "Случайный выбор из списка",
                    mode: .options,
                    tint: Color.green.opacity(0.15)
                )

                modeCard(
                    iconName: "icon_yesno",
                    title: "Да / Нет",
                    subtitle: "Простой ответ на вопрос",
                    mode: .yesNo,
                    tint: BrandColors.orange.opacity(0.15)
                )
            }
            .padding(.horizontal, 20)

            Spacer()

            // Bottom bar — just quit, no history
            HStack {
                Spacer()
                Button(action: { NSApp.terminate(nil) }) {
                    Label("Выход", systemImage: "xmark")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private func modeCard(iconName: String, title: String, subtitle: String, mode: RandomMode, tint: Color) -> some View {
        Button(action: { navigate(.modeConfig(mode)) }) {
            HStack(spacing: 14) {
                if let img = loadImage(iconName) {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .glassEffect(.regular.tint(tint), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { isHovered in
            hoveredMode = isHovered ? mode : nil
        }
        .scaleEffect(hoveredMode == mode ? 1.02 : 1.0)
        .animation(.easeOut(duration: 0.15), value: hoveredMode)
    }
}

// MARK: - Image Loader (from Bundle Resources)

func loadImage(_ name: String) -> NSImage? {
    if let url = Bundle.module.url(forResource: name, withExtension: "png", subdirectory: "Resources") {
        return NSImage(contentsOf: url)
    }
    return nil
}
