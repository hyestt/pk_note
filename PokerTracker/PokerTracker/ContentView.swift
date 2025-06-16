import SwiftUI

struct ContentView: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    @State private var selectedTab = 0
    @State private var showingNewSession = false
    @State private var showingRecordHand = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // All Hands Tab
            NavigationView {
                AllHandsView()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("All Hands")
            }
            .tag(0)
            
            // New Session Tab
            NavigationView {
                NewSessionView()
            }
            .tabItem {
                Image(systemName: "plus.circle")
                Text("New Session")
            }
            .tag(1)
            
            // Record Hand Tab
            NavigationView {
                RecordHandView()
            }
            .tabItem {
                Image(systemName: "suit.club.fill")
                Text("Record Hand")
            }
            .tag(2)
            
            // Analytics Tab
            NavigationView {
                AnalyticsView()
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text("Analytics")
            }
            .tag(3)
            
            // Settings Tab
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(4)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
} 