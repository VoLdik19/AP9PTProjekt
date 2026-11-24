import SwiftUI
import SwiftData

struct PrimePartsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PrimePart.setName) private var parts: [PrimePart]
    @State private var searchText = ""
    @State private var showingAddSheet = false

    private var filteredParts: [PrimePart] {
        if searchText.isEmpty {
            return parts
        }
        return parts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.setName.localizedCaseInsensitiveContains(searchText)
                || $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredParts) { part in
                    PrimePartRow(part: part)
                }
                .onDelete(perform: deleteParts)
            }
            .navigationTitle("Prime Parts")
            .searchable(text: $searchText, prompt: "Search parts")
            .toolbar {
                Button("Add", systemImage: "plus") {
                    showingAddSheet = true
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                PrimePartEditor(part: nil)
            }
        }
    }

    private func deleteParts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredParts[index])
        }
    }
}

private struct PrimePartRow: View {
    @Bindable var part: PrimePart

    var body: some View {
        HStack {
            Button {
                part.isOwned.toggle()
                if part.isOwned {
                    part.quantity = max(part.quantity, 1)
                }
            } label: {
                Image(systemName: part.isOwned ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(part.isOwned ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(part.name)
                    .font(.headline)
                Text("\(part.category) - \(part.setName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Stepper(
                value: Binding(
                    get: { part.quantity },
                    set: {
                        part.quantity = max(0, $0)
                        part.isOwned = part.quantity > 0
                    }
                ),
                in: 0...99
            ) {
                Text("\(part.quantity)/\(part.needed)")
                    .monospacedDigit()
                    .frame(width: 56)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PrimePartEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let part: PrimePart?

    @State private var name = ""
    @State private var setName = ""
    @State private var category = "Blueprint"
    @State private var quantity = 0
    @State private var needed = 1

    private let categories = ["Blueprint", "Neuroptics", "Chassis", "Systems", "Barrel", "Receiver", "Stock", "Link"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Part name", text: $name)
                TextField("Set name", text: $setName)
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0) }
                }
                Stepper("Owned: \(quantity)", value: $quantity, in: 0...99)
                Stepper("Needed: \(needed)", value: $needed, in: 1...99)
            }
            .navigationTitle(part == nil ? "Add Prime Part" : "Edit Prime Part")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let part {
                    name = part.name
                    setName = part.setName
                    category = part.category
                    quantity = part.quantity
                    needed = part.needed
                }
            }
        }
    }

    private func save() {
        let isOwned = quantity > 0
        if let part {
            part.name = name
            part.setName = setName
            part.category = category
            part.quantity = quantity
            part.needed = needed
            part.isOwned = isOwned
        } else {
            modelContext.insert(PrimePart(
                name: name,
                setName: setName,
                category: category,
                quantity: quantity,
                needed: needed,
                isOwned: isOwned
            ))
        }
    }
}
