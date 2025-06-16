import SwiftUI

enum CardSize {
    case small, medium, large
    
    var dimensions: CGSize {
        switch self {
        case .small:
            return CGSize(width: 25, height: 35)
        case .medium:
            return CGSize(width: 40, height: 56)
        case .large:
            return CGSize(width: 60, height: 84)
        }
    }
    
    var fontSize: Font {
        switch self {
        case .small:
            return .caption2
        case .medium:
            return .caption
        case .large:
            return .body
        }
    }
}

struct CardView: View {
    let card: Card
    let size: CardSize
    let isSelected: Bool
    
    init(card: Card, size: CardSize = .medium, isSelected: Bool = false) {
        self.card = card
        self.size = size
        self.isSelected = isSelected
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )
                .shadow(radius: 2)
            
            VStack(spacing: 2) {
                Text(card.rank.rawValue)
                    .font(size.fontSize)
                    .fontWeight(.bold)
                    .foregroundColor(card.suit.color)
                
                Text(card.suit.rawValue)
                    .font(size.fontSize)
                    .foregroundColor(card.suit.color)
            }
        }
        .frame(width: size.dimensions.width, height: size.dimensions.height)
    }
}

struct CardBackView: View {
    let size: CardSize
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.blue)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.blue.opacity(0.7), lineWidth: 1)
                )
                .shadow(radius: 2)
            
            Image(systemName: "suit.club.fill")
                .font(size.fontSize)
                .foregroundColor(.white)
        }
        .frame(width: size.dimensions.width, height: size.dimensions.height)
    }
}

struct CardSelectorView: View {
    @Binding var selectedCards: [Card]
    let maxSelection: Int
    let availableCards: [Card]
    
    @State private var selectedRanks: Set<Rank> = []
    @State private var selectedSuits: Set<Suit> = []
    
    // Keyboard-style layout for ranks
    let rankRows: [[Rank]] = [
        [.ace, .two, .three, .four],
        [.five, .six, .seven, .eight],
        [.nine, .ten, .jack, .queen, .king]
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Selected cards display
            if !selectedCards.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected Cards (\(selectedCards.count)/\(maxSelection))")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(selectedCards) { card in
                                CardView(card: card, size: .medium, isSelected: true)
                                    .onTapGesture {
                                        removeCard(card)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // Rank Selection (Keyboard Layout)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Ranks")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            ForEach(rankRows, id: \.self) { row in
                                HStack(spacing: 8) {
                                    ForEach(row, id: \.self) { rank in
                                        Button(action: {
                                            toggleRank(rank)
                                        }) {
                                            Text(rank.rawValue)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(selectedRanks.contains(rank) ? .white : .primary)
                                                .frame(width: 50, height: 50)
                                                .background(selectedRanks.contains(rank) ? Color.blue : Color(.systemGray5))
                                                .cornerRadius(8)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    if row.count < 4 {
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    
                    // Suit Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Suits")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            ForEach(Suit.allCases, id: \.self) { suit in
                                Button(action: {
                                    toggleSuit(suit)
                                }) {
                                    VStack(spacing: 4) {
                                        Text(suit.rawValue)
                                            .font(.title)
                                            .foregroundColor(selectedSuits.contains(suit) ? .white : suit.color)
                                        
                                        Text(suitName(suit))
                                            .font(.caption)
                                            .foregroundColor(selectedSuits.contains(suit) ? .white : .primary)
                                    }
                                    .frame(width: 70, height: 70)
                                    .background(selectedSuits.contains(suit) ? Color.blue : Color(.systemGray5))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Available combinations
                    if !selectedRanks.isEmpty && !selectedSuits.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Available Cards")
                                .font(.headline)
                            
                            let availableCombinations = getAvailableCombinations()
                            
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 50), spacing: 8)
                            ], spacing: 12) {
                                ForEach(availableCombinations, id: \.id) { card in
                                    Button(action: {
                                        toggleCardSelection(card)
                                    }) {
                                        CardView(
                                            card: card,
                                            size: .medium,
                                            isSelected: selectedCards.contains(card)
                                        )
                                    }
                                    .disabled(selectedCards.count >= maxSelection && !selectedCards.contains(card))
                                    .opacity(selectedCards.count >= maxSelection && !selectedCards.contains(card) ? 0.5 : 1.0)
                                }
                            }
                        }
                    }
                    
                    // Quick selection buttons
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            Button("Clear All") {
                                clearAll()
                            }
                            .buttonStyle(.bordered)
                            
                            if selectedCards.count == maxSelection {
                                Button("Remove Last") {
                                    removeLast()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private func toggleRank(_ rank: Rank) {
        if selectedRanks.contains(rank) {
            selectedRanks.remove(rank)
        } else {
            selectedRanks.insert(rank)
        }
    }
    
    private func toggleSuit(_ suit: Suit) {
        if selectedSuits.contains(suit) {
            selectedSuits.remove(suit)
        } else {
            selectedSuits.insert(suit)
        }
    }
    
    private func getAvailableCombinations() -> [Card] {
        var combinations: [Card] = []
        for rank in selectedRanks {
            for suit in selectedSuits {
                let card = Card(rank: rank, suit: suit)
                if availableCards.contains(card) {
                    combinations.append(card)
                }
            }
        }
        return combinations.sorted { card1, card2 in
            if card1.rank.value != card2.rank.value {
                return card1.rank.value > card2.rank.value
            }
            return card1.suit.rawValue < card2.suit.rawValue
        }
    }
    
    private func toggleCardSelection(_ card: Card) {
        if let index = selectedCards.firstIndex(of: card) {
            selectedCards.remove(at: index)
        } else if selectedCards.count < maxSelection {
            selectedCards.append(card)
        }
    }
    
    private func removeCard(_ card: Card) {
        if let index = selectedCards.firstIndex(of: card) {
            selectedCards.remove(at: index)
        }
    }
    
    private func clearAll() {
        selectedCards.removeAll()
        selectedRanks.removeAll()
        selectedSuits.removeAll()
    }
    
    private func removeLast() {
        if !selectedCards.isEmpty {
            selectedCards.removeLast()
        }
    }
    
    private func suitName(_ suit: Suit) -> String {
        switch suit {
        case .clubs:
            return "Clubs"
        case .diamonds:
            return "Diamond"
        case .hearts:
            return "Heart"
        case .spades:
            return "Spade"
        }
    }
}

struct HandCardsView: View {
    let cards: [Card]
    let size: CardSize
    
    var body: some View {
        HStack(spacing: size == .small ? 2 : 4) {
            ForEach(cards) { card in
                CardView(card: card, size: size)
            }
        }
    }
}

// Enhanced card selector with better UX
struct EnhancedCardSelectorView: View {
    @Binding var selectedCards: [Card]
    let maxSelection: Int
    let availableCards: [Card]
    let title: String
    
    @State private var searchText = ""
    @State private var filterBySuit: Suit?
    
    var filteredCards: [Card] {
        var cards = availableCards
        
        if let suit = filterBySuit {
            cards = cards.filter { $0.suit == suit }
        }
        
        if !searchText.isEmpty {
            cards = cards.filter { card in
                card.rank.rawValue.lowercased().contains(searchText.lowercased()) ||
                card.suit.rawValue.contains(searchText)
            }
        }
        
        return cards.sorted { card1, card2 in
            if card1.rank.value != card2.rank.value {
                return card1.rank.value > card2.rank.value
            }
            return card1.suit.rawValue < card2.suit.rawValue
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with selection count
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(selectedCards.count)/\(maxSelection)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // Selected cards preview
            if !selectedCards.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedCards) { card in
                            CardView(card: card, size: .small, isSelected: true)
                                .onTapGesture {
                                    removeCard(card)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 45)
            }
            
            // Suit filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button("All") {
                        filterBySuit = nil
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(filterBySuit == nil ? Color.blue : Color(.systemGray5))
                    .foregroundColor(filterBySuit == nil ? .white : .primary)
                    .cornerRadius(16)
                    
                    ForEach(Suit.allCases, id: \.self) { suit in
                        Button(action: {
                            filterBySuit = filterBySuit == suit ? nil : suit
                        }) {
                            HStack(spacing: 4) {
                                Text(suit.rawValue)
                                    .foregroundColor(suit.color)
                                Text(suitName(suit))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(filterBySuit == suit ? Color.blue : Color(.systemGray5))
                        .foregroundColor(filterBySuit == suit ? .white : .primary)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
            }
            
            // Cards grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 50), spacing: 8)
                ], spacing: 12) {
                    ForEach(filteredCards) { card in
                        Button(action: {
                            toggleCardSelection(card)
                        }) {
                            CardView(
                                card: card,
                                size: .medium,
                                isSelected: selectedCards.contains(card)
                            )
                        }
                        .disabled(selectedCards.count >= maxSelection && !selectedCards.contains(card))
                        .opacity(selectedCards.count >= maxSelection && !selectedCards.contains(card) ? 0.5 : 1.0)
                    }
                }
                .padding()
            }
        }
    }
    
    private func toggleCardSelection(_ card: Card) {
        if let index = selectedCards.firstIndex(of: card) {
            selectedCards.remove(at: index)
        } else if selectedCards.count < maxSelection {
            selectedCards.append(card)
        }
    }
    
    private func removeCard(_ card: Card) {
        if let index = selectedCards.firstIndex(of: card) {
            selectedCards.remove(at: index)
        }
    }
    
    private func suitName(_ suit: Suit) -> String {
        switch suit {
        case .clubs:
            return "Clubs"
        case .diamonds:
            return "Diamond"
        case .hearts:
            return "Heart"
        case .spades:
            return "Spade"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Single card examples
        HStack(spacing: 20) {
            CardView(card: Card(rank: .ace, suit: .spades), size: .small)
            CardView(card: Card(rank: .king, suit: .hearts), size: .medium)
            CardView(card: Card(rank: .queen, suit: .diamonds), size: .large)
        }
        
        // Selected card
        CardView(card: Card(rank: .jack, suit: .clubs), size: .medium, isSelected: true)
        
        // Card back
        CardBackView(size: .medium)
        
        // Hand cards
        HandCardsView(
            cards: [
                Card(rank: .ace, suit: .spades),
                Card(rank: .king, suit: .spades)
            ],
            size: .medium
        )
    }
    .padding()
} 