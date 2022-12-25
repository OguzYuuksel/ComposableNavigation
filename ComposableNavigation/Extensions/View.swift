import SwiftUI
import SwiftUINavigation

// MARK: - NavigationLink
extension View {
    @available(iOS, introduced: 13, deprecated: 16)
    @available(macOS, introduced: 10.15, deprecated: 13)
    @available(tvOS, introduced: 13, deprecated: 16)
    @available(watchOS, introduced: 6, deprecated: 9)
    public func navigationLink<Value, WrappedDestination: View>(
        unwrapping value: Binding<Value?>,
        onNavigate: @escaping (_ isActive: Bool) -> Void = { _ in },
        @ViewBuilder destination: @escaping (Binding<Value>) -> WrappedDestination
    ) -> some View {
        self.modifier(
            _NavigationLink(
                unwrapping: value,
                onNavigate: onNavigate,
                destination: destination
            )
        )
    }

    @available(iOS, introduced: 13, deprecated: 16)
    @available(macOS, introduced: 10.15, deprecated: 13)
    @available(tvOS, introduced: 13, deprecated: 16)
    @available(watchOS, introduced: 6, deprecated: 9)
    public func navigationLink<Enum, Case, WrappedDestination: View>(
        unwrapping enum: Binding<Enum?>,
        case casePath: CasePath<Enum, Case>,
        onNavigate: @escaping (Bool) -> Void = { _ in },
        @ViewBuilder destination: @escaping (Binding<Case>) -> WrappedDestination
    ) -> some View {
        self.navigationLink(
            unwrapping: `enum`.case(casePath),
            onNavigate: onNavigate,
            destination: destination
        )
    }
}

// MARK: View Modifier
fileprivate struct _NavigationLink<Value, WrappedDestination: View>: ViewModifier {
    private let value: Binding<Value?>
    private let onNavigate: (_ isActive: Bool) -> Void
    private let destination: (Binding<Value>) -> WrappedDestination

    init(unwrapping value: Binding<Value?>,
                onNavigate: @escaping (_ isActive: Bool) -> Void,
                @ViewBuilder destination: @escaping (Binding<Value>) -> WrappedDestination) {
        self.value = value
        self.onNavigate = onNavigate
        self.destination = destination
    }

    func body(content: Content) -> some View {
            content
                .background {
                    NavigationLink(unwrapping: value,
                                   onNavigate: onNavigate,
                                   destination: destination,
                                   label: {})
                    .isDetailLink(false)
                    .buttonStyle(PlainButtonStyle())
                    .hidden()
                    .accessibilityHidden(true)
                }
    }
}

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
