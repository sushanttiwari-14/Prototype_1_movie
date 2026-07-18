import Foundation
import CoreLocation

enum AppStage: Int, CaseIterable, Codable {
    case home, invite, matching, menu, carts, checkout, tracking, firstBite, dining, memory
}

struct Participant: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let initials: String
    let city: String
    let address: DeliveryAddress
    let isHost: Bool
}

struct DeliveryAddress: Hashable, Codable {
    let label: String
    let line: String
    let city: String
    let latitude: Double
    let longitude: Double
}

struct Restaurant: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let city: String
    let cuisine: String
    let rating: Double
    let priceLevel: Int
    let preparationMinutes: Int
    let deliveryMinutes: Int
    let coordinate: Coordinate
    let menu: [MenuItem]
}

struct Coordinate: Hashable, Codable {
    let latitude: Double
    let longitude: Double
    var clLocation: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
}

struct MenuItem: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let description: String
    let price: Int
    let category: String
    let isVegetarian: Bool
    let spice: Int
    let symbol: String
    let tags: Set<String>
}

struct MenuTwinProfile: Hashable, Codable {
    let canonicalDishType: String
    let cuisine: String
    let mealCategory: String
    let isVegetarian: Bool
    let flavorProfile: [String]
    let spiceCategory: String
    let cookingStyle: String
    let suitableCounterpart: String
}

struct RestaurantPair: Identifiable, Hashable {
    let id = UUID()
    let hostRestaurant: Restaurant
    let partnerRestaurant: Restaurant
    let score: SyncScore
    let theme: String
    var isSameRestaurant: Bool { hostRestaurant.name == partnerRestaurant.name }
}

struct SyncScore: Hashable {
    let total: Int
    let menuSimilarity: Int
    let predictedDifference: Int
    let priceCompatible: Bool
    let prepCompatible: Bool
}

struct CartItem: Identifiable, Hashable, Codable {
    var id: UUID { menuItem.id }
    let menuItem: MenuItem
    var quantity: Int
    var subtotal: Int { menuItem.price * quantity }
}

struct Cart: Identifiable, Hashable, Codable {
    let id: UUID
    let ownerID: UUID
    var items: [CartItem]
    var total: Int { items.reduce(0) { $0 + $1.subtotal } }
    var itemCount: Int { items.reduce(0) { $0 + $1.quantity } }
}

enum IndividualOrderStatus: Int, CaseIterable, Codable, Comparable {
    case awaitingAuthorization, authorized, confirmed, preparing, readyForCourier, outForDelivery, delivered

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
    var title: String {
        switch self {
        case .awaitingAuthorization: "Awaiting payment"
        case .authorized: "Payment authorized"
        case .confirmed: "Confirmed"
        case .preparing: "Preparing"
        case .readyForCourier: "Courier assigned"
        case .outForDelivery: "Out for delivery"
        case .delivered: "Delivered"
        }
    }
    var symbol: String {
        switch self {
        case .awaitingAuthorization: "creditcard"
        case .authorized: "checkmark.shield"
        case .confirmed: "checkmark.seal"
        case .preparing: "flame"
        case .readyForCourier: "figure.wave"
        case .outForDelivery: "scooter"
        case .delivered: "house.and.flag"
        }
    }
}

struct DeliveryEstimate: Hashable, Codable {
    var minutes: Int
    var window: String
}

struct LinkedOrder: Identifiable, Hashable, Codable {
    let id: String
    let ownerID: UUID
    let restaurantName: String
    let address: DeliveryAddress
    let total: Int
    var status: IndividualOrderStatus
    var estimate: DeliveryEstimate
    var paymentAuthorized: Bool
}

enum SharedMilestone: Int, CaseIterable, Codable {
    case linked, confirmed, preparing, onTheWay, arrived

    var title: String {
        switch self {
        case .linked: "Orders linked"
        case .confirmed: "Sync Table confirmed"
        case .preparing: "Both kitchens cooking"
        case .onTheWay: "Both couriers on the way"
        case .arrived: "Your table has arrived"
        }
    }
}

struct PartnerPresenceEvent: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let symbol: String
    let date: Date
}

struct SyncTable: Identifiable {
    let id: String
    let createdAt: Date
    let host: Participant
    let partner: Participant
    var selectedPair: RestaurantPair?
    var hostCart: Cart
    var partnerCart: Cart
    var hostReady: Bool
    var partnerReady: Bool
    var orders: [LinkedOrder]
}

struct SyncMemory: Identifiable {
    let id = UUID()
    let date: Date
    let cities: String
    let dishes: String
    let theme: String
}
