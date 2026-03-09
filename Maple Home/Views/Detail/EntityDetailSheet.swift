import SwiftUI

// MARK: - Entity Detail Sheet

struct EntityDetailSheet: View {
    let entity: HAEntity
    @Environment(\.dismiss) private var dismiss
    @Environment(DashboardViewModel.self) private var vm

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Icon header
                    EntityDetailHeader(entity: entity)
                        .padding(Spacing.sp6)

                    Divider().padding(.horizontal, Spacing.sp6)

                    // Primary controls
                    EntityDetailControls(entity: entity)
                        .padding(Spacing.sp6)

                    Divider().padding(.horizontal, Spacing.sp6)

                    // Attributes
                    EntityAttributesSection(entity: entity)
                        .padding(Spacing.sp6)
                }
            }
            .background(Color.base.ignoresSafeArea())
            .navigationTitle(entity.name)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(.lato(size: 14, weight: .bold))
                        .foregroundStyle(Color.accent)
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        #endif
    }
}

// MARK: - Detail Header

struct EntityDetailHeader: View {
    let entity: HAEntity

    var body: some View {
        HStack(spacing: Spacing.sp4) {
            // Icon badge
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(Color.surface)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)

                Image(systemName: entity.domain.activeSymbol)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(entity.domain.accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entity.name)
                    .font(.merriweather(size: 20, weight: .bold))
                    .foregroundStyle(Color.textPrimary)

                Text(entity.id)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(Color.textMuted)

                if let areaId = entity.areaId {
                    Text(areaId.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.lato(size: 12, weight: .light))
                        .foregroundStyle(Color.textMuted)
                }
            }
        }
    }
}

// MARK: - Detail Controls

struct EntityDetailControls: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var vm

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sp4) {
            switch entity.domain.controlStyle {
            case .toggle, .light:
                toggleControls
            case .climate:
                climateControls
            case .cover:
                coverControls
            case .mediaPlayer:
                mediaControls
            case .slider:
                sliderControls
            case .select:
                selectControls
            case .action:
                actionControls
            case .readOnly:
                readOnlyInfo
            case .timer:
                timerControls
            }
        }
    }

    // MARK: - Toggle Controls

    @ViewBuilder
    private var toggleControls: some View {
        HStack {
            Text("Power")
                .font(.lato(size: 13, weight: .bold))
                .foregroundStyle(Color.textSecondary)
            Spacer()
            Toggle("", isOn: Binding(
                get: { entity.isOn },
                set: { _, _ in Task { await vm.toggle(entity) } }
            ))
            .tint(entity.domain.accentColor)
            .labelsHidden()
        }

        if let brightness = entity.attributes.brightness {
            VStack(alignment: .leading, spacing: Spacing.sp2) {
                HStack {
                    Text("Brightness")
                        .font(.lato(size: 13, weight: .bold))
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text("\(Int(Double(brightness) / 255.0 * 100))%")
                        .font(.lato(size: 13))
                        .foregroundStyle(Color.textMuted)
                }
                Slider(value: Binding(
                    get: { Double(brightness) / 255.0 },
                    set: { newValue, _ in Task { await vm.setBrightness(entity, brightness: Int(newValue * 255)) } }
                ), in: 0...1)
                .tint(Color.entityLight)
            }
        }
    }

    // MARK: - Climate Controls

    @ViewBuilder
    private var climateControls: some View {
        if let currentTemp = entity.attributes.currentTemperature {
            HStack {
                Text("Current Temperature")
                    .font(.lato(size: 13, weight: .bold))
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text(String(format: "%.1f\u{00B0}", currentTemp))
                    .font(.merriweather(size: 20, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
            }
        }

        if let targetTemp = entity.attributes.targetTemperature {
            HStack {
                Text("Target Temperature")
                    .font(.lato(size: 13, weight: .bold))
                    .foregroundStyle(Color.textSecondary)
                Spacer()

                Button {
                    Task { await vm.setTemperature(entity, temperature: targetTemp - 0.5) }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.textMuted)
                }
                .buttonStyle(.plain)

                Text(String(format: "%.1f\u{00B0}", targetTemp))
                    .font(.merriweather(size: 24, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(minWidth: 60, alignment: .center)

                Button {
                    Task { await vm.setTemperature(entity, temperature: targetTemp + 0.5) }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.accent)
                }
                .buttonStyle(.plain)
            }
        }

        if let modes = entity.attributes.hvacModes, modes.count > 1 {
            VStack(alignment: .leading, spacing: Spacing.sp2) {
                Text("Mode")
                    .font(.lato(size: 13, weight: .bold))
                    .foregroundStyle(Color.textSecondary)
                HvacModePickerView(
                    modes: modes,
                    activeMode: entity.state,
                    accentColor: entity.domain.accentColor
                ) { mode in
                    Task { await vm.setHvacMode(entity, mode: mode) }
                }
            }
        }
    }

    // MARK: - Cover Controls

    @ViewBuilder
    private var coverControls: some View {
        if let position = entity.attributes.currentPosition {
            VStack(alignment: .leading, spacing: Spacing.sp2) {
                HStack {
                    Text("Position")
                        .font(.lato(size: 13, weight: .bold))
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text("\(position)%")
                        .font(.lato(size: 15, weight: .black))
                        .foregroundStyle(Color.textPrimary)
                }
                Slider(value: Binding(
                    get: { Double(position) / 100.0 },
                    set: { newValue, _ in Task { await vm.setCoverPosition(entity, position: Int(newValue * 100)) } }
                ), in: 0...1)
                .tint(Color.entityCool)
            }
        }

        HStack(spacing: Spacing.sp3) {
            Button { Task { await vm.openCover(entity) } } label: {
                Label("Open", systemImage: "chevron.up")
            }
            .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))

            Button { Task { await vm.stopCover(entity) } } label: {
                Label("Stop", systemImage: "stop.fill")
            }
            .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))

            Button { Task { await vm.closeCover(entity) } } label: {
                Label("Close", systemImage: "chevron.down")
            }
            .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))
        }
    }

    // MARK: - Media Controls

    @ViewBuilder
    private var mediaControls: some View {
        HStack(spacing: Spacing.sp6) {
            Button { } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.textMuted)
            }
            .buttonStyle(.plain)

            Button { Task { await vm.mediaPlayPause(entity) } } label: {
                Image(systemName: entity.state == "playing" ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.entityMedia)
            }
            .buttonStyle(.plain)

            Button { } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.textMuted)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)

        if let volume = entity.attributes.volumeLevel {
            VStack(alignment: .leading, spacing: Spacing.sp2) {
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundStyle(Color.textMuted)
                    Slider(value: Binding(
                        get: { volume },
                        set: { newValue, _ in Task { await vm.setVolume(entity, level: newValue) } }
                    ), in: 0...1)
                    .tint(Color.entityMedia)
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundStyle(Color.textMuted)
                }
            }
        }
    }

    // MARK: - Slider Controls

    @ViewBuilder
    private var sliderControls: some View {
        if let value = Double(entity.state) {
            VStack(alignment: .leading, spacing: Spacing.sp2) {
                HStack {
                    Text("Value")
                        .font(.lato(size: 13, weight: .bold))
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Text("\(entity.state)\(entity.attributes.unitOfMeasurement ?? "")")
                        .font(.lato(size: 15, weight: .black))
                        .foregroundStyle(Color.textPrimary)
                }
                Slider(value: .constant(value), in: 0...100)
                    .tint(entity.domain.accentColor)
            }
        }
    }

    // MARK: - Select Controls

    @ViewBuilder
    private var selectControls: some View {
        if let options = entity.attributes.options {
            VStack(alignment: .leading, spacing: Spacing.sp2) {
                Text("Options")
                    .font(.lato(size: 13, weight: .bold))
                    .foregroundStyle(Color.textSecondary)

                ForEach(options, id: \.self) { option in
                    Button {
                        Task { await vm.selectOption(entity, option: option) }
                    } label: {
                        HStack {
                            Text(option)
                                .font(.lato(size: 14))
                                .foregroundStyle(option == entity.state ? Color.accent : Color.textPrimary)
                            Spacer()
                            if option == entity.state {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accent)
                            }
                        }
                        .padding(.vertical, Spacing.sp2)
                    }
                    .buttonStyle(.plain)
                    Divider()
                }
            }
        }
    }

    // MARK: - Action Controls

    @ViewBuilder
    private var actionControls: some View {
        Button {
            Task {
                if entity.domain == .scene {
                    await vm.activateScene(entity)
                } else {
                    await vm.triggerButton(entity)
                }
            }
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text(entity.domain == .scene ? "Activate Scene" : "Run")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(MapleButtonStyle(variant: .primary))
    }

    // MARK: - Read-Only Info

    @ViewBuilder
    private var readOnlyInfo: some View {
        HStack {
            Text("State")
                .font(.lato(size: 13, weight: .bold))
                .foregroundStyle(Color.textSecondary)
            Spacer()
            Text(entity.state)
                .font(.merriweather(size: 20, weight: .bold))
                .foregroundStyle(Color.textPrimary)
            if let unit = entity.attributes.unitOfMeasurement {
                Text(unit)
                    .font(.lato(size: 12, weight: .light))
                    .foregroundStyle(Color.textMuted)
            }
        }
    }

    // MARK: - Timer Controls

    @ViewBuilder
    private var timerControls: some View {
        Text(entity.state)
            .font(.lato(size: 24, weight: .black))
            .foregroundStyle(Color.textPrimary)
            .frame(maxWidth: .infinity, alignment: .center)

        HStack(spacing: Spacing.sp3) {
            Button { } label: {
                Label("Start", systemImage: "play.fill")
            }
            .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))

            Button { } label: {
                Label("Pause", systemImage: "pause.fill")
            }
            .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))

            Button { } label: {
                Label("Cancel", systemImage: "xmark")
            }
            .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Attributes Section

struct EntityAttributesSection: View {
    let entity: HAEntity

    private var rows: [(String, String)] {
        let excluded = Set(["friendly_name", "icon", "supported_features",
                           "attribution", "entity_picture"])
        return entity.attributes.rawKeyValues
            .filter { !excluded.contains($0.key) }
            .sorted { $0.key < $1.key }
            .map { (
                $0.key.replacingOccurrences(of: "_", with: " ").capitalized,
                $0.value
            ) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sp3) {
            Text("ATTRIBUTES")
                .font(.lato(size: 11, weight: .bold))
                .foregroundStyle(Color.textMuted)
                .tracking(1.0)

            if rows.isEmpty {
                Text("No attributes available.")
                    .font(.lato(size: 13))
                    .foregroundStyle(Color.textFaint)
            } else {
                ForEach(rows, id: \.0) { key, value in
                    HStack {
                        Text(key)
                            .font(.lato(size: 13, weight: .bold))
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text(value)
                            .font(.lato(size: 13))
                            .foregroundStyle(Color.textMuted)
                            .multilineTextAlignment(.trailing)
                    }
                    .contentShape(Rectangle())
                    Divider()
                }
            }
        }
    }
}
