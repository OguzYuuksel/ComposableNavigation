import SwiftUI
import SwiftUINavigation

// MARK: - MusicScreen - State
struct MusicScreenState: Equatable {
    var destination: Destination?
    // TuneIn containers: Music, Sport, News
    // var containers: [String] = .init()

    // Only one of the below destinations can be shown in the screen
    // User should't open information sheet during browsing request.
    // When a container tapped two scenerio may occour
    // - If request success: Go to browser.
    // - If request fails: pop-up alert.
    enum Destination: Equatable {
        case loading
        case information
        case browser(BrowserScreenState)
        case requestAlert(AlertState<String>)
    }
}

// MARK: - MusicScreen - View
struct MusicScreen: View {
    @ObservedObject var store: Store
    var state: Binding<MusicScreenState> { $store.state.musicScreenState }

    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    state.destination.wrappedValue = .information
                } label: {
                    Text("Pop information sheet")
                }

                Button {
                    state.destination.wrappedValue = .loading
                    Task {
                        do {
                            let newContents = try await browse(0)
                            state.destination.wrappedValue = .browser(.init(contents: newContents))
                        } catch {
                            state.destination.wrappedValue = .requestAlert(.init(title: .init("Container Request Error")))
                        }
                    }
                } label: {
                    Text("Container for '0'")
                }
            }
            .loading(unwrapping: state.destination, case: /MusicScreenState.Destination.loading)
            .alert(unwrapping: state.destination, case: /MusicScreenState.Destination.requestAlert) { _ in }
            // FIXME: When deeplinked to the information screen, `.sheet` modifier slips touch point on simulator.
            // Even removing all other modifiers and `NavigationStack` didn't fix it.
            .sheet(unwrapping: state.destination, case: /MusicScreenState.Destination.information) { _ in
                Text("Information Sheet.")
            }
            .navigationTitle("Music Tap")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(unwrapping: state.destination, case: /MusicScreenState.Destination.browser) { $browserState in
                BrowserScreen(state: $browserState) { content in
                    // Handler sets inmost destination to loading
                    browserState.inmost.destination = .loading

                    // Handler fires API request
                    Task {
                        do {
                            let newContents = try await browse(content)
                            // API request successful
                            browserState.inmost.destination = .child(.init(contents: newContents))
                        } catch {
                            // API request failed
                            browserState.inmost.destination = .requestAlert(.init(title: .init("Request Error")))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Helpers
extension MusicScreen {
    // API mock
    private func browse(_ content: Int) async throws -> [Int] {
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC / 2)
        guard randomTrue(percentage: 80) else { throw BrowserError.badResponse }
        return Array(0...content + 1)
    }

    private func randomTrue(percentage: Int) -> Bool {
        guard percentage < 100 else { return true }
        let boolArray = Array(repeating: true, count: percentage) + Array(repeating: false, count: 100 - percentage)
        return boolArray.randomElement() ?? false
    }

    // Error
    private enum BrowserError: Error {
        case badResponse
    }
}
