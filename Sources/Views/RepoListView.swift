import SwiftUI

struct RepoListView: View {
    @Environment(AppState.self) var state
    @State private var showSettings = false
    @State private var refreshTask: Task<Void, Never>?

    private var showSkeleton: Bool {
        state.isLoading && state.repos.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            divider

            if showSkeleton {
                LoadingBar()
            }

            if showSkeleton {
                SkeletonView()
            } else {
                repoList
            }

            divider

            FooterView(
                counts: state.statusCounts,
                isLoading: state.isLoading,
                repoCount: state.repos.count,
                onSettings: { showSettings.toggle() },
                onQuit: { NSApplication.shared.terminate(nil) }
            )
        }
        .frame(width: 340)
        .background(Theme.panel)
        .popover(isPresented: $showSettings) {
            SettingsView(state: state)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
            let optionHeld = NSEvent.modifierFlags.contains(.option)
            state.isExpanded = optionHeld
            refreshTask?.cancel()
            refreshTask = Task {
                await state.refresh()
                if optionHeld {
                    await state.enrichDescriptions()
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Text("\u{1F431}")
                    .font(.system(size: 13))
                Text("Catnap")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)

                if state.isExpanded {
                    Text("expanded")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.textAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Theme.textAccent.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            if state.isLoading && !state.repos.isEmpty {
                Text("scanning\u{2026}")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textAccent)
            } else if !state.repos.isEmpty {
                Text("just now")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    // MARK: - Divider

    private var divider: some View {
        Rectangle()
            .fill(Theme.borderSubtle)
            .frame(height: 1)
            .padding(.horizontal, 20)
    }

    // MARK: - Repo List

    private var repoList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(state.groupedRepos, id: \.category) { group in
                    CategorySection(
                        category: group.category,
                        repos: group.repos,
                        expanded: state.isExpanded,
                        isCollapsed: state.isSectionCollapsed(group.category),
                        onToggle: { state.toggleSection(group.category) }
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .frame(maxHeight: 460)
    }
}

// MARK: - Loading Bar

private struct LoadingBar: View {
    @State private var offset: CGFloat = -0.4

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width * 0.4
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Theme.textAccent, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: 2)
                .offset(x: offset * geo.size.width)
        }
        .frame(height: 2)
        .padding(.horizontal, 20)
        .clipped()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                offset = 1.4
            }
        }
    }
}

// MARK: - Skeleton Loading

private struct SkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SkeletonSection(headerWidth: 100, rowWidths: [120, 150, 90])
            SkeletonSection(headerWidth: 80, rowWidths: [110, 80, 130])
            SkeletonSection(headerWidth: 70, rowWidths: [140, 95])
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxHeight: 460)
    }
}

private struct SkeletonSection: View {
    let headerWidth: CGFloat
    let rowWidths: [CGFloat]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Theme.section)
                .frame(width: headerWidth, height: 12)

            ForEach(Array(rowWidths.enumerated()), id: \.offset) { index, width in
                SkeletonRow(nameWidth: width)
                    .modifier(ShimmerModifier(delay: Double(index) * 0.1))
            }
        }
    }
}

private struct SkeletonRow: View {
    let nameWidth: CGFloat

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Theme.section)
                .frame(width: 6, height: 6)
            RoundedRectangle(cornerRadius: 4)
                .fill(Theme.section)
                .frame(width: nameWidth, height: 12)
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(Theme.section)
                .frame(width: 28, height: 10)
        }
        .padding(.leading, 16)
    }
}

private struct ShimmerModifier: ViewModifier {
    let delay: Double
    @State private var opacity: Double = 0.4

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.8)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    opacity = 0.8
                }
            }
    }
}
