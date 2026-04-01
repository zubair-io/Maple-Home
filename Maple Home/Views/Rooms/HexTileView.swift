import SwiftUI

// MARK: - Flat-Top Hex Shape

struct HexShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        // Flat-top: (25%,0) → (75%,0) → (100%,50%) → (75%,100%) → (25%,100%) → (0,50%)
        var path = Path()
        path.move(to: CGPoint(x: w * 0.25, y: 0))
        path.addLine(to: CGPoint(x: w * 0.75, y: 0))
        path.addLine(to: CGPoint(x: w, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.75, y: h))
        path.addLine(to: CGPoint(x: w * 0.25, y: h))
        path.addLine(to: CGPoint(x: 0, y: h * 0.5))
        path.closeSubpath()
        return path
    }
}

// MARK: - Hex Geometry

struct HexGeometry {
    let tileWidth: CGFloat
    var tileHeight: CGFloat { tileWidth * 0.865 }
    var colStep: CGFloat { tileWidth * 0.76 }
    var rowStep: CGFloat { tileHeight * 1.035 }
    var oddOffset: CGFloat { tileHeight * 0.52 }

    static func tileWidth(for screenWidth: CGFloat) -> CGFloat {
        // Size tiles so 4 fit per row: 3 colSteps + 1 full tile, with padding
        let usable = screenWidth - 32 // Spacing.sp4 * 2
        // tileWidth + 3 * (tileWidth * 0.76) = usable → tileWidth * 3.28 = usable
        return usable / 3.28
    }

    func origin(for position: HexPosition) -> CGPoint {
        let x = CGFloat(position.col) * colStep
        let y = CGFloat(position.row) * rowStep + (position.col % 2 == 1 ? oddOffset : 0)
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Hex Tile View

struct HexTileView: View {
    let room: Room
    let isSelected: Bool
    let hasSelection: Bool
    let tileWidth: CGFloat

    private var geo: HexGeometry { HexGeometry(tileWidth: tileWidth) }

    // Temperature color coding
    private var tempColor: Color {
        guard let temp = room.currentTemp else { return .mapleT3 }
        switch temp {
        case ..<66:  return .tempCold
        case ..<69:  return .tempCool
        case ..<74:  return .tempNorm
        default:     return .tempWarm
        }
    }

    // Fill state
    private var fillColor: Color {
        if room.isLit && room.isOccupied {
            return Color(hex: "#FFF8F5")
        }
        if room.isLit {
            return Color(hex: "#FFFAF7")
        }
        if room.isOccupied {
            return Color(hex: "#F7FAF8")
        }
        return .mapleSurface
    }

    var body: some View {
        let h = geo.tileHeight

        ZStack {
            // Fill
            HexShape()
                .fill(fillColor)

            // Border
            HexShape()
                .stroke(
                    isSelected ? Color.mapleAccent : Color.mapleBorderStrong,
                    lineWidth: isSelected ? 2.5 : 0.5
                )

            // Content
            VStack(spacing: 2) {
                Text(room.currentTemp.map { "\(Int($0))°" } ?? "–")
                    .font(MapleFont.bodyHeavy(11))
                    .foregroundColor(room.currentTemp != nil ? tempColor : .mapleT4)
                    .lineLimit(1)

                Text(room.shortName)
                    .font(MapleFont.bodyBold(7))
                    .foregroundColor(.mapleT2)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .textCase(.uppercase)

                // Indicator dots
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.mapleAccent)
                        .opacity(room.isLit ? 1.0 : 0.2)
                        .frame(width: 4, height: 4)
                        .shadow(color: room.isLit ? Color.mapleAccent.opacity(0.6) : .clear, radius: 5)

                    Circle()
                        .fill(Color.mapleSuccess)
                        .opacity(room.isOccupied ? 1.0 : 0.2)
                        .frame(width: 4, height: 4)
                        .shadow(color: room.isOccupied ? Color.mapleSuccess.opacity(0.6) : .clear, radius: 5)
                }
                .padding(.top, 1)
            }
            .padding(.horizontal, tileWidth * 0.08)

            // Occupancy pulse dot — top-right corner
            if room.isOccupied {
                Circle()
                    .fill(Color.mapleSuccess)
                    .frame(width: 6, height: 6)
                    .shadow(color: .mapleSuccess.opacity(0.6), radius: 4)
                    .modifier(OccupancyPulse())
                    .position(x: tileWidth * 0.72, y: h * 0.15)
            }
        }
        .frame(width: tileWidth, height: h)
        .clipShape(HexShape())
        .scaleEffect(isSelected ? 1.08 : (hasSelection && !isSelected ? 0.97 : 1.0))
        .opacity(hasSelection && !isSelected ? 0.65 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.7), value: isSelected)
        .animation(.easeOut(duration: 0.18), value: hasSelection)
    }
}

// MARK: - Occupancy Pulse Animation

struct OccupancyPulse: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 0.85 : 1.0)
            .animation(
                .easeInOut(duration: 2.2).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}
