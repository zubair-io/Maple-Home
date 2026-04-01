import SwiftUI

// MARK: - Rooms View

struct RoomsView: View {
    @Environment(DashboardViewModel.self) private var dashboardVM
    @Environment(RoomsViewModel.self) private var roomsVM

    @State private var showSettings = false
    @State private var hasAppeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Main content
                VStack(spacing: 0) {
                    // Connection banner
                    if !dashboardVM.connectionState.isConnected {
                        ConnectionBannerView(state: dashboardVM.connectionState)
                            .padding(.horizontal, Spacing.sp4)
                            .padding(.top, Spacing.sp2)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Summary chips
                    if !roomsVM.allRooms.isEmpty {
                        summaryChips
                            .padding(.horizontal, Spacing.sp4)
                            .padding(.top, Spacing.sp4)
                            .padding(.bottom, Spacing.sp2)
                    }

                    // Hex grid
                    if roomsVM.floorSections.isEmpty && dashboardVM.dataSource == .live {
                        emptyState
                    } else {
                        HexGridView(
                            floorSections: roomsVM.floorSections,
                            selectedRoomId: roomsVM.selectedRoomId,
                            onSelectRoom: { roomId in
                                withAnimation(.spring(response: 0.22, dampingFraction: 0.7)) {
                                    roomsVM.selectRoom(roomId)
                                }
                            }
                        )
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 10)
                    }
                }
                .background(Color.base)

                // Custom bottom sheet overlay
                RoomSheetView(
                    room: roomsVM.selectedRoom,
                    isPresented: roomsVM.selectedRoomId != nil,
                    onDismiss: {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                            roomsVM.deselectRoom()
                        }
                    }
                )
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Rooms")
                        .font(MapleFont.displayBold(17))
                        .foregroundColor(.mapleT1)
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.textMuted)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .task {
            await dashboardVM.connect()
        }
        .onChange(of: dashboardVM.entities) { _, _ in
            roomsVM.buildRooms()
        }
        .onChange(of: dashboardVM.areas) { _, _ in
            roomsVM.buildRooms()
        }
        .onChange(of: dashboardVM.floors) { _, _ in
            roomsVM.buildRooms()
        }
        .onAppear {
            roomsVM.buildRooms()
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                hasAppeared = true
            }
        }
        .alert(
            "Error",
            isPresented: Bindable(dashboardVM).showCommandError,
            presenting: dashboardVM.commandError
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error.message)
        }
    }

    // MARK: - Summary Chips

    private var summaryChips: some View {
        HStack(spacing: Spacing.sp2) {
            summaryChip(
                icon: "person.fill",
                text: "\(roomsVM.occupiedCount) occupied",
                color: .mapleSuccess
            )
            summaryChip(
                icon: "lightbulb.fill",
                text: "\(roomsVM.lightsOnCount) lights on",
                color: .entityLight
            )
            if let avgTemp = roomsVM.averageTemp {
                summaryChip(
                    icon: "thermometer.medium",
                    text: "\(Int(avgTemp))° avg",
                    color: .mapleInfo
                )
            }
            Spacer()
        }
    }

    private func summaryChip(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(color)
            Text(text)
                .font(MapleFont.bodyBold(10))
                .foregroundColor(.mapleT2)
        }
        .padding(.horizontal, Spacing.sp3)
        .padding(.vertical, 5)
        .background(Color.mapleSurface)
        .cornerRadius(Radius.pill)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.sp4) {
            Image(systemName: "hexagon")
                .font(.system(size: 48))
                .foregroundStyle(Color.mapleT4)
            Text("No rooms found")
                .font(MapleFont.bodyRegular(14))
                .foregroundStyle(Color.mapleT3)
            Text("Rooms will appear once areas are set up in Home Assistant.")
                .font(MapleFont.bodyRegular(13))
                .foregroundStyle(Color.mapleT3)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sp10)
    }
}
