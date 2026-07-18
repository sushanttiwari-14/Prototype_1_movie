import SwiftUI

struct ContentView: View {
    let store: SyncTableStore

    var body: some View {
        @Bindable var store = store
        NavigationStack(path: $store.path) {
            ZStack {
                WarmBackground()
                stageView
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            }
            .toolbar {
                if store.stage != .home {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            if let previous = AppStage(rawValue: max(0, store.stage.rawValue - 1)) {
                                store.go(previous)
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .accessibilityLabel("Back")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.showDeveloperMenu.toggle()
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Demo controls")
                }
            }
            .sheet(isPresented: $store.showDeveloperMenu) {
                DeveloperMenu(store: store)
                    .presentationDetents([.medium])
            }
            .alert("Sync Table", isPresented: Binding(get: { store.errorMessage != nil }, set: { if !$0 { store.errorMessage = nil } })) {
                Button("OK") { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
    }

    @ViewBuilder private var stageView: some View {
        switch store.stage {
        case .home: HomeView(store: store)
        case .invite: InviteView(store: store)
        case .matching: MatchingView(store: store)
        case .menu: SharedMenuView(store: store)
        case .carts: DualCartView(store: store)
        case .checkout: CheckoutView(store: store)
        case .tracking: TrackingView(store: store)
        case .firstBite: FirstBiteView(store: store)
        case .dining: DiningView(store: store)
        case .memory: MemoryView(store: store)
        }
    }
}

struct DeveloperMenu: View {
    let store: SyncTableStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Demo Mode") {
                    Button("Join as Partner") { store.joinPartner() }
                    Button("Partner cart action") { store.simulatePartnerAction() }
                    Button("Set both ready") { store.setBothReady() }
                    Button("Advance delivery") { store.advanceSimulation() }
                    Button("Inject 4-minute delay") { store.injectDelay() }
                    Button("Complete both deliveries") { store.completeDeliveries() }
                    Button("Trigger first-bite countdown") { store.go(.firstBite) }
                }
                Section {
                    Button("Reset entire demo", role: .destructive) {
                        store.reset()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Demo Controls")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}

#Preview {
    ContentView(store: SyncTableStore())
}
