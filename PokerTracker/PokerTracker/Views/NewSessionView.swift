import SwiftUI

struct NewSessionView: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    @State private var location = "Live Casino"
    @State private var date = Date()
    @State private var blinds = "5/10"
    @State private var currency = "USD"
    @State private var tableSize = 10
    @State private var effectiveStack = 400.0
    @State private var sessionTag = SessionTag.none
    @State private var buyIn = 0.0
    @State private var showingColorPicker = false
    @State private var isCreatingSession = false
    @State private var showingSuccess = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    let locations = ["Live Casino", "Home Game", "Online", "Tournament"]
    let blindsOptions = ["1/2", "2/5", "5/10", "10/20", "25/50"]
    let currencies = ["USD", "EUR", "GBP", "CAD", "AUD"]
    let tableSizes = [6, 8, 9, 10]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Session Details") {
                    // Location
                    Picker("Location", selection: $location) {
                        ForEach(locations, id: \.self) { location in
                            Text(location).tag(location)
                        }
                    }
                    
                    // Date & Time
                    DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    // Blinds
                    Picker("Blinds", selection: $blinds) {
                        ForEach(blindsOptions, id: \.self) { blind in
                            Text(blind).tag(blind)
                        }
                    }
                    
                    // Currency
                    Picker("Currency", selection: $currency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    
                    // Table Size
                    Picker("Table Size", selection: $tableSize) {
                        ForEach(tableSizes, id: \.self) { size in
                            Text("\(size) Players").tag(size)
                        }
                    }
                    
                    // Effective Stack
                    HStack {
                        Text("Effective Stack")
                        Spacer()
                        TextField("400", value: $effectiveStack, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    // Buy In
                    HStack {
                        Text("Buy In")
                        Spacer()
                        TextField("0", value: $buyIn, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Session Tag") {
                    Button(action: {
                        showingColorPicker = true
                    }) {
                        HStack {
                            Text("Select Session Tag Color")
                            Spacer()
                            Circle()
                                .fill(sessionTag.color)
                                .frame(width: 20, height: 20)
                            Text(sessionTag.rawValue)
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                Section {
                    Button(action: startRecordingHands) {
                        HStack {
                            Spacer()
                            if isCreatingSession {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Creating Session...")
                            } else {
                                Text("Start Recording Hands")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isCreatingSession || buyIn <= 0)
                }
            }
            .navigationTitle("New Session")
            .sheet(isPresented: $showingColorPicker) {
                SessionTagColorPicker(selectedTag: $sessionTag)
            }
            .alert("Session Created", isPresented: $showingSuccess) {
                Button("OK") { }
            } message: {
                Text("Your poker session has been created successfully. You can now start recording hands!")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }
    
    private func startRecordingHands() {
        // 驗證輸入
        guard buyIn > 0 else {
            errorMessage = "Buy-in amount must be greater than 0"
            showingError = true
            return
        }
        
        guard effectiveStack > 0 else {
            errorMessage = "Effective stack must be greater than 0"
            showingError = true
            return
        }
        
        isCreatingSession = true
        
                 // 模擬異步操作
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
             let newSession = PokerSession(
                 date: date,
                 location: location,
                 blinds: blinds,
                 currency: currency,
                 tableSize: tableSize,
                 effectiveStack: effectiveStack,
                 sessionTag: sessionTag,
                 buyIn: buyIn,
                 cashOut: 0,
                 isActive: true
             )
             
             databaseManager.createSession(newSession)
             
             isCreatingSession = false
             showingSuccess = true
             
             // Reset form after success
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 resetForm()
             }
         }
    }
    
    private func resetForm() {
        location = "Live Casino"
        date = Date()
        blinds = "5/10"
        currency = "USD"
        tableSize = 10
        effectiveStack = 400.0
        sessionTag = .none
        buyIn = 0.0
    }
}

struct SessionTagColorPicker: View {
    @Binding var selectedTag: SessionTag
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(SessionTag.allCases, id: \.self) { tag in
                        Button(action: {
                            selectedTag = tag
                            dismiss()
                        }) {
                            VStack {
                                Circle()
                                    .fill(tag.color)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedTag == tag ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                
                                Text(tag.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Select Session Tag Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NewSessionView()
} 