import SwiftUI

// MARK: - Week State
enum WeekState {
    case passed
    case current
    case future
}

// MARK: - Wallpaper View
/// The full-screen wallpaper rendering.
/// Uses GeometryReader to scale proportionally at any resolution.
struct WallpaperView: View {
    let columns = 4
    let rows = 13
    let totalWeeks = 52
    let accentHex = "34D399" // Mint Green

    private var currentWeek: Int {
        let cal = Calendar(identifier: .iso8601)
        return cal.component(.weekOfYear, from: Date())
    }

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // --- Sizing ---
            let circleSize  = w * 0.052
            let hSpacing    = circleSize * 1.4
            let vSpacing    = circleSize * 1.05

            // Grid dimensions (for centering)
            let gridW = CGFloat(columns) * circleSize + CGFloat(columns - 1) * hSpacing
            let gridH = CGFloat(rows) * circleSize + CGFloat(rows - 1) * vSpacing

            ZStack {
                // Background
                Color(hex: "0A0A0A")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // ── Year Label ──
                    Text(String(currentYear))
                        .font(.system(size: w * 0.055, weight: .ultraLight, design: .rounded))
                        .foregroundColor(.white.opacity(0.22))
                        .kerning(6)
                        .padding(.bottom, h * 0.008)

                    // ── Week Counter ──
                    Text("WEEK \(currentWeek) OF \(totalWeeks)")
                        .font(.system(size: w * 0.022, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: accentHex).opacity(0.55))
                        .kerning(2)
                        .padding(.bottom, h * 0.045)

                    // ── Circle Grid ──
                    VStack(spacing: vSpacing) {
                        ForEach(0..<rows, id: \.self) { row in
                            HStack(spacing: hSpacing) {
                                ForEach(0..<columns, id: \.self) { col in
                                    let weekNum = row * columns + col + 1
                                    if weekNum <= totalWeeks {
                                        weekCircle(
                                            weekNumber: weekNum,
                                            size: circleSize
                                        )
                                    } else {
                                        Color.clear
                                            .frame(width: circleSize, height: circleSize)
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: gridW, height: gridH)

                    Spacer()

                    // ── Subtle progress bar ──
                    progressBar(width: gridW, height: 2)
                        .padding(.bottom, h * 0.06)
                }
            }
        }
    }

    // MARK: - Week Circle
    @ViewBuilder
    private func weekCircle(weekNumber: Int, size: CGFloat) -> some View {
        let state = weekState(for: weekNumber)

        ZStack {
            switch state {
            case .passed:
                Circle()
                    .fill(.white.opacity(0.82))
                    .frame(width: size, height: size)

            case .current:
                // Glow layer
                Circle()
                    .fill(Color(hex: accentHex).opacity(0.25))
                    .frame(width: size * 1.8, height: size * 1.8)
                    .blur(radius: size * 0.4)

                // Main dot
                Circle()
                    .fill(Color(hex: accentHex))
                    .frame(width: size, height: size)
                    .shadow(color: Color(hex: accentHex).opacity(0.6), radius: size * 0.6)

            case .future:
                Circle()
                    .stroke(.white.opacity(0.10), lineWidth: max(1, size * 0.055))
                    .frame(width: size, height: size)
            }
        }
        .frame(width: size, height: size)
    }

    // MARK: - Progress Bar
    @ViewBuilder
    private func progressBar(width: CGFloat, height: CGFloat) -> some View {
        let progress = CGFloat(min(currentWeek, totalWeeks)) / CGFloat(totalWeeks)

        ZStack(alignment: .leading) {
            // Track
            RoundedRectangle(cornerRadius: height / 2)
                .fill(.white.opacity(0.06))
                .frame(width: width, height: height)

            // Fill
            RoundedRectangle(cornerRadius: height / 2)
                .fill(Color(hex: accentHex).opacity(0.45))
                .frame(width: width * progress, height: height)
        }
    }

    // MARK: - Helpers
    private func weekState(for week: Int) -> WeekState {
        if week < currentWeek { return .passed }
        if week == currentWeek { return .current }
        return .future
    }
}

// MARK: - Preview
#Preview {
    WallpaperView()
        .frame(width: 393, height: 852)
}
