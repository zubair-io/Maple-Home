import SwiftUI

struct RoomSheetView: View {
    let room: Room?
    let isPresented: Bool
    var onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let screenHeight = proxy.size.height
            let maxSheetHeight = screenHeight * 0.88

            ZStack(alignment: .bottom) {
                // Scrim
                Color.black
                    .opacity(isPresented ? 0.35 : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss()
                    }
                    .animation(.easeInOut(duration: 0.25), value: isPresented)

                // Sheet
                if let room {
                    VStack(spacing: 0) {
                        SheetHeaderView(
                            floorName: room.floorName,
                            roomName: room.name,
                            onClose: onDismiss
                        )

                        ScrollView(.vertical, showsIndicators: false) {
                            RoomDetailBody(room: room)
                                .padding(.horizontal, MapleSpacing.s6)
                                .padding(.top, MapleSpacing.s4)
                                .padding(.bottom, MapleSpacing.s8)
                        }
                    }
                    .frame(maxHeight: maxSheetHeight)
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: Radius.lg,
                            topTrailingRadius: Radius.lg
                        )
                        .fill(Color.mapleBase)
                    )
                    .shadow(color: .black.opacity(0.13), radius: 20, x: 0, y: -8)
                    .offset(y: isPresented ? max(0, dragOffset) : screenHeight)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.height > 0 {
                                    dragOffset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                let shouldDismiss = value.translation.height > 100
                                    || value.predictedEndTranslation.height > 300
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                                    dragOffset = 0
                                    if shouldDismiss {
                                        onDismiss()
                                    }
                                }
                            }
                    )
                    .animation(.spring(response: 0.38, dampingFraction: 0.82), value: isPresented)
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .ignoresSafeArea()
    }
}
