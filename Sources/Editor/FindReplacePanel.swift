import SwiftUI

struct FindReplacePanel: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Find", text: $viewModel.findOptions.searchText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { viewModel.findNext() }

                TextField("Replace", text: $viewModel.findOptions.replacementText)
                    .textFieldStyle(.roundedBorder)

                Button("Find Next") { viewModel.findNext() }
                Button("Find Previous") { viewModel.findPrevious() }
                Button("Replace") { viewModel.replaceCurrentMatch() }
                Button("Replace All") { viewModel.replaceAllMatches() }

                Button {
                    viewModel.hideFindPanel()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 16) {
                Toggle("Case Sensitive", isOn: $viewModel.findOptions.caseSensitive)
                Toggle("Whole Word", isOn: $viewModel.findOptions.wholeWord)
                Toggle("Regex", isOn: $viewModel.findOptions.usesRegularExpression)
            }
            .font(.caption)

            if let message = viewModel.findStatusMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
    }
}
