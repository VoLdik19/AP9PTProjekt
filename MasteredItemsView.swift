import SwiftUI
import SwiftData

struct MasteredItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\MasteredItem.category), SortDescriptor(\MasteredItem.name)]) private var items: [MasteredItem]
    @State private var searchText = ""
    @State private var showingAddSheet = false

    private var filteredItems: [MasteredItem] {
        searchText.isEmpty
            ? items
            : items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
                    || $0.category.localizedCaseInsensitiveContains(searchText)
            }
    }

    private var groupedItems: [(String, [MasteredItem])] {
        Dictionary(grouping: filteredItems, by: \.category)
            .sorted { $0.key < $1.key }
            .map { ($0.key, $0.value.sorted { $0.name < $1.name }) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedItems, id: \.0) { category, categoryItems in
                    Section(category) {
                        ForEach(categoryItems) { item in
                            MasteredItemRow(item: item)
                        }
                        .onDelete { offsets in
                            deleteItems(categoryItems: categoryItems, offsets: offsets)
                        }
                    }
                }
            }
            .navigationTitle("Mastery")
            .searchable(text: $searchText, prompt: "Search items")
            .toolbar {
                Button("Add", systemImage: "plus") {
                    showingAddSheet = true
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                MasteredItemEditor()
            }
        }
    }

    private func deleteItems(categoryItems: [MasteredItem], offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(categoryItems[index])
        }
    }
}

private struct MasteredItemRow: View {
    @Bindable var item: MasteredItem

    var body: some View {
        HStack {
            Button {
                item.isMastered.toggle()
                item.rank = item.isMastered ? 30 : 0
            } label: {
                Image(systemName: item.isMastered ? "star.circle.fill" : "circle")
                    .foregroundStyle(item.isMastered ? .yellow : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text(item.notes.isEmpty ? item.category : "\(item.category) - \(item.notes)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Stepper(
                value: Binding(
                    get: { item.rank },
                    set: {
                        item.rank = max(0, min(30, $0))
                        item.isMastered = item.rank == 30
                    }
                ),
                in: 0...30
            ) {
                Text("R\(item.rank)")
                    .monospacedDigit()
                    .frame(width: 44)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MasteredItemEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category = "Warframes"
    @State private var rank = 0
    @State private var notes = ""

    private let categories = ["Warframes", "Primary", "Secondary", "Melee", "Archwing", "Companion", "Necramech"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Item name", text: $name)
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0) }
                }
                Stepper("Rank: \(rank)", value: $rank, in: 0...30)
                TextField("Notes", text: $notes)
            }
            .navigationTitle("Add Mastered Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        modelContext.insert(MasteredItem(
                            name: name,
                            category: category,
                            isMastered: rank == 30,
                            rank: rank,
                            notes: notes
                        ))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
