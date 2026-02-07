import SwiftUI

@main
struct CatnapApp: App {
    @State private var state = AppState()

    var body: some Scene {
        MenuBarExtra {
            RepoListView()
                .environment(state)
        } label: {
            Image(systemName: "cat.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
