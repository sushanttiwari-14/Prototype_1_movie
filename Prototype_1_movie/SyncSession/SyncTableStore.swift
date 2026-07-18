import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class SyncTableStore {
    var stage: AppStage = .home
    var path: [AppStage] = []
    var table: SyncTable
    var partnerJoined = false
    var matches: [RestaurantPair] = []
    var isMatching = false
    var events: [PartnerPresenceEvent] = []
    var selectedCategory = "Mains"
    var showDeveloperMenu = false
    var isSubmitting = false
    var errorMessage: String?
    var countdown: Int?
    var hostReadyToEat = false
    var partnerReadyToEat = false
    var reaction: String?
    var memory: SyncMemory?
    var liveActivityStarted = false

    private let catalogue: RestaurantCatalogueService
    private let matcher: RestaurantMatchingService
    private let orderService: LinkedOrderService
    private var simulationTask: Task<Void, Never>?

    init(
        catalogue: RestaurantCatalogueService? = nil,
        matcher: RestaurantMatchingService? = nil,
        orderService: LinkedOrderService? = nil
    ) {
        self.catalogue = catalogue ?? MockRestaurantCatalogueService()
        self.matcher = matcher ?? DeterministicRestaurantMatchingService()
        self.orderService = orderService ?? MockLinkedOrderService()
        self.table = SyncTable(
            id: "ST-7N4K",
            createdAt: Date(),
            host: DemoData.aniket,
            partner: DemoData.aisha,
            selectedPair: nil,
            hostCart: .init(id: UUID(), ownerID: DemoData.aniket.id, items: []),
            partnerCart: .init(id: UUID(), ownerID: DemoData.aisha.id, items: []),
            hostReady: false,
            partnerReady: false,
            orders: []
        )
    }

    func go(_ destination: AppStage) {
        withAnimation(.snappy) {
            stage = destination
        }
    }

    func joinPartner() {
        withAnimation(.bouncy) { partnerJoined = true }
        events.insert(.init(text: "Aisha joined from Bengaluru", symbol: "person.2.fill", date: .now), at: 0)
    }

    func findMatches() async {
        isMatching = true
        async let host = catalogue.restaurants(in: table.host.city)
        async let partner = catalogue.restaurants(in: table.partner.city)
        let result = await matcher.matches(host: host, partner: partner)
        try? await Task.sleep(for: .seconds(1.4))
        matches = Array(result.prefix(3))
        table.selectedPair = matches.first
        isMatching = false
    }

    func select(_ pair: RestaurantPair) {
        table.selectedPair = pair
        table.hostCart.items = []
        table.partnerCart.items = []
    }

    func addHostItem(_ item: MenuItem) {
        add(item, to: &table.hostCart)
    }

    private func add(_ item: MenuItem, to cart: inout Cart) {
        if let index = cart.items.firstIndex(where: { $0.menuItem.id == item.id }) {
            cart.items[index].quantity += 1
        } else {
            cart.items.append(.init(menuItem: item, quantity: 1))
        }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    func removeHostItem(_ item: MenuItem) {
        guard let index = table.hostCart.items.firstIndex(where: { $0.menuItem.id == item.id }) else { return }
        if table.hostCart.items[index].quantity > 1 { table.hostCart.items[index].quantity -= 1 }
        else { table.hostCart.items.remove(at: index) }
    }

    func simulatePartnerAction() {
        guard let menu = table.selectedPair?.partnerRestaurant.menu, !menu.isEmpty else { return }
        let next = menu[table.partnerCart.items.count % menu.count]
        add(next, to: &table.partnerCart)
        events.insert(.init(text: "Aisha added \(next.name)", symbol: "plus.circle.fill", date: .now), at: 0)
        reaction = ["😍", "🤌", "🌶️"].randomElement()
    }

    func seedCarts() {
        guard let pair = table.selectedPair else { return }
        if table.hostCart.items.isEmpty { addHostItem(pair.hostRestaurant.menu[0]) }
        if table.partnerCart.items.isEmpty { simulatePartnerAction() }
    }

    func setHostReady() {
        table.hostReady.toggle()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func setBothReady() {
        seedCarts()
        withAnimation(.bouncy) {
            table.hostReady = true
            table.partnerReady = true
        }
        events.insert(.init(text: "Aisha is ready", symbol: "checkmark.circle.fill", date: .now), at: 0)
    }

    func authorizeAndSubmit() async {
        isSubmitting = true
        do {
            try? await Task.sleep(for: .milliseconds(700))
            table.orders = try await orderService.submit(table: table)
            isSubmitting = false
            go(.tracking)
            startAutomaticDeliverySimulation()
            await startLiveActivityIfPossible()
        } catch {
            errorMessage = "Both carts need an item and both people must be ready."
            isSubmitting = false
        }
    }

    var sharedMilestone: SharedMilestone {
        guard table.orders.count == 2 else { return .linked }
        let minimum = table.orders.map(\.status).min() ?? .authorized
        switch minimum {
        case .awaitingAuthorization, .authorized: return .linked
        case .confirmed: return .confirmed
        case .preparing, .readyForCourier: return .preparing
        case .outForDelivery: return .onTheWay
        case .delivered: return .arrived
        }
    }

    var predictedDifference: Int {
        guard table.orders.count == 2 else { return table.selectedPair?.score.predictedDifference ?? 3 }
        return abs(table.orders[0].estimate.minutes - table.orders[1].estimate.minutes)
    }

    func advanceSimulation() {
        guard table.orders.count == 2 else { return }
        if table.orders[0].status < .delivered {
            table.orders[0].status = IndividualOrderStatus(rawValue: table.orders[0].status.rawValue + 1) ?? .delivered
        } else if table.orders[1].status < .delivered {
            table.orders[1].status = IndividualOrderStatus(rawValue: table.orders[1].status.rawValue + 1) ?? .delivered
        }
        if table.orders[0].status.rawValue > table.orders[1].status.rawValue + 1 {
            table.orders[1].status = IndividualOrderStatus(rawValue: table.orders[1].status.rawValue + 1) ?? .delivered
        }
        updateActivity()
        if table.orders.allSatisfy({ $0.status == .delivered }) { go(.firstBite) }
    }

    func injectDelay() {
        guard table.orders.count == 2 else { return }
        table.orders[1].estimate.minutes += 4
        table.orders[1].estimate.window = "8:10–8:14 PM"
        events.insert(.init(text: "Aisha’s estimate updated honestly", symbol: "clock.badge.exclamationmark", date: .now), at: 0)
        updateActivity()
    }

    func completeDeliveries() {
        guard table.orders.count == 2 else { return }
        table.orders[0].status = .delivered
        table.orders[1].status = .delivered
        updateActivity()
        go(.firstBite)
    }

    func startAutomaticDeliverySimulation() {
        simulationTask?.cancel()
        simulationTask = Task { [weak self] in
            // Seven 15-second beats: about 105 seconds from checkout to arrival.
            for _ in 0..<7 {
                try? await Task.sleep(for: .seconds(15))
                guard !Task.isCancelled else { return }
                self?.advanceSimulation()
            }
            self?.completeDeliveries()
        }
    }

    func beginFirstBite() {
        hostReadyToEat = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(650))
            partnerReadyToEat = true
            for value in stride(from: 3, through: 1, by: -1) {
                countdown = value
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                try? await Task.sleep(for: .seconds(1))
            }
            countdown = 0
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            try? await Task.sleep(for: .seconds(1))
            go(.dining)
        }
    }

    func finishMeal() {
        let hostDish = table.hostCart.items.first?.menuItem.name ?? "Dinner"
        let partnerDish = table.partnerCart.items.first?.menuItem.name ?? "Dinner"
        memory = .init(date: .now, cities: "\(table.host.city) • \(table.partner.city)", dishes: "\(hostDish) + \(partnerDish)", theme: table.selectedPair?.theme ?? "Dinner Together")
        go(.memory)
    }

    func reset() {
        simulationTask?.cancel()
        let services = (catalogue, matcher, orderService)
        let fresh = SyncTableStore(catalogue: services.0, matcher: services.1, orderService: services.2)
        stage = fresh.stage
        path = fresh.path
        table = fresh.table
        partnerJoined = false
        matches = []
        events = []
        hostReadyToEat = false
        partnerReadyToEat = false
        memory = nil
        showDeveloperMenu = false
    }
}
