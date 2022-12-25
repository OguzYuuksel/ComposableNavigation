import SwiftUI
import SwiftUINavigation

// MARK: - State
struct RootState: Equatable {
    // Screen keeps all taps alive but only shows one.
    // Therefore, we need to keep all states, but also
    // show only one tab on screen.
    var selectedTap: Tab = .musicTab
    var musicScreenState: MusicScreenState = .init()
    var soundScreenState: SoundScreenState = .init()
    var settingsScreenState: SettingsScreenState = .init()

    // Below alerts may show-up in the same time
    // since they are errors from different endpoints.
    // They can be occour in the same time, we wouldn't like to lose the information
    // TODO: [Bad Idea!] alerts might be converted into array?
    // -- Since AlertState is generic, the type will change according
    //    to the alerts, [AlertState<????>] won't be a generic solution.
    var aMonitoringAlert: AlertState<String>?
    var bMonitoringAlert: AlertState<String>?
    var cMonitoringAlert: AlertState<String>?

    enum Tab {
        case musicTab
        case soundTab
        case settingsTab
    }
}

// MARK: - Screen
struct RootScreen: View {
    @StateObject var store: Store

    var body: some View {
        TabView(selection: $store.state.selectedTap) {
            MusicScreen(store: store)
                .tabItem { Text("Music") }
                .tag(RootState.Tab.musicTab)

            SoundScreen()
                .tabItem { Text("Sound") }
                .tag(RootState.Tab.soundTab)

            SettingsScreen()
                .tabItem { Text("Settings") }
                .tag(RootState.Tab.settingsTab)
        }
        .alert(unwrapping: $store.state.aMonitoringAlert) { _ in }
        .alert(unwrapping: $store.state.bMonitoringAlert) { _ in }
        .alert(unwrapping: $store.state.cMonitoringAlert) { _ in }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootScreen(store: .init())
    }
}
