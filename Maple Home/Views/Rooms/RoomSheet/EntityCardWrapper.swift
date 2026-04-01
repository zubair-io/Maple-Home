import SwiftUI

struct EntityCardWrapper<Content: View>: View {
    var railColor: Color
    @ViewBuilder var content: Content

    var body: some View {
        HStack(spacing: 0) {
            // Left color rail
            Rectangle()
                .fill(railColor)
                .frame(width: 3)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: Radius.md,
                        bottomLeadingRadius: Radius.md
                    )
                )

            // Content area
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .padding(14)
            .padding(.leading, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.mapleSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .stroke(Color.mapleBorder, lineWidth: 1)
        )
        .mapleShadowSm()
    }
}
