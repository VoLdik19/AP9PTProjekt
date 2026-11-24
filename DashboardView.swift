import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var parts: [PrimePart]
    @Query private var items: [MasteredItem]

    private var ownedParts: Int {
        parts.filter(\.isOwned).count
    }

    private var masteredItems: Int {
        items.filter(\.isMastered).count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Warframe Companion")
                        .font(.largeTitle.bold())
                        .padding(.top)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        SummaryCard(
                            title: "Prime Parts",
                            value: "\(ownedParts)",
                            detail: "of \(parts.count) collected",
                            color: .cyan,
                            icon: "hexagon.fill"
                        )
                        SummaryCard(
                            title: "Mastered",
                            value: "\(masteredItems)",
                            detail: "of \(items.count) items",
                            color: .orange,
                            icon: "star.fill"
                        )
                    }

                    if !parts.isEmpty {
                        Text("Recent Prime Progress")
                            .font(.title2.bold())

                        ForEach(Array(parts.prefix(5))) { part in
                            HStack {
                                Image(systemName: part.isOwned ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(part.isOwned ? .green : .secondary)
                                VStack(alignment: .leading) {
                                    Text(part.name)
                                        .font(.headline)
                                    Text(part.setName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(part.quantity)/\(part.needed)")
                                    .monospacedDigit()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String
    let detail: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
