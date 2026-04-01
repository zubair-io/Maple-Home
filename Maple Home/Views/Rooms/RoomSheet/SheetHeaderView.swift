import SwiftUI

struct SheetHeaderView: View {
    let floorName: String?
    let roomName: String
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Handle pill
            Capsule()
                .fill(Color.mapleT4)
                .frame(width: 36, height: 4)
                .padding(.top, 14)
                .padding(.bottom, 10)

            // Header content
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if let floorName {
                        Text(floorName.uppercased())
                            .font(MapleFont.bodyBold(9))
                            .kerning(1.6)
                            .foregroundColor(.mapleAccent)
                    }

                    Text(roomName)
                        .font(MapleFont.displayBold(22))
                        .foregroundColor(.mapleT1)
                }

                Spacer()

                MapleIconButton(systemImage: "xmark", size: 28) {
                    onClose()
                }
            }
            .padding(.horizontal, MapleSpacing.s6)
            .padding(.bottom, MapleSpacing.s4)

            // Bottom divider
            Rectangle()
                .fill(Color.mapleBorder)
                .frame(height: 1)
        }
    }
}
