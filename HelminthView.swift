import SwiftUI
import SwiftData

struct HelminthView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HelminthFrame.name) private var frames: [HelminthFrame]
    @State private var searchText = ""
    @State private var showingAddSheet = false

    private var filteredFrames: [HelminthFrame] {
        searchText.isEmpty
            ? frames
            : frames.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
                    || $0.ability.localizedCaseInsensitiveContains(searchText)
            }
    }

    private var subsumedCount: Int {
        frames.filter(\.isSubsumed).count
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Subsumed Warframes")
                                .font(.headline)
                            Text("\(subsumedCount) of \(frames.count)")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        ProgressView(value: Double(subsumedCount), total: Double(max(frames.count, 1)))
                            .frame(width: 100)
                    }
                }

                ForEach(filteredFrames) { frame in
                    HStack {
                        Button {
                            frame.isSubsumed.toggle()
                        } label: {
                            Image(systemName: frame.isSubsumed ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(frame.isSubsumed ? .green : .secondary)
                                .font(.title3)
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(frame.name)
                                .font(.headline)
                            if !frame.ability.isEmpty {
                                Text(frame.ability)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text(frame.isSubsumed ? "Subsumed" : "Available")
                            .font(.caption)
                            .foregroundStyle(frame.isSubsumed ? .green : .secondary)
                    }
                    .padding(.vertical, 3)
                }
                .onDelete { offsets in
                    for index in offsets {
                        modelContext.delete(filteredFrames[index])
                    }
                }
            }
            .navigationTitle("Helminth")
            .searchable(text: $searchText, prompt: "Search Warframes or abilities")
            .toolbar {
                Button("Add", systemImage: "plus") {
                    showingAddSheet = true
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                HelminthEditor()
            }
        }
    }
}

private struct HelminthEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var ability = ""
    @State private var isSubsumed = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Warframe name", text: $name)
                TextField("Subsumed ability", text: $ability)
                Toggle("Subsumed", isOn: $isSubsumed)
            }
            .navigationTitle("Add Warframe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        modelContext.insert(HelminthFrame(
                            name: name,
                            ability: ability,
                            isSubsumed: isSubsumed
                        ))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
