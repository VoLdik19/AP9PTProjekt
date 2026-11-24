import SwiftUI
import SwiftData

@main
struct WarframeCompanionApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: PrimePart.self, MasteredItem.self, HelminthFrame.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
            SeedData.insertIfNeeded(in: container.mainContext)
        } catch {
            fatalError("Unable to create the data store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
