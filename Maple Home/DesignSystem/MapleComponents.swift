// MapleComponents.swift
// Shared primitives used across all entity cards

import SwiftUI

// MARK: - Entity Card Shell

struct MapleCard<Content: View>: View {
    var category: HACategory = .control
    var isActive: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(category.color)
                .frame(height: 2)
            content
                .padding(MapleSpacing.s5)
        }
        .background(Color.mapleSurface)
        .clipShape(RoundedRectangle(cornerRadius: MapleRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MapleRadius.lg, style: .continuous)
                .stroke(isActive ? category.color : Color.clear, lineWidth: 1.5)
        )
        .mapleShadowSm()
    }
}

// MARK: - Card Header

struct MapleCardHeader: View {
    var entityType: String
    var name: String
    var area: String? = nil
    var badgeStyle: MapleBadgeStyle? = nil
    var badgeText: String? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack(alignment: .top, spacing: MapleSpacing.s3) {
            VStack(alignment: .leading, spacing: 3) {
                Text(entityType.uppercased())
                    .font(MapleFont.label)
                    .kerning(1.4)
                    .foregroundColor(.mapleT4)
                Text(name)
                    .font(MapleFont.displayBold(15))
                    .foregroundColor(.mapleT1)
                    .fixedSize(horizontal: false, vertical: true)
                if let area {
                    Text(area)
                        .font(MapleFont.bodyLight(11))
                        .foregroundColor(.mapleT3)
                }
            }
            Spacer()
            if let style = badgeStyle, let text = badgeText {
                MapleBadge(text: text, style: style)
            }
            if let trailing {
                trailing
            }
        }
        .padding(.bottom, MapleSpacing.s3)
    }
}

// MARK: - State Badge

struct MapleBadge: View {
    var text: String
    var style: MapleBadgeStyle
    var showDot: Bool = true

    var body: some View {
        HStack(spacing: 4) {
            if showDot {
                Circle()
                    .fill(style.fgColor)
                    .frame(width: 5, height: 5)
            }
            Text(text)
                .font(MapleFont.bodyBold(11))
                .kerning(0.3)
                .foregroundColor(style.fgColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(style.bgColor)
        .clipShape(Capsule())
    }
}

// MARK: - Maple Toggle

struct MapleToggle: View {
    @Binding var isOn: Bool
    var onChange: ((Bool) -> Void)? = nil

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? Color.mapleAccent : Color.mapleT4)
                .frame(width: 46, height: 26)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isOn)
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                .padding(3)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isOn)
        }
        .frame(width: 46, height: 26)
        .onTapGesture {
            isOn.toggle()
            onChange?(isOn)
        }
    }
}

// MARK: - Maple Slider

struct MapleSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...100
    var label: String? = nil
    var valueFormat: (Double) -> String = { "\(Int($0))%" }
    var accentColor: Color = .mapleAccent

    var body: some View {
        VStack(spacing: MapleSpacing.s2) {
            if label != nil || true {
                HStack {
                    if let label {
                        Text(label.uppercased())
                            .font(MapleFont.label)
                            .kerning(0.8)
                            .foregroundColor(.mapleT3)
                    }
                    Spacer()
                    Text(valueFormat(value))
                        .font(MapleFont.displayBold(13))
                        .foregroundColor(.mapleT1)
                }
            }
            GeometryReader { geo in
                let pct = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
                let thumbD: CGFloat = 18

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.mapleT4.opacity(0.4))
                        .frame(height: 4)
                    Capsule()
                        .fill(accentColor)
                        .frame(width: max(0, pct * geo.size.width), height: 4)
                    Circle()
                        .fill(Color.mapleSurface)
                        .frame(width: thumbD, height: thumbD)
                        .overlay(Circle().stroke(accentColor, lineWidth: 3))
                        .shadow(color: accentColor.opacity(0.35), radius: 4, x: 0, y: 1)
                        .offset(x: max(0, min(pct * geo.size.width - thumbD / 2, geo.size.width - thumbD)))
                }
                .frame(height: thumbD)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let pctNew = drag.location.x / geo.size.width
                        let clamped = max(0, min(1, pctNew))
                        value = range.lowerBound + clamped * (range.upperBound - range.lowerBound)
                    }
                )
            }
            .frame(height: 18)
        }
    }
}

// MARK: - Color Temp Slider

struct ColorTempSlider: View {
    @Binding var kelvin: Double

    var body: some View {
        VStack(spacing: MapleSpacing.s2) {
            HStack {
                Text("COLOR TEMP")
                    .font(MapleFont.label)
                    .kerning(0.8)
                    .foregroundColor(.mapleT3)
                Spacer()
                Text("\(Int(kelvin))K")
                    .font(MapleFont.displayBold(13))
                    .foregroundColor(.mapleT1)
            }
            GeometryReader { geo in
                let pct = CGFloat((kelvin - 2000) / (6500 - 2000))
                let thumbD: CGFloat = 18
                ZStack(alignment: .leading) {
                    LinearGradient(
                        colors: [Color(hex: "#FFD27F"), Color(hex: "#FFF4D6"), Color(hex: "#C8E8FF")],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .frame(height: 4)
                    .clipShape(Capsule())

                    Circle()
                        .fill(Color.white)
                        .frame(width: thumbD, height: thumbD)
                        .overlay(Circle().stroke(Color.mapleT2, lineWidth: 3))
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                        .offset(x: max(0, min(pct * geo.size.width - thumbD/2, geo.size.width - thumbD)))
                }
                .frame(height: thumbD)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let p = max(0, min(1, drag.location.x / geo.size.width))
                        kelvin = 2000 + p * (6500 - 2000)
                    }
                )
            }
            .frame(height: 18)
        }
    }
}

// MARK: - Mode Pills

struct ModePills: View {
    var options: [String]
    @Binding var selected: String
    var accentStyle: Bool = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MapleSpacing.s2) {
                ForEach(options, id: \.self) { opt in
                    let isSelected = opt == selected
                    Button(opt) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                            selected = opt
                        }
                    }
                    .font(MapleFont.bodyBold(11))
                    .kerning(0.3)
                    .foregroundColor(isSelected ? .white : .mapleT3)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isSelected ? (accentStyle ? Color.mapleAccent : Color.mapleT1) : Color.mapleSurface2)
                    .clipShape(Capsule())
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: selected)
                }
            }
            .padding(.horizontal, 1)
        }
    }
}

// MARK: - Arc Progress

struct MapleArc: View {
    var value: Double
    var label: String
    var sublabel: String
    var size: CGFloat = 88
    var strokeWidth: CGFloat = 6
    var color: Color = .mapleAccent

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.mapleT4.opacity(0.3), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(135))
                .frame(width: size, height: size)
            Circle()
                .trim(from: 0, to: 0.75 * value)
                .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(135))
                .frame(width: size, height: size)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: value)
            GeometryReader { geo in
                let angle = Angle.degrees(135 + 270 * value)
                let r = (size - strokeWidth) / 2
                let cx = geo.size.width / 2
                let cy = geo.size.height / 2
                let x = cx + r * cos(angle.radians)
                let y = cy + r * sin(angle.radians)
                Circle()
                    .fill(color)
                    .frame(width: strokeWidth * 1.3, height: strokeWidth * 1.3)
                    .position(x: x, y: y)
                    .opacity(value > 0 ? 1 : 0)
            }
            .frame(width: size, height: size)
            VStack(spacing: 1) {
                Text(label)
                    .font(MapleFont.displayBold(size * 0.22))
                    .foregroundColor(.mapleT1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(sublabel.uppercased())
                    .font(.system(size: size * 0.09, weight: .bold))
                    .kerning(0.5)
                    .foregroundColor(.mapleT3)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Control Row

struct MapleControlRow: View {
    var label: String
    var icon: String? = nil
    var trailing: AnyView

    var body: some View {
        HStack(spacing: MapleSpacing.s3) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.mapleT3)
                    .frame(width: 18)
            }
            Text(label)
                .font(MapleFont.bodyRegular(13))
                .foregroundColor(.mapleT1)
            Spacer()
            trailing
        }
        .padding(.vertical, MapleSpacing.s3)
    }
}

// MARK: - Section Divider Label

struct MapleSection: View {
    var label: String

    var body: some View {
        HStack(spacing: MapleSpacing.s3) {
            Text(label.uppercased())
                .font(MapleFont.label)
                .kerning(1.4)
                .foregroundColor(.mapleT4)
            Rectangle()
                .fill(Color.mapleBorder)
                .frame(height: 1)
        }
        .padding(.top, MapleSpacing.s6)
        .padding(.bottom, MapleSpacing.s3)
    }
}

// MARK: - Sensor Value Display

struct SensorValueDisplay: View {
    var value: String
    var unit: String
    var valueSize: CGFloat = 52

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 4) {
            Text(value)
                .font(MapleFont.displayHero(valueSize))
                .foregroundColor(.mapleT1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(unit)
                .font(MapleFont.bodyLight(16))
                .foregroundColor(.mapleT3)
                .padding(.bottom, 6)
        }
    }
}

// MARK: - Number Stepper

struct MapleNumberStepper: View {
    @Binding var value: Double
    var step: Double = 1
    var range: ClosedRange<Double>
    var format: (Double) -> String = { "\(Int($0))" }

    var body: some View {
        HStack(spacing: MapleSpacing.s2) {
            Button {
                withAnimation(.spring(response: 0.2)) {
                    value = max(range.lowerBound, value - step)
                }
            } label: {
                Text("−")
                    .font(MapleFont.displayBold(20))
                    .foregroundColor(.mapleT1)
                    .frame(width: 36, height: 36)
                    .background(Color.mapleSurface2)
                    .cornerRadius(MapleRadius.sm)
            }
            Text(format(value))
                .font(MapleFont.displayBold(24))
                .foregroundColor(.mapleT1)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            Button {
                withAnimation(.spring(response: 0.2)) {
                    value = min(range.upperBound, value + step)
                }
            } label: {
                Text("+")
                    .font(MapleFont.displayBold(20))
                    .foregroundColor(.mapleT1)
                    .frame(width: 36, height: 36)
                    .background(Color.mapleSurface2)
                    .cornerRadius(MapleRadius.sm)
            }
        }
    }
}

// MARK: - Icon Button

struct MapleIconButton: View {
    var systemImage: String
    var size: CGFloat = 34
    var accent: Bool = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(accent ? .white : .mapleT2)
                .frame(width: size, height: size)
                .background(accent ? Color.mapleAccent : Color.mapleSurface2)
                .clipShape(Circle())
        }
    }
}

// MARK: - Cover Visual

struct CoverVisual: View {
    var position: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: MapleRadius.sm, style: .continuous)
                    .fill(Color.mapleSurface2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                RoundedRectangle(cornerRadius: MapleRadius.sm, style: .continuous)
                    .fill(Color.mapleT1)
                    .frame(height: geo.size.height * (1 - position / 100))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: position)
            }
        }
        .frame(height: 60)
    }
}

// MARK: - Lock Icon View

struct LockIconView: View {
    enum LockState { case locked, unlocked, jammed }
    var state: LockState

    var bgColor: Color {
        switch state {
        case .locked:   return .mapleSuccessDim
        case .unlocked: return .mapleWarningDim
        case .jammed:   return .mapleErrorDim
        }
    }
    var iconColor: Color {
        switch state {
        case .locked:   return .mapleSuccess
        case .unlocked: return .mapleWarning
        case .jammed:   return .mapleError
        }
    }
    var iconName: String {
        switch state {
        case .locked:   return "lock.fill"
        case .unlocked: return "lock.open.fill"
        case .jammed:   return "exclamationmark.lock.fill"
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: MapleRadius.xl, style: .continuous)
                .fill(bgColor)
                .frame(width: 80, height: 80)
            Image(systemName: iconName)
                .font(.system(size: 32, weight: .light))
                .foregroundColor(iconColor)
        }
        .animation(.spring(response: 0.3), value: state == .locked)
    }
}

// MARK: - Binary Sensor Row

struct BinarySensorRow: View {
    enum BinState { case clear, triggered, motion }
    var state: BinState
    var icon: String
    var label: String
    var timestamp: String

    var bgColor: Color {
        switch state {
        case .clear:     return .mapleSuccessDim
        case .triggered: return .mapleErrorDim
        case .motion:    return .mapleAccentDim
        }
    }
    var iconColor: Color {
        switch state {
        case .clear:     return .mapleSuccess
        case .triggered: return .mapleError
        case .motion:    return .mapleAccent
        }
    }

    var body: some View {
        HStack(spacing: MapleSpacing.s4) {
            ZStack {
                RoundedRectangle(cornerRadius: MapleRadius.md, style: .continuous)
                    .fill(bgColor)
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(MapleFont.displayBold(17))
                    .foregroundColor(state == .triggered ? .mapleError : state == .motion ? .mapleAccent : .mapleT1)
                Text(timestamp)
                    .font(MapleFont.bodyLight(11))
                    .foregroundColor(.mapleT3)
            }
        }
    }
}

// MARK: - Action Button

struct MapleActionButton: View {
    var label: String
    var icon: String? = nil
    var style: ActionStyle = .dark
    var action: () -> Void

    enum ActionStyle { case dark, accent, ghost, destructive }

    var bg: Color {
        switch style {
        case .dark:        return .mapleT1
        case .accent:      return .mapleAccent
        case .ghost:       return .clear
        case .destructive: return .mapleError
        }
    }
    var fg: Color {
        switch style {
        case .ghost: return .mapleT1
        default:     return .white
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: MapleSpacing.s2) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                }
                Text(label.uppercased())
                    .font(MapleFont.bodyBold(12))
                    .kerning(0.4)
            }
            .foregroundColor(fg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(bg)
            .cornerRadius(MapleRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: MapleRadius.md, style: .continuous)
                    .stroke(style == .ghost ? Color.mapleBorderStrong : .clear, lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Tag

struct MapleTag: View {
    var text: String

    var body: some View {
        Text(text)
            .font(MapleFont.bodyBold(10))
            .kerning(0.8)
            .foregroundColor(.mapleT3)
            .padding(.horizontal, MapleSpacing.s2)
            .padding(.vertical, 3)
            .background(Color.mapleSurface2)
            .cornerRadius(MapleRadius.xs)
    }
}

// MARK: - Divider Row

struct MapleDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.mapleBorder)
            .frame(height: 1)
            .padding(.vertical, MapleSpacing.s2)
    }
}

// MARK: - Connection Banner

struct ConnectionBannerView: View {
    let state: ConnectionState

    var body: some View {
        switch state {
        case .connecting, .authenticating:
            bannerContent(icon: nil, message: "Connecting...", showProgress: true)
        case .reconnecting(let attempt):
            bannerContent(icon: "exclamationmark.circle.fill", message: "Reconnecting (attempt \(attempt))...", showProgress: true)
        case .error(let error):
            bannerContent(icon: "exclamationmark.circle.fill", message: error.userMessage, showProgress: false)
        default:
            EmptyView()
        }
    }

    private func bannerContent(icon: String?, message: String, showProgress: Bool) -> some View {
        HStack(spacing: MapleSpacing.s3) {
            if let icon {
                Image(systemName: icon).foregroundStyle(Color.mapleError)
            }
            Text(message)
                .font(MapleFont.bodyBold(13))
                .foregroundStyle(Color.mapleT1)
            Spacer()
            if showProgress {
                ProgressView().controlSize(.small)
            }
        }
        .padding(MapleSpacing.s4)
        .background(Color.mapleSurface)
        .clipShape(RoundedRectangle(cornerRadius: MapleRadius.lg))
        .shadow(color: .black.opacity(0.12), radius: 32, x: 0, y: 8)
    }
}

// MARK: - Empty State View

struct EmptyExposedEntitiesView: View {
    var body: some View {
        VStack(spacing: MapleSpacing.s4) {
            Image(systemName: "house.circle")
                .font(.system(size: 48))
                .foregroundStyle(Color.mapleT4)
            Text("No exposed entities found.")
                .font(MapleFont.bodyRegular(14))
                .foregroundStyle(Color.mapleT3)
            Text("In Home Assistant, mark entities as exposed in Settings → Voice Assistants → Expose.")
                .font(MapleFont.bodyRegular(13))
                .foregroundStyle(Color.mapleT3)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MapleSpacing.s10)
    }
}

// MARK: - Primary Button Style

struct MapleButtonStyle: ButtonStyle {
    enum Variant { case primary, ghost }
    let variant: Variant
    var isFullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        switch variant {
        case .primary:
            configuration.label
                .font(MapleFont.bodyBold(14))
                .foregroundStyle(Color.white)
                .padding(.horizontal, MapleSpacing.s6)
                .padding(.vertical, MapleSpacing.s3)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .background(Color.mapleAccent)
                .clipShape(RoundedRectangle(cornerRadius: MapleRadius.pill))
                .opacity(configuration.isPressed ? 0.85 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
        case .ghost:
            configuration.label
                .font(MapleFont.bodyBold(12))
                .foregroundStyle(Color.mapleT1)
                .padding(.horizontal, MapleSpacing.s4)
                .padding(.vertical, MapleSpacing.s2)
                .background(Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: MapleRadius.pill))
                .overlay(
                    RoundedRectangle(cornerRadius: MapleRadius.pill)
                        .stroke(Color.mapleBorderStrong, lineWidth: 1)
                )
                .opacity(configuration.isPressed ? 0.7 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
                .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
        }
    }
}

// MARK: - Pill Badge

struct PillBadge: View {
    let text: String
    var foregroundColor: Color = .white
    var backgroundColor: Color = .mapleAccent

    var body: some View {
        Text(text.uppercased())
            .font(MapleFont.bodyBold(10))
            .tracking(0.5)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, MapleSpacing.s2)
            .padding(.vertical, 3)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: MapleRadius.pill))
    }
}
