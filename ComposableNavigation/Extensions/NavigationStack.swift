import SwiftUI

struct NavigationStack<Content: View>: View {
    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        if #available(iOS 16, *) {
            SwiftUI.NavigationStack {
                content()
            }
        } else {
            // FIXME: If you deeplink more than two level, navigation will stay at the second level.
            // This is a known `NavigationLink` bug.
            NavigationView {
                content()
            }
            .navigationViewStyle(.stack)
        }
    }
}
