import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Overview", systemImage: "square.grid.2x2")
                }

            WarframeStatusView()
                .tabItem {
                    Label("Live Status", systemImage: "antenna.radiowaves.left.and.right")
                }

            PrimePartsView()
                .tabItem {
                    Label("Prime Parts", systemImage: "hexagon")
                }

            MasteredItemsView()
                .tabItem {
                    Label("Mastery", systemImage: "star")
                }

            HelminthView()
                .tabItem {
                    Label("Helminth", systemImage: "cross.case")
                }
        }
    }
}
