import SwiftUI

struct EditorOverlayContainer<Content: View>: View {
    let title: String
    let onDismiss: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 0) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Close (Esc)")
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                content()
            }
            .frame(maxWidth: 460, maxHeight: 560)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.2), radius: 24, y: 8)
        }
        .onExitCommand(perform: onDismiss)
    }
}
