import SwiftUI

struct RecordHandView: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    @State private var selectedSession: PokerSession?
    @State private var selectedPosition: Position = .button
    @State private var holeCards: [Card] = []
    @State private var boardCards: [Card] = []
    @State private var heroCards: [Card] = []
    @State private var handActions: [HandAction] = []
    @State private var handResult: HandResult = .fold
    @State private var potSize: Double = 0
    @State private var netResult: Double = 0
    @State private var notes: String = ""
    @State private var showingCardSelector = false
    @State private var cardSelectorType: CardSelectorType = .hole
    @State private var showingHandActions = false
    @State private var showingPositionPicker = false
    
    enum CardSelectorType {
        case hole, board, hero
    }
    
    var allCards: [Card] {
        var cards: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
        return cards
    }
    
    var availableCards: [Card] {
        let usedCards = holeCards + boardCards + heroCards
        return allCards.filter { card in
            !usedCards.contains(card)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Hand Details Header
                    handDetailsHeader
                    
                    // Position Selection
                    positionSection
                    
                    // Board Cards Section
                    boardCardsSection
                    
                    // Hero Cards Section
                    heroCardsSection
                    
                    // Hand Actions Section
                    handActionsSection
                    
                    // Results Section
                    resultsSection
                    
                    // Notes Section
                    notesSection
                    
                    // Save Button
                    saveButton
                }
                .padding()
            }
            .navigationTitle("Record Hand")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Handle cancel
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHand()
                    }
                    .font(.system(size: 17, weight: .semibold))
                }
            }
            .sheet(isPresented: $showingCardSelector) {
                CardSelectorSheet(
                    selectedCards: bindingForCardType(),
                    availableCards: availableCards,
                    maxSelection: maxSelectionForCardType(),
                    title: titleForCardType()
                )
            }
            .sheet(isPresented: $showingHandActions) {
                HandActionsSheet(selectedActions: $handActions)
            }
            .sheet(isPresented: $showingPositionPicker) {
                PositionPickerSheet(selectedPosition: $selectedPosition)
            }
        }
    }
    
    private var handDetailsHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Hand Details")
                    .font(.headline)
                Spacer()
                Text("Poker Keyboard")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Toggle("", isOn: .constant(true))
                    .labelsHidden()
            }
            
            Text("Enter detailed hand description")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var positionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Position")
                .font(.headline)
            
            Button(action: {
                showingPositionPicker = true
            }) {
                HStack {
                    Text(selectedPosition.displayName)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var boardCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Board")
                Spacer()
                Button("Select board cards") {
                    cardSelectorType = .board
                    showingCardSelector = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if boardCards.isEmpty {
                Text("Select board cards")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                HandCardsView(cards: boardCards, size: .medium)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    private var heroCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hero")
                Spacer()
                Button("Select hole cards") {
                    cardSelectorType = .hero
                    showingCardSelector = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if heroCards.isEmpty {
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { _ in
                        CardBackView(size: .medium)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else {
                HandCardsView(cards: heroCards, size: .medium)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    private var handActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hand Actions")
                Spacer()
                Button("What would you like to do with this hand?") {
                    showingHandActions = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if handActions.isEmpty {
                Text("Add actions")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(handActions, id: \.self) { action in
                            Text(action.rawValue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Results")
                .font(.headline)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Pot Size")
                    Spacer()
                    TextField("0", value: $potSize, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Net Result")
                    Spacer()
                    TextField("0", value: $netResult, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                Picker("Result", selection: $handResult) {
                    ForEach(HandResult.allCases, id: \.self) { result in
                        Text(result.rawValue).tag(result)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
            
            TextField("Add a note...", text: $notes)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3)
        }
    }
    
    private var saveButton: some View {
        Button(action: saveHand) {
            HStack {
                Spacer()
                Text("Save Hand")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
    
    private func bindingForCardType() -> Binding<[Card]> {
        switch cardSelectorType {
        case .hole:
            return $holeCards
        case .board:
            return $boardCards
        case .hero:
            return $heroCards
        }
    }
    
    private func maxSelectionForCardType() -> Int {
        switch cardSelectorType {
        case .hole:
            return 2
        case .board:
            return 5
        case .hero:
            return 2
        }
    }
    
    private func titleForCardType() -> String {
        switch cardSelectorType {
        case .hole:
            return "Select Hole Cards"
        case .board:
            return "Select Board Cards"
        case .hero:
            return "Select Hero Cards"
        }
    }
    
    private func saveHand() {
        guard let session = selectedSession else { return }
        
        let newHand = PokerHand(
            sessionId: session.id,
            position: selectedPosition,
            holeCards: heroCards,
            boardCards: boardCards,
            actions: handActions,
            result: handResult,
            potSize: potSize,
            netResult: netResult,
            notes: notes
        )
        
        databaseManager.createHand(newHand)
        
        // Reset form
        resetForm()
    }
    
    private func resetForm() {
        selectedPosition = .button
        holeCards = []
        boardCards = []
        heroCards = []
        handActions = []
        handResult = .fold
        potSize = 0
        netResult = 0
        notes = ""
    }
}

struct CardSelectorSheet: View {
    @Binding var selectedCards: [Card]
    let availableCards: [Card]
    let maxSelection: Int
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            EnhancedCardSelectorView(
                selectedCards: $selectedCards,
                maxSelection: maxSelection,
                availableCards: availableCards,
                title: title
            )
            .navigationTitle(title)
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

struct HandActionsSheet: View {
    @Binding var selectedActions: [HandAction]
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(HandAction.allCases, id: \.self) { action in
                        Button(action: {
                            toggleAction(action)
                        }) {
                            VStack {
                                Image(systemName: iconForAction(action))
                                    .font(.title2)
                                    .foregroundColor(selectedActions.contains(action) ? .white : .blue)
                                
                                Text(action.rawValue)
                                    .font(.caption)
                                    .foregroundColor(selectedActions.contains(action) ? .white : .primary)
                            }
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(selectedActions.contains(action) ? Color.blue : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Hand Actions")
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
    
    private func toggleAction(_ action: HandAction) {
        if let index = selectedActions.firstIndex(of: action) {
            selectedActions.remove(at: index)
        } else {
            selectedActions.append(action)
        }
    }
    
    private func iconForAction(_ action: HandAction) -> String {
        switch action {
        case .fold:
            return "xmark.circle"
        case .call:
            return "phone.circle"
        case .raise:
            return "arrow.up.circle"
        case .check:
            return "checkmark.circle"
        case .bet:
            return "dollarsign.circle"
        case .allIn:
            return "exclamationmark.circle"
        }
    }
}

struct PositionPickerSheet: View {
    @Binding var selectedPosition: Position
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Position.allCases, id: \.self) { position in
                        Button(action: {
                            selectedPosition = position
                            dismiss()
                        }) {
                            VStack {
                                Text(position.displayName)
                                    .font(.headline)
                                    .foregroundColor(selectedPosition == position ? .white : .primary)
                            }
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(selectedPosition == position ? Color.blue : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Select Position")
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
    RecordHandView()
} 