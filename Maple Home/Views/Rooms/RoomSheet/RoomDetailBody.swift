import SwiftUI

struct RoomDetailBody: View {
    let room: Room
    @Environment(DashboardViewModel.self) private var vm

    /// Live entities for this room's area, always current
    private var areaEntities: [HAEntity] {
        vm.entities.values.filter { $0.areaId == room.id }
    }

    private var lightEntities: [HAEntity] {
        areaEntities.filter { $0.domain == .light }
    }

    private var occupancyEntities: [HAEntity] {
        areaEntities.filter { $0.domain == .binarySensor && ($0.attributes.deviceClass == "occupancy" || $0.attributes.deviceClass == "motion" || $0.attributes.deviceClass == "presence") }
    }

    private var climateEntities: [HAEntity] {
        areaEntities.filter { $0.domain == .climate }
    }

    private var mediaEntities: [HAEntity] {
        areaEntities.filter { $0.domain == .mediaPlayer }
    }

    private var coverEntities: [HAEntity] {
        areaEntities.filter { $0.domain == .cover }
    }

    private var switchEntities: [HAEntity] {
        areaEntities.filter { $0.domain == .switch || $0.domain == .inputBoolean }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MapleSpacing.s3) {
            // Summary badges
            HStack(spacing: Spacing.sp2) {
                if let temp = room.currentTemp {
                    MapleBadge(text: "\(Int(temp))°F", style: .info)
                }
                if room.isLit {
                    MapleBadge(text: "\(room.lightsOnCount) on", style: .on)
                }
                if room.isOccupied {
                    MapleBadge(text: "Occupied", style: .ok)
                }
            }
            .padding(.bottom, MapleSpacing.s2)

            // Individual light cards
            ForEach(lightEntities) { entity in
                LightCardView(entity: entity)
            }

            // Presence card — shown if room has occupancy sensors
            if !occupancyEntities.isEmpty {
                RoomPresenceCard(room: room)
            }

            // Climate card
            if !climateEntities.isEmpty {
                MapleSection(label: "Climate")
                RoomClimateCard(room: room)
            }

            // Media card
            if !mediaEntities.isEmpty {
                MapleSection(label: "Media")
                RoomMediaCard(room: room)
            }

            // Humidity card
            if room.humidity != nil {
                MapleSection(label: "Environment")
                RoomHumidityCard(room: room)
            }

            // Cover/garage card
            if !coverEntities.isEmpty {
                MapleSection(label: "Covers")
                RoomGarageCard(room: room)
            }

            // Switches/appliances card
            if !switchEntities.isEmpty {
                MapleSection(label: "Switches")
                RoomAppliancesCard(room: room)
            }

            // Devices card — catches remaining entities
            RoomDevicesCard(room: room)
        }
    }
}
