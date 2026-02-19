import SwiftUI

// MARK: - SpinnerScreen (supports 1/3/5 sequential carousels)

struct SpinnerScreen: View {
    let mode: RandomMode
    let spinCount: Int
    let navigate: (Screen) -> Void
    @EnvironmentObject var state: AppState

    @State private var carousels: [CarouselData] = []
    @State private var activeIndex: Int = 0
    @State private var allDone = false
    @State private var finalResult: String = ""
    @State private var resultStats: [(value: String, count: Int)] = []

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                // Back button always visible
                Button(action: { navigate(.modeConfig(mode)) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(7)
                        .contentShape(Circle())
                        .glassEffect(.regular, in: .circle)
                }
                .buttonStyle(.plain)
                .contentShape(Circle())

                Spacer()

                Text(allDone ? "Результат" : "Крутим...")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                // Quit button
                Button(action: { NSApp.terminate(nil) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(7)
                        .contentShape(Circle())
                        .glassEffect(.regular, in: .circle)
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 8)

            // Counter (e.g. "2 / 3")
            if spinCount > 1 {
                Text("\(min(activeIndex + 1, spinCount)) / \(spinCount)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 4)
            }

            // Carousels
            ScrollView {
                VStack(spacing: spinCount == 1 ? 0 : 8) {
                    ForEach(carousels.indices, id: \.self) { idx in
                        SingleCarousel(
                            data: carousels[idx],
                            isActive: idx == activeIndex,
                            isCompleted: idx < activeIndex || (idx == activeIndex && carousels[idx].isDone),
                            compact: spinCount > 1,
                            onComplete: {
                                carouselFinished(index: idx)
                            }
                        )
                        .opacity(idx <= activeIndex ? 1 : 0.3)
                    }
                }
                .padding(.horizontal, 12)
            }

            // Results area
            if allDone {
                VStack(spacing: 8) {
                    // Stats breakdown (for multi-spin)
                    if spinCount > 1 {
                        VStack(spacing: 4) {
                            ForEach(resultStats, id: \.value) { stat in
                                HStack {
                                    Text(stat.value)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    // Bar + count
                                    HStack(spacing: 6) {
                                        let pct = CGFloat(stat.count) / CGFloat(spinCount)
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(stat.value == finalResult ? BrandColors.yellow : .white.opacity(0.3))
                                            .frame(width: pct * 80, height: 8)
                                        Text("\(stat.count)×")
                                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                            .foregroundStyle(stat.value == finalResult ? BrandColors.yellow : .white.opacity(0.6))
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .glassEffect(.regular.tint(
                                    stat.value == finalResult
                                        ? BrandColors.yellow.opacity(0.15)
                                        : .white.opacity(0.02)
                                ), in: RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)

                        Text("Победитель:")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.top, 4)
                    }

                    // Final winner
                    Text(finalResult)
                        .font(.system(size: spinCount > 1 ? 30 : 38, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BrandColors.yellow, BrandColors.orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: BrandColors.orange.opacity(0.3), radius: 6)
                        .transition(.scale.combined(with: .opacity))
                }
                .padding(.top, 6)

                Spacer(minLength: 8)

                // Action buttons
                HStack(spacing: 12) {
                    Button(action: { navigate(.spinner(mode, spinCount)) }) {
                        Label("Ещё раз", systemImage: "arrow.clockwise")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 9)
                            .contentShape(Capsule())
                            .glassEffect(.regular.tint(BrandColors.yellow.opacity(0.2)), in: .capsule)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Capsule())

                    Button(action: { navigate(.modeSelect) }) {
                        Label("В меню", systemImage: "house")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 9)
                            .contentShape(Capsule())
                            .glassEffect(.regular, in: .capsule)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Capsule())
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 16)
            } else {
                Spacer()
            }
        }
        .onAppear {
            setupCarousels()
        }
    }

    private func setupCarousels() {
        carousels = (0..<spinCount).map { _ in
            CarouselData(mode: mode, state: state)
        }
        activeIndex = 0
    }

    private func carouselFinished(index: Int) {
        carousels[index].isDone = true

        if index + 1 < spinCount {
            // Launch next carousel after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.3)) {
                    activeIndex = index + 1
                }
            }
        } else {
            // All done — compute stats
            let results = carousels.map { $0.winnerResult }
            var freq: [String: Int] = [:]
            for r in results { freq[r, default: 0] += 1 }

            let sorted = freq.sorted { $0.value > $1.value }
            let best = sorted.first?.key ?? "?"

            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                resultStats = sorted.map { (value: $0.key, count: $0.value) }
                finalResult = best
                allDone = true
            }
        }
    }
}

// MARK: - Carousel Data

class CarouselData: Identifiable {
    let id = UUID()
    var items: [String] = []
    var winnerResult: String = ""
    let winnerIndex = 45
    var isDone = false

    init(mode: RandomMode, state: AppState) {
        generateItems(mode: mode, state: state)
    }

    private func generateItems(mode: RandomMode, state: AppState) {
        let cellCount = 50
        var pool: [String] = []

        switch mode {
        case .numbers:
            let lo = state.minNumber
            let hi = max(lo, state.maxNumber)
            for _ in 0..<cellCount {
                pool.append("\(Int.random(in: lo...hi))")
            }
            winnerResult = "\(Int.random(in: lo...hi))"

        case .options:
            let opts = state.customOptions.isEmpty ? ["—"] : state.customOptions
            while pool.count < cellCount {
                pool.append(contentsOf: opts.shuffled())
            }
            winnerResult = opts.randomElement() ?? "—"

        case .yesNo:
            for _ in 0..<cellCount {
                pool.append(Bool.random() ? "Да" : "Нет")
            }
            winnerResult = Bool.random() ? "Да" : "Нет"
        }

        items = Array(pool.prefix(cellCount))
        if winnerIndex < items.count {
            items[winnerIndex] = winnerResult
        }
    }
}

// MARK: - Single Carousel Row

struct SingleCarousel: View {
    let data: CarouselData
    let isActive: Bool
    let isCompleted: Bool
    let compact: Bool
    let onComplete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var started = false
    @State private var showWinner = false

    private let cellWidth: CGFloat = 76
    private let cellSpacing: CGFloat = 4
    private let duration: Double = 3.5

    private var cellHeight: CGFloat { compact ? 40 : 54 }
    private var fontSize: CGFloat { compact ? 12 : 15 }

    var body: some View {
        VStack(spacing: 0) {
            // Pointer
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: compact ? 9 : 13))
                .foregroundStyle(BrandColors.yellow)
                .shadow(color: BrandColors.orange.opacity(0.4), radius: 3)
                .padding(.bottom, 2)

            // Carousel strip
            GeometryReader { geo in
                let viewWidth = geo.size.width
                ZStack {
                    HStack(spacing: cellSpacing) {
                        ForEach(0..<data.items.count, id: \.self) { i in
                            let isWinner = showWinner && i == data.winnerIndex
                            Text(data.items[i])
                                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                                .foregroundStyle(isWinner ? BrandColors.yellow : .primary)
                                .frame(width: cellWidth, height: cellHeight)
                                .glassEffect(
                                    isWinner
                                        ? .regular.tint(BrandColors.yellow.opacity(0.25))
                                        : .regular.tint(.white.opacity(i % 2 == 0 ? 0.05 : 0.02)),
                                    in: RoundedRectangle(cornerRadius: compact ? 5 : 7)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: compact ? 5 : 7)
                                        .stroke(isWinner ? BrandColors.yellow : .clear, lineWidth: isWinner ? 2 : 0)
                                )
                        }
                    }
                    .offset(x: offset + viewWidth / 2 - cellWidth / 2)
                }
                .frame(height: cellHeight)
                .clipShape(RoundedRectangle(cornerRadius: compact ? 6 : 10))
                .onChange(of: isActive) { _, active in
                    if active && !started {
                        startSpin(viewWidth: viewWidth)
                    }
                }
                .onAppear {
                    // Auto-start if this is the first one
                    if isActive && !started {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            startSpin(viewWidth: viewWidth)
                        }
                    }
                }
            }
            .frame(height: cellHeight)
        }
    }

    private func startSpin(viewWidth: CGFloat) {
        guard !started else { return }
        started = true

        let totalCell = cellWidth + cellSpacing
        let target = -CGFloat(data.winnerIndex) * totalCell

        withAnimation(
            .timingCurve(0.1, 0.7, 0.2, 1.0, duration: duration)
        ) {
            offset = target
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showWinner = true
            }
            onComplete()
        }
    }
}
