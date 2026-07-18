import Foundation
import GroupActivities

struct SyncTableActivity: GroupActivity {
    let tableID: String
    var metadata: GroupActivityMetadata {
        var value = GroupActivityMetadata()
        value.title = "Sync Table"
        value.subtitle = "Two locations. Two carts. One shared meal."
        value.type = .generic
        return value
    }
}

enum SyncMessage: Codable {
    case selectedRestaurant(hostID: UUID, partnerID: UUID)
    case presence(String)
    case cartActivity(ownerID: UUID, itemName: String, added: Bool)
    case ready(ownerID: UUID, value: Bool)
    case reaction(ownerID: UUID, emoji: String)
    case firstBite(Date)
}

protocol SyncSessionService: AnyObject {
    var isConnected: Bool { get }
    func send(_ message: SyncMessage) async
}

@MainActor
final class LocalSyncSession: SyncSessionService {
    private(set) var isConnected = true
    var onMessage: ((SyncMessage) -> Void)?
    func send(_ message: SyncMessage) async { onMessage?(message) }
}

@MainActor
final class SharePlaySyncSession: SyncSessionService {
    private var messenger: GroupSessionMessenger?
    private(set) var isConnected = false

    func configure(session: GroupSession<SyncTableActivity>) {
        messenger = GroupSessionMessenger(session: session)
        isConnected = true
        session.join()
    }

    func send(_ message: SyncMessage) async {
        try? await messenger?.send(message)
    }
}
