import SwiftUI

struct FooterView: View {
    let counts: (active: Int, inProgress: Int, stale: Int)
    let isLoading: Bool
    let repoCount: Int
    let onSettings: () -> Void
    let onQuit: () -> Void

    var body: some View {
        HStack {
            if isLoading && counts.active == 0 {
                Text("scanning \(repoCount > 0 ? "\(repoCount)" : "") repos\u{2026}")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary)
            } else {
                HStack(spacing: 14) {
                    StatDot(color: Theme.statusActive, count: counts.active)
                    StatDot(color: Theme.statusProgress, count: counts.inProgress)
                    StatDot(color: Theme.statusStale, count: counts.stale)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                FooterButton(icon: "gear", action: onSettings)
                FooterButton(icon: "power", action: onQuit)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

private struct StatDot: View {
    let color: Color
    let count: Int

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 5, height: 5)
            Text("\(count)")
                .font(.system(size: 11))
                .foregroundStyle(Theme.textTertiary)
                .monospacedDigit()
        }
    }
}

private struct FooterButton: View {
    let icon: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(isHovered ? Theme.textSecondary : Theme.textTertiary)
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovered ? Theme.rowHover : .clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
