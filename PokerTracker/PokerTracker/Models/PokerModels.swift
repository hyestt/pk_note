import Foundation
import SwiftUI

// MARK: - Core Data Models

struct PokerSession: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var location: String
    var blinds: String
    var currency: String
    var tableSize: Int
    var effectiveStack: Double
    var sessionTag: SessionTag
    var buyIn: Double
    var cashOut: Double
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    var profit: Double {
        return cashOut - buyIn
    }
    
    init(
        date: Date = Date(),
        location: String = "Live Casino",
        blinds: String = "5/10",
        currency: String = "USD",
        tableSize: Int = 10,
        effectiveStack: Double = 400,
        sessionTag: SessionTag = .none,
        buyIn: Double = 0,
        cashOut: Double = 0,
        isActive: Bool = true
    ) {
        self.date = date
        self.location = location
        self.blinds = blinds
        self.currency = currency
        self.tableSize = tableSize
        self.effectiveStack = effectiveStack
        self.sessionTag = sessionTag
        self.buyIn = buyIn
        self.cashOut = cashOut
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct PokerHand: Identifiable, Codable {
    let id = UUID()
    var sessionId: UUID
    var position: Position
    var holeCards: [Card]
    var boardCards: [Card]
    var actions: [HandAction]
    var result: HandResult
    var potSize: Double
    var netResult: Double
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    
    init(
        sessionId: UUID,
        position: Position = .button,
        holeCards: [Card] = [],
        boardCards: [Card] = [],
        actions: [HandAction] = [],
        result: HandResult = .fold,
        potSize: Double = 0,
        netResult: Double = 0,
        notes: String = ""
    ) {
        self.sessionId = sessionId
        self.position = position
        self.holeCards = holeCards
        self.boardCards = boardCards
        self.actions = actions
        self.result = result
        self.potSize = potSize
        self.netResult = netResult
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Enums

enum SessionTag: String, CaseIterable, Codable {
    case none = "None"
    case red = "Red"
    case blue = "Blue"
    case green = "Green"
    case yellow = "Yellow"
    case purple = "Purple"
    case orange = "Orange"
    case teal = "Teal"
    case pink = "Pink"
    
    var color: Color {
        switch self {
        case .none: return .gray
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .purple: return .purple
        case .orange: return .orange
        case .teal: return .teal
        case .pink: return .pink
        }
    }
}

enum Position: String, CaseIterable, Codable {
    case utg = "UTG"
    case utgPlus1 = "UTG+1"
    case mp = "MP"
    case co = "CO"
    case button = "BTN"
    case smallBlind = "SB"
    case bigBlind = "BB"
    
    var displayName: String {
        return self.rawValue
    }
}

enum Suit: String, CaseIterable, Codable {
    case clubs = "♣"
    case diamonds = "♦"
    case hearts = "♥"
    case spades = "♠"
    
    var color: Color {
        switch self {
        case .clubs, .spades:
            return .black
        case .diamonds, .hearts:
            return .red
        }
    }
}

enum Rank: String, CaseIterable, Codable {
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "T"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    case ace = "A"
    
    var value: Int {
        switch self {
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten: return 10
        case .jack: return 11
        case .queen: return 12
        case .king: return 13
        case .ace: return 14
        }
    }
}

struct Card: Identifiable, Codable, Equatable {
    let id = UUID()
    let rank: Rank
    let suit: Suit
    
    var displayString: String {
        return "\(rank.rawValue)\(suit.rawValue)"
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }
}

enum HandAction: String, CaseIterable, Codable {
    case fold = "Fold"
    case call = "Call"
    case raise = "Raise"
    case check = "Check"
    case bet = "Bet"
    case allIn = "All-In"
    
    var color: Color {
        switch self {
        case .fold: return .red
        case .call: return .blue
        case .raise, .bet: return .green
        case .check: return .gray
        case .allIn: return .purple
        }
    }
}

enum HandResult: String, CaseIterable, Codable {
    case fold = "Fold"
    case win = "Win"
    case lose = "Lose"
    case chop = "Chop"
    
    var color: Color {
        switch self {
        case .fold: return .gray
        case .win: return .green
        case .lose: return .red
        case .chop: return .orange
        }
    }
}

// MARK: - Helper Extensions

extension PokerSession {
    var isProfit: Bool {
        return profit > 0
    }
    
    var duration: TimeInterval {
        return updatedAt.timeIntervalSince(createdAt)
    }
}

extension Array where Element == Card {
    static var fullDeck: [Card] {
        var deck: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(Card(rank: rank, suit: suit))
            }
        }
        return deck
    }
} 