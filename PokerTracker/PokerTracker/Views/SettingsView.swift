import SwiftUI

struct SettingsView: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section("Premium") {
                    NavigationLink(destination: PremiumView()) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("Upgrade to Premium")
                        }
                    }
                }
                
                Section("Data") {
                    Button("Export Data") {
                        // Export functionality
                    }
                    
                    Button("Import Data") {
                        // Import functionality
                    }
                    
                    Button("Backup to iCloud") {
                        // iCloud backup
                    }
                }
                
                Section("Preferences") {
                    NavigationLink(destination: Text("Currency Settings")) {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                            Text("Default Currency")
                        }
                    }
                    
                    NavigationLink(destination: Text("Notification Settings")) {
                        HStack {
                            Image(systemName: "bell")
                            Text("Notifications")
                        }
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink(destination: Text("Privacy Policy")) {
                        Text("Privacy Policy")
                    }
                    
                    NavigationLink(destination: Text("Terms of Service")) {
                        Text("Terms of Service")
                    }
                }
                
                // 開發測試區段
                Section("開發測試") {
                    Button("測試數據庫功能") {
                        testDatabaseFunctionality()
                    }
                    .foregroundColor(.blue)
                    
                    Button("測試UI組件") {
                        testUIComponents()
                    }
                    .foregroundColor(.green)
                    
                    Button("創建測試數據") {
                        createTestData()
                    }
                    .foregroundColor(.orange)
                    
                    Button("清除所有數據") {
                        clearAllData()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    // MARK: - 測試功能
    private func testDatabaseFunctionality() {
        print("🔧 開始測試數據庫功能...")
        
        // 測試Session創建
        let testSession = PokerSession(
            date: Date(),
            location: "測試賭場",
            blinds: "5/10",
            currency: "USD",
            tableSize: 9,
            effectiveStack: 500,
            sessionTag: .blue,
            buyIn: 500,
            cashOut: 750,
            isActive: false
        )
        
        databaseManager.createSession(testSession)
        print("✅ Session創建測試完成 - 收益: $\(testSession.profit)")
        
        // 測試數據檢索
        let sessions = databaseManager.sessions
        let hands = databaseManager.hands
        print("✅ 數據檢索測試完成 - Sessions: \(sessions.count), Hands: \(hands.count)")
    }
    
    private func testUIComponents() {
        print("🎨 開始測試UI組件...")
        
        // 測試Card模型
        let testCard = Card(rank: .ace, suit: .spades)
        print("✅ Card模型測試 - \(testCard.displayString)")
        
        // 測試Position枚舉
        let positions = Position.allCases
        print("✅ Position枚舉測試 - \(positions.count)個位置")
        
        // 測試SessionTag顏色
        let tagColors = SessionTag.allCases.map { $0.color }
        print("✅ SessionTag測試 - \(tagColors.count)種顏色")
    }
    
    private func createTestData() {
        print("📝 開始創建測試數據...")
        
        // 創建測試Session
        let testSession = PokerSession(
            date: Date(),
            location: "Live Casino",
            blinds: "5/10",
            currency: "USD",
            tableSize: 9,
            effectiveStack: 400,
            sessionTag: .green,
            buyIn: 400,
            cashOut: 550,
            isActive: false
        )
        
        databaseManager.createSession(testSession)
        
        // 創建測試Hand
        let testHand = PokerHand(
            sessionId: testSession.id,
            position: .button,
            holeCards: [
                Card(rank: .ace, suit: .spades),
                Card(rank: .king, suit: .hearts)
            ],
            boardCards: [
                Card(rank: .ace, suit: .clubs),
                Card(rank: .king, suit: .diamonds),
                Card(rank: .queen, suit: .spades)
            ],
            actions: [.raise, .call],
            result: .win,
            potSize: 150,
            netResult: 75,
            notes: "測試手牌 - AK suited"
        )
        
        databaseManager.createHand(testHand)
        print("✅ 測試數據創建完成")
    }
    
    private func clearAllData() {
        print("🗑️ 清除所有數據...")
        // 這裡可以添加清除數據的邏輯
        print("✅ 數據清除完成")
    }
}

struct PremiumView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                    
                    Text("Poker Tracker Premium")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Unlock advanced features and take your poker game to the next level")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Features
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(icon: "infinity", title: "Unlimited session recording", description: "Record as many sessions as you want")
                    FeatureRow(icon: "chart.bar.fill", title: "AI-powered analysis", description: "Get insights into your playing patterns")
                    FeatureRow(icon: "square.and.arrow.up", title: "Data export", description: "Export your data in multiple formats")
                    FeatureRow(icon: "icloud.fill", title: "Cloud synchronization", description: "Sync your data across all devices")
                    FeatureRow(icon: "tag.fill", title: "Custom tags and notes", description: "Organize your sessions with custom tags")
                    FeatureRow(icon: "headphones", title: "Priority support", description: "Get help when you need it most")
                }
                .padding()
                
                // Pricing
                VStack(spacing: 20) {
                    Text("Choose Your Plan")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 16) {
                        PricingCard(
                            title: "Monthly Premium",
                            price: "$9.99",
                            period: "per month",
                            features: ["All premium features", "Cancel anytime"],
                            isPopular: true
                        )
                    }
                }
                .padding()
                
                // CTA Button
                Button(action: {
                    // Handle subscription
                }) {
                    Text("Start Free Trial")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding()
                
                Text("7-day free trial, then $9.99/month. Cancel anytime.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PricingCard: View {
    let title: String
    let price: String
    let period: String
    let features: [String]
    let isPopular: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            if isPopular {
                Text("Most Popular")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text(price)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(period)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(features, id: \.self) { feature in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(feature)
                            .font(.subheadline)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isPopular ? Color.blue : Color(.systemGray4), lineWidth: isPopular ? 2 : 1)
        )
    }
}

#Preview {
    SettingsView()
} 