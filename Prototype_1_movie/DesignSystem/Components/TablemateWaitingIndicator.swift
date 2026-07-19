import SwiftUI

/// A warm, ambient waiting cue for the invite flow rather than a utilitarian spinner.
struct TablemateWaitingIndicator: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isGathering = false

    var body: some View {
        ZStack {
            Circle()
                .fill(SyncFlowPalette.rose.opacity(0.11))
                .frame(width: 58, height: 58)

            Circle()
                .fill(.white.opacity(0.72))
                .frame(width: 42, height: 42)
                .shadow(color: SyncFlowPalette.rose.opacity(0.12), radius: 8, y: 3)

            Image(systemName: "heart.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(SyncFlowPalette.rose)
                .scaleEffect(isGathering ? 1.08 : 0.92)

            sparkle("sparkle", size: 12, x: -23, y: -18, delay: 0)
            sparkle("circle.fill", size: 6, x: 25, y: -8, delay: 0.3)
            sparkle("sparkle", size: 9, x: 19, y: 22, delay: 0.6)
        }
        .frame(width: 64, height: 64)
        .accessibilityLabel("Waiting for your tablemate")
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
                isGathering = true
            }
        }
        .onChange(of: reduceMotion) { _, isReduced in
            if isReduced {
                isGathering = false
            } else {
                withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
                    isGathering = true
                }
            }
        }
    }

    private func sparkle(_ name: String, size: CGFloat, x: CGFloat, y: CGFloat, delay: Double) -> some View {
        Image(systemName: name)
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(SyncFlowPalette.rose.opacity(name == "circle.fill" ? 0.55 : 0.88))
            .offset(
                x: isGathering ? x * 0.8 : x,
                y: isGathering ? y * 0.8 : y
            )
            .opacity(isGathering ? 0.58 : 1)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 1.15).repeatForever(autoreverses: true).delay(delay),
                value: isGathering
            )
    }
}
