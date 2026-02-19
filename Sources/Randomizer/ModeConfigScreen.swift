import SwiftUI

struct ModeConfigScreen: View {
    let mode: RandomMode
    let navigate: (Screen) -> Void
    @EnvironmentObject var state: AppState

    @State private var minText: String = ""
    @State private var maxText: String = ""
    @State private var options: [OptionItem] = []
    @State private var spinCount: Int = 1

    private let spinCounts = [1, 3, 5]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { navigate(.modeSelect) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(8)
                        .contentShape(Circle())
                        .glassEffect(.regular, in: .circle)
                }
                .buttonStyle(.plain)
                .contentShape(Circle())

                Spacer()

                HStack(spacing: 8) {
                    if let img = loadImage(modeIconName) {
                        Image(nsImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    Text(modeTitle)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()
                Color.clear.frame(width: 30, height: 30)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Content
            Group {
                switch mode {
                case .numbers:
                    numbersContent
                case .options:
                    optionsContent
                case .yesNo:
                    yesNoContent
                }
            }

            Spacer()

            // Spin count picker
            VStack(spacing: 8) {
                Text("Сколько раз крутить?")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.6))

                HStack(spacing: 8) {
                    ForEach(spinCounts, id: \.self) { count in
                        Button(action: { spinCount = count }) {
                            Text("\(count)")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(spinCount == count ? .white : .white.opacity(0.7))
                                .frame(width: 48, height: 36)
                                .contentShape(Rectangle())
                                .glassEffect(
                                    spinCount == count
                                        ? .regular.tint(BrandColors.yellow.opacity(0.3))
                                        : .regular,
                                    in: RoundedRectangle(cornerRadius: 10)
                                )
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }
                }
            }
            .padding(.bottom, 14)

            // Spin button — calmer gradient (warm amber/gold, not neon)
            Button(action: spinAction) {
                HStack(spacing: 8) {
                    Image(systemName: "dice.fill")
                        .font(.system(size: 16))
                    Text("Крутить!")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .glassEffect(.regular.tint(BrandColors.yellow.opacity(0.35)), in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .onAppear {
            minText = "\(state.minNumber)"
            maxText = "\(state.maxNumber)"
            options = state.customOptions.map { OptionItem(text: $0) }
            if options.isEmpty {
                options.append(OptionItem(text: ""))
            }
            spinCount = state.spinCount
        }
    }

    private var modeTitle: String {
        switch mode {
        case .numbers: return "Числа"
        case .options: return "Варианты"
        case .yesNo: return "Да / Нет"
        }
    }

    private var modeIconName: String {
        switch mode {
        case .numbers: return "icon_numbers"
        case .options: return "icon_options"
        case .yesNo: return "icon_yesno"
        }
    }

    // MARK: - Numbers

    private var numbersContent: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Минимум")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.6))
                TextField("1", text: $minText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Максимум")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.6))
                TextField("100", text: $maxText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 12)
    }

    // MARK: - Options

    private var optionsContent: some View {
        VStack(spacing: 6) {
            Text("Введите варианты:")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(options.indices, id: \.self) { index in
                        HStack(spacing: 8) {
                            TextField("Вариант \(index + 1)", text: $options[index].text)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 14))

                            if options.count > 1 {
                                Button(action: { removeOption(at: index) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red.opacity(0.7))
                                        .font(.system(size: 16))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            Button(action: addOption) {
                Label("Добавить вариант", systemImage: "plus.circle.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .padding(.top, 6)
    }

    // MARK: - Yes/No

    private var yesNoContent: some View {
        VStack(spacing: 14) {
            Spacer()
            if let img = loadImage("icon_yesno") {
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 72, height: 72)
            }
            Text("Подбросим монетку?")
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
        }
    }

    // MARK: - Actions

    private func addOption() {
        withAnimation(.easeOut(duration: 0.2)) {
            options.append(OptionItem(text: ""))
        }
    }

    private func removeOption(at index: Int) {
        guard options.count > 1 else { return }
        _ = withAnimation(.easeOut(duration: 0.2)) {
            options.remove(at: index)
        }
    }

    private func spinAction() {
        switch mode {
        case .numbers:
            if let val = Int(minText) { state.minNumber = val }
            if let val = Int(maxText) { state.maxNumber = val }
        case .options:
            let opts = options.map { $0.text.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            if !opts.isEmpty {
                state.customOptions = opts
            }
        case .yesNo:
            break
        }
        state.spinCount = spinCount

        navigate(.spinner(mode, spinCount))
    }
}

// MARK: - Option Item

struct OptionItem: Identifiable {
    let id = UUID()
    var text: String
}
