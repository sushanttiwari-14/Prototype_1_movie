import SwiftUI

struct QuantityControl: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let itemName: String
    let quantity: Int
    let add: () -> Void
    let remove: () -> Void

    var body: some View {
        Group {
            if quantity > 0 {
                HStack(spacing: 10) {
                    Button("Remove \(itemName)", systemImage: "minus", action: remove)
                        .labelStyle(.iconOnly)
                    Text(quantity, format: .number)
                        .font(.subheadline.bold().monospacedDigit())
                        .contentTransition(reduceMotion ? .identity : .numericText())
                    Button("Add \(itemName)", systemImage: "plus", action: add)
                        .labelStyle(.iconOnly)
                }
                .foregroundStyle(SyncFlowPalette.rose)
                .padding(.horizontal, 10)
                .frame(minHeight: SyncButtonMetrics.minimumHitTarget)
                .background(SyncFlowPalette.blush.opacity(0.85), in: Capsule())
            } else {
                Button("Add \(itemName)", systemImage: "plus", action: add)
                    .labelStyle(.iconOnly)
                    .font(.headline)
                    .foregroundStyle(SyncFlowPalette.rose)
                    .frame(width: SyncButtonMetrics.minimumHitTarget, height: SyncButtonMetrics.minimumHitTarget)
                    .background(SyncFlowPalette.blush.opacity(0.9), in: Circle())
            }
        }
        .syncMotion(SyncMotion.controlChange, value: quantity)
    }
}
