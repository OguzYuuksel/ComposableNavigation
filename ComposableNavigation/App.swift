import SwiftUI
import SwiftUINavigation

// MARK: - Store
class Store: ObservableObject {
    @Published var state: RootState = .init()
}

extension Store {
    func deeplink(_ destination: Destination) {
        switch destination {
        case let .musicScreen(destination):
            state.selectedTap = .musicTab
            state.musicScreenState.destination = destination
        case .soundScreen:
            state.selectedTap = .soundTab
        case .settingsScreen:
            state.selectedTap = .settingsTab
        }
    }

    enum Destination: Equatable {
        case musicScreen(MusicScreenState.Destination?)
        case soundScreen
        case settingsScreen
    }
}

// MARK: - View
@main
struct ComposableNavigationApp: App {
    let store: Store = {
        let store = Store()
        // MARK: Deeplinks
        // store.deeplink(.musicScreen(.information)) // FIXME: Buggy
        // store.deeplink(.musicScreen(nil))
        // store.deeplink(.musicScreen(.loading))
        // store.deeplink(.musicScreen(.requestAlert(.init(title: .init("DeepLinkAlert")))))
        // store.deeplink(.musicScreen(.browser(.init(contents: [0, 1, 2]))))
        //
        // store.deeplink(
        //     .musicScreen(
        //        .browser(
        //            .init(
        //                destination: .child(
        //                    .init(
        //                        destination: .child(
        //                            .init(
        //                                destination: .child(.init(contents: [0, 9, 2])),
        //                                  contents: [1]
        //                            )
        //                        ),
        //                          contents: [5, 6]
        //                    )
        //                ),
        //                contents: [0, 1, 2]
        //            )
        //         )
        //     )
        // )
        //
        // store.deeplink(.settingsScreen)
        // store.deeplink(.soundScreen)
        return store
    }()

    var body: some Scene {
        WindowGroup {
            RootScreen(store: store)
        }
    }
}
