import SwiftUI

struct RepoRowView: View {
    let repo: RepoInfo
    let expanded: Bool
    @State private var isHovered = false

    var body: some View {
        Link(destination: repo.githubURL ?? URL(string: "https://github.com")!) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(repo.status.color)
                        .frame(width: 6, height: 6)

                    Text(repo.name)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)

                    if repo.isDirty {
                        Circle()
                            .fill(Theme.dirty)
                            .frame(width: 5, height: 5)
                    }

                    Spacer()

                    Text(repo.relativeTime)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textTertiary)
                        .monospacedDigit()
                }

                if expanded, let desc = repo.description, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textTertiary)
                        .lineLimit(1)
                        .padding(.leading, 14)
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 8)
            .padding(.leading, 16)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Theme.rowHover : .clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
