import SwiftUI
import CasePaths

// MARK: - Loading
extension View {
    func loading(_ isActive: Binding<Bool>) -> some View {
        self.modifier(_Loading(isActive))
    }

    @ViewBuilder
    func loading(_ isActive: Binding<Bool?>) -> some View {
        if let binding = Binding(unwrapping: isActive) {
            self.loading(binding)
        }
    }

    func loading<Enum>(unwrapping enum: Binding<Enum?>, case casePath: CasePath<Enum, Bool>) -> some View {
        self.loading(`enum`.case(casePath))
    }

    func loading<Enum>(unwrapping enum: Binding<Enum?>, case casePath: CasePath<Enum, Void>) -> some View {
        self.loading(`enum`.isPresent(casePath))
    }
}

// MARK: View Modifier
fileprivate struct _Loading: ViewModifier {
    private let isActive: Binding<Bool>

    init(_ isActive: Binding<Bool>) {
        self.isActive = isActive
    }

    func body(content: Content) -> some View {
        ZStack {
            if isActive.wrappedValue { ProgressView() }
            content
        }
        .disabled(isActive.wrappedValue)
        .navigationBarBackButtonHidden(isActive.wrappedValue)
    }
}
