import SwiftUI
import SwiftUINavigation

// MARK: - BrowserScreen - State
struct BrowserScreenState: Equatable {
    // Only one of `Destination?` can be shown in the screen
    // - Destination? == .none: Browser contents are shown on screen.
    // - Destination? == .loading: ProgressView overlays the screen.
    // - Destination? == .requestAlert: browse api fails and alert pops-up.
    // - Destination? == .child: screen navigates to new content.

    // Content will be a generic that conforms BrowserContent protocol.
    // When user tap a content on the view, the content will be passed
    // to the reducer via an associated value action case.
    // reducer will resolve if the content is browsable or playable.
    // Then, reducer will execute related action.
    typealias Content = Int
    var destination: Destination?
    var contents: [Content]
    /// - Returns:Deepest `BrowserScreenState`.
    var inmost: Self {
        get {
            switch destination {
            case let .child(state):
                return state.inmost
            default:
                return self
            }
        }
        set {
            switch destination {
            case var .child(state):
                state.inmost = newValue
                self.destination = .child(state)
            default:
                self = newValue
            }
        }
    }

    enum Destination: Equatable {
        case loading
        case requestAlert(AlertState<String>)
        indirect case child(BrowserScreenState)
    }
}

// MARK: - BrowserScreen - View
struct BrowserScreen: View {
    @Binding var state: BrowserScreenState
    let onTap: (Int) -> ()

    var body: some View {
            ScrollView {
                ForEach(state.contents, id: \.self) { content in
                    Button {
                        onTap(content)
                    } label: {
                        Text(content.description)
                    }
                }
            }
            .loading(unwrapping: $state.destination, case: /BrowserScreenState.Destination.loading)
            .alert(unwrapping: $state.destination, case: /BrowserScreenState.Destination.requestAlert) { _ in }
            .navigationTitle(title)
            .navigationLink(unwrapping: $state.destination, case: /BrowserScreenState.Destination.child) { $browserState in
                BrowserScreen(state: $browserState) { int in
                    onTap(int)
                }
            }
    }

    // Helpers
    private var title: String { "Sum: " + state.contents.reduce(0, +).description }
}
