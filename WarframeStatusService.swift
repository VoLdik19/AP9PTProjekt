import Foundation
import Combine

struct WarframeWorldState: Decodable {
    struct Cycle: Decodable {
        let state: String?
        let isDay: Bool?
        let remainingTime: String?
        let activation: String?
        let expiry: String?
        let shortString: String?
        let active: String?
    }

    struct Trader: Decodable {
        let active: Bool?
        let character: String?
        let location: String?
        let startString: String?
        let endString: String?
    }

    struct Arbitration: Decodable {
        let active: Bool?
        let node: String?
        let enemy: String?
        let type: String?
        let expiry: String?
    }

    struct SortieVariant: Decodable {
        let node: String?
        let missionType: String?
        let modifier: String?
    }

    struct Sortie: Decodable {
        let boss: String?
        let faction: String?
        let eta: String?
        let variants: [SortieVariant]?
    }

    struct Alert: Decodable {
        let mission: Mission?
        let eta: String?

        struct Mission: Decodable {
            let node: String?
            let type: String?
        }
    }

    let cetusCycle: Cycle?
    let vallisCycle: Cycle?
    let cambionCycle: Cycle?
    let voidTrader: Trader?
    let arbitration: Arbitration?
    let sortie: Sortie?
    let alerts: [Alert]?
}

@MainActor
final class WarframeStatusService: ObservableObject {
    @Published var worldState: WarframeWorldState?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?

    private let endpoint = URL(string: "https://api.warframestat.us/pc")!

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var request = URLRequest(url: endpoint)
            request.timeoutInterval = 20
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            worldState = try decoder.decode(WarframeWorldState.self, from: data)
            lastUpdated = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
