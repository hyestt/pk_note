import SwiftUI

struct AnalyticsView: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Overall Stats
                    OverallStatsCard()
                    
                    // Session Stats
                    SessionStatsCard()
                    
                    // Position Stats
                    PositionStatsCard()
                    
                    // Recent Sessions
                    RecentSessionsCard()
                }
                .padding()
            }
            .navigationTitle("Analytics")
        }
    }
}

struct OverallStatsCard: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    
    var totalProfit: Double {
        databaseManager.sessions.reduce(0) { $0 + $1.profit }
    }
    
    var totalHands: Int {
        databaseManager.hands.count
    }
    
    var totalSessions: Int {
        databaseManager.sessions.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overall Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                StatItem(title: "Total Profit", value: String(format: "$%.2f", totalProfit), color: totalProfit >= 0 ? .green : .red)
                StatItem(title: "Total Hands", value: "\(totalHands)", color: .blue)
                StatItem(title: "Sessions", value: "\(totalSessions)", color: .orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct SessionStatsCard: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    
    var avgSessionProfit: Double {
        guard !databaseManager.sessions.isEmpty else { return 0 }
        let totalProfit = databaseManager.sessions.reduce(0) { $0 + $1.profit }
        return totalProfit / Double(databaseManager.sessions.count)
    }
    
    var winRate: Double {
        guard !databaseManager.sessions.isEmpty else { return 0 }
        let winningSessions = databaseManager.sessions.filter { $0.profit > 0 }.count
        return Double(winningSessions) / Double(databaseManager.sessions.count) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                StatItem(title: "Avg Profit", value: String(format: "$%.2f", avgSessionProfit), color: avgSessionProfit >= 0 ? .green : .red)
                StatItem(title: "Win Rate", value: String(format: "%.1f%%", winRate), color: .blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct PositionStatsCard: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Position Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Position.allCases, id: \.self) { position in
                    let handsInPosition = databaseManager.hands.filter { $0.position == position }
                    let profitInPosition = handsInPosition.reduce(0) { $0 + $1.netResult }
                    
                    VStack {
                        Text(position.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Text("\(handsInPosition.count)")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(String(format: "$%.0f", profitInPosition))
                            .font(.caption)
                            .foregroundColor(profitInPosition >= 0 ? .green : .red)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct RecentSessionsCard: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    
    var recentSessions: [PokerSession] {
        Array(databaseManager.sessions.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Sessions")
                .font(.headline)
                .fontWeight(.semibold)
            
            if recentSessions.isEmpty {
                Text("No sessions recorded yet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(recentSessions) { session in
                    HStack {
                        Circle()
                            .fill(session.sessionTag.color)
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.location)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(session.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "$%.2f", session.profit))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(session.profit >= 0 ? .green : .red)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AnalyticsView()
} 