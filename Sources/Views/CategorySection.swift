import SwiftUI

struct CategorySection: View {
    let category: String
    let repos: [RepoInfo]
    let expanded: Bool
    let isCollapsed: Bool
    let onToggle: () -> Void
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header — custom, not DisclosureGroup
            Button(action: onToggle) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Theme.textTertiary)
                        .rotationEffect(.degrees(isCollapsed ? 0 : 90))
                        .animation(.easeInOut(duration: 0.2), value: isCollapsed)
                        .frame(width: 12)

                    Text(category)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)

                    Spacer()

                    Text("\(repos.count)")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.textTertiary)
                        .monospacedDigit()
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovered ? Theme.rowHover : .clear)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { isHovered = $0 }

            // Repo rows
            if !isCollapsed {
                ForEach(repos) { repo in
                    RepoRowView(repo: repo, expanded: expanded)
                }
            }
        }
    }
}
