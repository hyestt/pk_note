import SwiftUI

struct AllHandsView: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    @State private var showingFilter = false
    @State private var searchText = ""
    
    var filteredHands: [PokerHand] {
        if searchText.isEmpty {
            return databaseManager.hands
        } else {
            return databaseManager.hands.filter { hand in
                hand.notes.localizedCaseInsensitiveContains(searchText) ||
                hand.position.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if filteredHands.isEmpty {
                    EmptyStateView()
                } else {
                    List(filteredHands) { hand in
                        HandRowView(hand: hand)
                    }
                    .refreshable {
                        // Refresh data from database
                        // DatabaseManager automatically loads data
                    }
                }
            }
            .navigationTitle("All Hands")
            .searchable(text: $searchText, prompt: "Search hands...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Filter") {
                        showingFilter = true
                    }
                }
            }
            .sheet(isPresented: $showingFilter) {
                FilterView()
            }
        }
    }
}

struct HandRowView: View {
    let hand: PokerHand
    
    var body: some View {
        HStack {
            // Position
            Text(hand.position.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
            
            // Hole Cards
            HStack(spacing: 2) {
                ForEach(hand.holeCards) { card in
                    CardView(card: card, size: .small)
                }
            }
            
            Spacer()
            
            // Result
            VStack(alignment: .trailing) {
                Text(hand.result.rawValue)
                    .font(.caption)
                    .foregroundColor(hand.result.color)
                
                Text("$\(hand.netResult, specifier: "%.2f")")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(hand.netResult >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "suit.club.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Hands Recorded")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start a new session to begin recording hands")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Filter Options")
                    .font(.title2)
                    .padding()
                
                // Add filter options here
                
                Spacer()
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AllHandsView()
} 