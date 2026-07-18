import ActivityKit
import Foundation

struct SyncTableActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let hostStatus: String
        let partnerStatus: String
        let arrivalWindow: String
        let predictedDifference: Int
        let hostProgress: Double
        let partnerProgress: Double
    }

    let tableID: String
    let hostName: String
    let partnerName: String
}

extension SyncTableStore {
    func startLiveActivityIfPossible() async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled, table.orders.count == 2 else { return }
        let attributes = SyncTableActivityAttributes(tableID: table.id, hostName: table.host.name, partnerName: table.partner.name)
        let state = activityState
        do {
            _ = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: Date().addingTimeInterval(180)), pushType: nil)
            liveActivityStarted = true
        } catch {
            liveActivityStarted = false
        }
    }

    func updateActivity() {
        let state = activityState
        Task {
            for activity in Activity<SyncTableActivityAttributes>.activities {
                await activity.update(.init(state: state, staleDate: Date().addingTimeInterval(180)))
                if table.orders.allSatisfy({ $0.status == .delivered }) {
                    await activity.end(.init(state: state, staleDate: nil), dismissalPolicy: .after(.now.addingTimeInterval(120)))
                }
            }
        }
    }

    private var activityState: SyncTableActivityAttributes.ContentState {
        let first = table.orders.first
        let second = table.orders.dropFirst().first
        return .init(
            hostStatus: first?.status.title ?? "Linked",
            partnerStatus: second?.status.title ?? "Linked",
            arrivalWindow: "Expected within \(predictedDifference) min of each other",
            predictedDifference: predictedDifference,
            hostProgress: Double(first?.status.rawValue ?? 0) / 6,
            partnerProgress: Double(second?.status.rawValue ?? 0) / 6
        )
    }
}
