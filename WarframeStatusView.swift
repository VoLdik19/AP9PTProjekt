import SwiftUI

struct WarframeStatusView: View {
    @StateObject private var status = WarframeStatusService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if status.isLoading && status.worldState == nil {
                        ProgressView("Loading world state...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }

                    if let message = status.errorMessage {
                        Label(message, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if let state = status.worldState {
                        statusGrid(state)

                        if let sortie = state.sortie {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sortie")
                                    .font(.title2.bold())
                                Text("\(sortie.boss ?? "Unknown boss") - \(sortie.faction ?? "")")
                                if let eta = sortie.eta {
                                    Text(eta).foregroundStyle(.secondary)
                                }
                                ForEach(Array((sortie.variants ?? []).enumerated()), id: \.offset) { _, variant in
                                    Text("\(variant.node ?? \"Unknown\"): \(variant.missionType ?? \"\") - \(variant.modifier ?? \"\")")
                                        .font(.caption)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        if let alerts = state.alerts, !alerts.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Alerts")
                                    .font(.title2.bold())
                                ForEach(Array(alerts.prefix(5).enumerated()), id: \.offset) { _, alert in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(alert.mission?.node ?? "Unknown node")
                                                .font(.headline)
                                            Text(alert.mission?.type ?? "")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(alert.eta ?? "")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Live Status")
            .toolbar {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    Task { await status.refresh() }
                }
                .disabled(status.isLoading)
            }
            .task {
                await status.refresh()
            }
        }
    }

    @ViewBuilder
    private func statusGrid(_ state: WarframeWorldState) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            if let cycle = state.cetusCycle {
                StatusCard(
                    title: "Cetus",
                    value: cycle.isDay == true ? "Day" : (cycle.state ?? "Unknown"),
                    detail: cycle.shortString ?? cycle.remainingTime ?? "",
                    color: .yellow
                )
            }
            if let cycle = state.vallisCycle {
                StatusCard(
                    title: "Orb Vallis",
                    value: cycle.state?.capitalized ?? "Unknown",
                    detail: cycle.shortString ?? cycle.remainingTime ?? "",
                    color: .cyan
                )
            }
            if let cycle = state.cambionCycle {
                StatusCard(
                    title: "Cambion Drift",
                    value: cycle.active ?? cycle.state?.capitalized ?? "Unknown",
                    detail: cycle.shortString ?? cycle.remainingTime ?? "",
                    color: .purple
                )
            }
            if let trader = state.voidTrader {
                StatusCard(
                    title: "Baro Ki'Teer",
                    value: trader.active == true ? "On arrival" : "Away",
                    detail: trader.active == true ? (trader.location ?? "") : (trader.startString ?? trader.endString ?? ""),
                    color: .orange
                )
            }
            if let arbitration = state.arbitration {
                StatusCard(
                    title: "Arbitration",
                    value: arbitration.active == true ? "Active" : "Inactive",
                    detail: arbitration.node ?? arbitration.type ?? "",
                    color: .red
                )
            }
        }
    }
}

private struct StatusCard: View {
    let title: String
    let value: String
    let detail: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
