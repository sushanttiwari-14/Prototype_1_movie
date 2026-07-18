import Testing
import Foundation
@testable import Prototype_1_movie

@Suite("Sync Table core logic")
struct SyncTableTests {
    @Test("Menu Twin matching is deterministic")
    func matching() async {
        let service = DeterministicRestaurantMatchingService()
        let host = DemoData.catalogue.filter { $0.city == "Mumbai" }
        let partner = DemoData.catalogue.filter { $0.city == "Bengaluru" }
        let first = await service.matches(host: host, partner: partner)
        let second = await service.matches(host: host, partner: partner)
        #expect(first.map(\.score.total) == second.map(\.score.total))
        #expect(first.first?.score.menuSimilarity == 100)
        #expect(first.first?.theme == "North Indian Grill Night")
    }

    @Test("Cart ownership remains separate")
    @MainActor
    func cartOwnership() {
        let store = SyncTableStore()
        store.table.selectedPair = RestaurantPair(
            hostRestaurant: DemoData.catalogue[0],
            partnerRestaurant: DemoData.catalogue[1],
            score: .init(total: 91, menuSimilarity: 89, predictedDifference: 3, priceCompatible: true, prepCompatible: true),
            theme: "North Indian Grill Night"
        )
        store.addHostItem(DemoData.catalogue[0].menu[0])
        #expect(store.table.hostCart.itemCount == 1)
        #expect(store.table.partnerCart.itemCount == 0)
        store.simulatePartnerAction()
        #expect(store.table.hostCart.itemCount == 1)
        #expect(store.table.partnerCart.itemCount == 1)
    }

    @Test("Checkout is gated by both readiness states")
    func readinessGate() async throws {
        let service = MockLinkedOrderService()
        var table = sampleTable()
        await #expect(throws: OrderError.self) { try await service.submit(table: table) }
        table.hostReady = true
        table.partnerReady = true
        let orders = try await service.submit(table: table)
        #expect(orders.count == 2)
        #expect(orders[0].ownerID != orders[1].ownerID)
    }

    @Test("Shared milestone uses the slower individual order")
    @MainActor
    func divergentMilestone() {
        let store = SyncTableStore()
        store.table = sampleTable()
        store.table.orders = sampleOrders(host: .preparing, partner: .confirmed)
        #expect(store.sharedMilestone == .confirmed)
        store.table.orders[1].status = .preparing
        #expect(store.sharedMilestone == .preparing)
    }

    @Test("Fallback profile never invents logistics")
    func foundationFallback() async {
        let first = DemoData.mumbaiMenu[0]
        let second = DemoData.bengaluruMenu[0]
        let profile = await DeterministicMenuTwinService().profile(for: first, counterpart: second)
        #expect(profile.canonicalDishType == "Grilled paneer meal")
        #expect(profile.suitableCounterpart == second.name)
        #expect(profile.isVegetarian)
    }

    private func sampleTable() -> SyncTable {
        let pair = RestaurantPair(
            hostRestaurant: DemoData.catalogue[0],
            partnerRestaurant: DemoData.catalogue[1],
            score: .init(total: 91, menuSimilarity: 89, predictedDifference: 3, priceCompatible: true, prepCompatible: true),
            theme: "North Indian Grill Night"
        )
        return .init(
            id: "ST-TEST", createdAt: .now, host: DemoData.aniket, partner: DemoData.aisha, selectedPair: pair,
            hostCart: .init(id: UUID(), ownerID: DemoData.aniket.id, items: [.init(menuItem: DemoData.mumbaiMenu[0], quantity: 1)]),
            partnerCart: .init(id: UUID(), ownerID: DemoData.aisha.id, items: [.init(menuItem: DemoData.bengaluruMenu[0], quantity: 1)]),
            hostReady: false, partnerReady: false, orders: []
        )
    }

    private func sampleOrders(host: IndividualOrderStatus, partner: IndividualOrderStatus) -> [LinkedOrder] {
        [
            .init(id: "A", ownerID: DemoData.aniket.id, restaurantName: "A", address: DemoData.aniket.address, total: 1, status: host, estimate: .init(minutes: 40, window: "8:00"), paymentAuthorized: true),
            .init(id: "B", ownerID: DemoData.aisha.id, restaurantName: "B", address: DemoData.aisha.address, total: 1, status: partner, estimate: .init(minutes: 43, window: "8:03"), paymentAuthorized: true)
        ]
    }
}
