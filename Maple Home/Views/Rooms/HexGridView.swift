import SwiftUI

// MARK: - Hex Grid View (Floor-Grouped, Vertical Only)

struct HexGridView: View {
    let floorSections: [FloorSection]
    let selectedRoomId: String?
    let onSelectRoom: (String) -> Void

    var body: some View {
        GeometryReader { proxy in
            let tw = HexGeometry.tileWidth(for: proxy.size.width)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.sp6) {
                    ForEach(floorSections) { section in
                        VStack(alignment: .leading, spacing: Spacing.sp3) {
                            // Floor label
                            Text(section.name.uppercased())
                                .font(MapleFont.label)
                                .kerning(1.4)
                                .foregroundColor(.mapleT3)
                                .padding(.horizontal, Spacing.sp4)

                            // Hex tiles in wrapping rows
                            HexFloorGrid(
                                rooms: section.rooms,
                                selectedRoomId: selectedRoomId,
                                tileWidth: tw,
                                containerWidth: proxy.size.width,
                                onSelectRoom: onSelectRoom
                            )
                        }
                    }
                }
                .padding(.vertical, Spacing.sp4)
            }
        }
    }
}

// MARK: - Hex Floor Grid (wrapping hex layout for one floor)

struct HexFloorGrid: View {
    let rooms: [Room]
    let selectedRoomId: String?
    let tileWidth: CGFloat
    let containerWidth: CGFloat
    let onSelectRoom: (String) -> Void

    private var geo: HexGeometry { HexGeometry(tileWidth: tileWidth) }

    /// Fixed 4 tiles per row
    private var tilesPerRow: Int { 4 }

    /// Assign grid positions automatically: fill rows left to right
    private var positionedRooms: [(room: Room, col: Int, row: Int)] {
        rooms.enumerated().map { (index, room) in
            let col = index % tilesPerRow
            let row = index / tilesPerRow
            return (room, col, row)
        }
    }

    private var rowCount: Int {
        guard !rooms.isEmpty else { return 0 }
        return (rooms.count - 1) / tilesPerRow + 1
    }

    var body: some View {
        let gridHeight = CGFloat(rowCount - 1) * geo.rowStep + geo.tileHeight + geo.oddOffset
        let gridWidth = CGFloat(min(rooms.count, tilesPerRow) - 1) * geo.colStep + tileWidth
        let xOffset = max(0, (containerWidth - gridWidth) / 2)

        ZStack(alignment: .topLeading) {
            ForEach(positionedRooms, id: \.room.id) { item in
                let pos = HexPosition(col: item.col, row: item.row)
                let origin = geo.origin(for: pos)

                HexTileView(
                    room: item.room,
                    isSelected: selectedRoomId == item.room.id,
                    hasSelection: selectedRoomId != nil,
                    tileWidth: tileWidth
                )
                .position(
                    x: origin.x + tileWidth / 2 + xOffset,
                    y: origin.y + geo.tileHeight / 2
                )
                .onTapGesture {
                    onSelectRoom(item.room.id)
                }
            }
        }
        .frame(width: containerWidth, height: max(0, gridHeight))
    }
}
