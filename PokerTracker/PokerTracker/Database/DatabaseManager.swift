import Foundation
import SQLite3
import Combine

class DatabaseManager: ObservableObject {
    static let shared = DatabaseManager()
    
    private var db: OpaquePointer?
    private let dbPath: String
    
    @Published var sessions: [PokerSession] = []
    @Published var hands: [PokerHand] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        // Get documents directory path
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("PokerTracker.sqlite")
        
        dbPath = fileURL.path
        
        openDatabase()
        createTables()
        loadAllData()
    }
    
    deinit {
        closeDatabase()
    }
    
    // MARK: - Database Connection
    
    private func openDatabase() {
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(dbPath)")
        } else {
            print("Unable to open database")
            errorMessage = "Unable to open database"
        }
    }
    
    private func closeDatabase() {
        if sqlite3_close(db) == SQLITE_OK {
            print("Database connection closed")
        } else {
            print("Unable to close database")
        }
    }
    
    // MARK: - Table Creation
    
    private func createTables() {
        createSessionsTable()
        createHandsTable()
        createSettingsTable()
    }
    
    private func createSessionsTable() {
        let createTableSQL = """
            CREATE TABLE IF NOT EXISTS sessions (
                id TEXT PRIMARY KEY,
                date REAL NOT NULL,
                location TEXT NOT NULL,
                blinds TEXT NOT NULL,
                currency TEXT NOT NULL,
                table_size INTEGER NOT NULL,
                effective_stack REAL NOT NULL,
                session_tag TEXT NOT NULL,
                buy_in REAL NOT NULL,
                cash_out REAL NOT NULL,
                is_active INTEGER NOT NULL,
                created_at REAL NOT NULL,
                updated_at REAL NOT NULL
            );
        """
        
        if sqlite3_exec(db, createTableSQL, nil, nil, nil) == SQLITE_OK {
            print("Sessions table created successfully")
        } else {
            print("Sessions table could not be created")
            errorMessage = "Sessions table could not be created"
        }
    }
    
    private func createHandsTable() {
        let createTableSQL = """
            CREATE TABLE IF NOT EXISTS hands (
                id TEXT PRIMARY KEY,
                session_id TEXT NOT NULL,
                position TEXT NOT NULL,
                hole_cards TEXT NOT NULL,
                board_cards TEXT NOT NULL,
                actions TEXT NOT NULL,
                result TEXT NOT NULL,
                pot_size REAL NOT NULL,
                net_result REAL NOT NULL,
                notes TEXT NOT NULL,
                created_at REAL NOT NULL,
                updated_at REAL NOT NULL,
                FOREIGN KEY (session_id) REFERENCES sessions (id)
            );
        """
        
        if sqlite3_exec(db, createTableSQL, nil, nil, nil) == SQLITE_OK {
            print("Hands table created successfully")
        } else {
            print("Hands table could not be created")
            errorMessage = "Hands table could not be created"
        }
    }
    
    private func createSettingsTable() {
        let createTableSQL = """
            CREATE TABLE IF NOT EXISTS settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL,
                updated_at REAL NOT NULL
            );
        """
        
        if sqlite3_exec(db, createTableSQL, nil, nil, nil) == SQLITE_OK {
            print("Settings table created successfully")
        } else {
            print("Settings table could not be created")
            errorMessage = "Settings table could not be created"
        }
    }
    
    // MARK: - Session CRUD Operations
    
    func createSession(_ session: PokerSession) {
        let insertSQL = """
            INSERT INTO sessions (id, date, location, blinds, currency, table_size, effective_stack, session_tag, buy_in, cash_out, is_active, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, session.id.uuidString, -1, nil)
            sqlite3_bind_double(statement, 2, session.date.timeIntervalSince1970)
            sqlite3_bind_text(statement, 3, session.location, -1, nil)
            sqlite3_bind_text(statement, 4, session.blinds, -1, nil)
            sqlite3_bind_text(statement, 5, session.currency, -1, nil)
            sqlite3_bind_int(statement, 6, Int32(session.tableSize))
            sqlite3_bind_double(statement, 7, session.effectiveStack)
            sqlite3_bind_text(statement, 8, session.sessionTag.rawValue, -1, nil)
            sqlite3_bind_double(statement, 9, session.buyIn)
            sqlite3_bind_double(statement, 10, session.cashOut)
            sqlite3_bind_int(statement, 11, session.isActive ? 1 : 0)
            sqlite3_bind_double(statement, 12, session.createdAt.timeIntervalSince1970)
            sqlite3_bind_double(statement, 13, session.updatedAt.timeIntervalSince1970)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Session inserted successfully")
                DispatchQueue.main.async {
                    self.sessions.append(session)
                }
            } else {
                print("Could not insert session")
                errorMessage = "Could not insert session"
            }
        } else {
            print("INSERT statement could not be prepared")
            errorMessage = "INSERT statement could not be prepared"
        }
        
        sqlite3_finalize(statement)
    }
    
    func updateSession(_ session: PokerSession) {
        let updateSQL = """
            UPDATE sessions SET date = ?, location = ?, blinds = ?, currency = ?, table_size = ?, effective_stack = ?, session_tag = ?, buy_in = ?, cash_out = ?, is_active = ?, updated_at = ?
            WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 1, session.date.timeIntervalSince1970)
            sqlite3_bind_text(statement, 2, session.location, -1, nil)
            sqlite3_bind_text(statement, 3, session.blinds, -1, nil)
            sqlite3_bind_text(statement, 4, session.currency, -1, nil)
            sqlite3_bind_int(statement, 5, Int32(session.tableSize))
            sqlite3_bind_double(statement, 6, session.effectiveStack)
            sqlite3_bind_text(statement, 7, session.sessionTag.rawValue, -1, nil)
            sqlite3_bind_double(statement, 8, session.buyIn)
            sqlite3_bind_double(statement, 9, session.cashOut)
            sqlite3_bind_int(statement, 10, session.isActive ? 1 : 0)
            sqlite3_bind_double(statement, 11, Date().timeIntervalSince1970)
            sqlite3_bind_text(statement, 12, session.id.uuidString, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Session updated successfully")
                DispatchQueue.main.async {
                    if let index = self.sessions.firstIndex(where: { $0.id == session.id }) {
                        self.sessions[index] = session
                    }
                }
            } else {
                print("Could not update session")
                errorMessage = "Could not update session"
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    func deleteSession(_ sessionId: UUID) {
        let deleteSQL = "DELETE FROM sessions WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, sessionId.uuidString, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Session deleted successfully")
                DispatchQueue.main.async {
                    self.sessions.removeAll { $0.id == sessionId }
                }
            } else {
                print("Could not delete session")
                errorMessage = "Could not delete session"
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - Hand CRUD Operations
    
    func createHand(_ hand: PokerHand) {
        let insertSQL = """
            INSERT INTO hands (id, session_id, position, hole_cards, board_cards, actions, result, pot_size, net_result, notes, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            let holeCardsData = try! JSONEncoder().encode(hand.holeCards)
            let boardCardsData = try! JSONEncoder().encode(hand.boardCards)
            let actionsData = try! JSONEncoder().encode(hand.actions)
            
            sqlite3_bind_text(statement, 1, hand.id.uuidString, -1, nil)
            sqlite3_bind_text(statement, 2, hand.sessionId.uuidString, -1, nil)
            sqlite3_bind_text(statement, 3, hand.position.rawValue, -1, nil)
            sqlite3_bind_text(statement, 4, String(data: holeCardsData, encoding: .utf8), -1, nil)
            sqlite3_bind_text(statement, 5, String(data: boardCardsData, encoding: .utf8), -1, nil)
            sqlite3_bind_text(statement, 6, String(data: actionsData, encoding: .utf8), -1, nil)
            sqlite3_bind_text(statement, 7, hand.result.rawValue, -1, nil)
            sqlite3_bind_double(statement, 8, hand.potSize)
            sqlite3_bind_double(statement, 9, hand.netResult)
            sqlite3_bind_text(statement, 10, hand.notes, -1, nil)
            sqlite3_bind_double(statement, 11, hand.createdAt.timeIntervalSince1970)
            sqlite3_bind_double(statement, 12, hand.updatedAt.timeIntervalSince1970)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Hand inserted successfully")
                DispatchQueue.main.async {
                    self.hands.append(hand)
                }
            } else {
                print("Could not insert hand")
                errorMessage = "Could not insert hand"
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - Data Loading
    
    private func loadAllData() {
        loadSessions()
        loadHands()
    }
    
    private func loadSessions() {
        let querySQL = "SELECT * FROM sessions ORDER BY created_at DESC;"
        var statement: OpaquePointer?
        var loadedSessions: [PokerSession] = []
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = UUID(uuidString: String(cString: sqlite3_column_text(statement, 0))) ?? UUID()
                let date = Date(timeIntervalSince1970: sqlite3_column_double(statement, 1))
                let location = String(cString: sqlite3_column_text(statement, 2))
                let blinds = String(cString: sqlite3_column_text(statement, 3))
                let currency = String(cString: sqlite3_column_text(statement, 4))
                let tableSize = Int(sqlite3_column_int(statement, 5))
                let effectiveStack = sqlite3_column_double(statement, 6)
                let sessionTag = SessionTag(rawValue: String(cString: sqlite3_column_text(statement, 7))) ?? .none
                let buyIn = sqlite3_column_double(statement, 8)
                let cashOut = sqlite3_column_double(statement, 9)
                let isActive = sqlite3_column_int(statement, 10) == 1
                let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 11))
                let updatedAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 12))
                
                var session = PokerSession(
                    date: date,
                    location: location,
                    blinds: blinds,
                    currency: currency,
                    tableSize: tableSize,
                    effectiveStack: effectiveStack,
                    sessionTag: sessionTag,
                    buyIn: buyIn,
                    cashOut: cashOut,
                    isActive: isActive
                )
                
                // Override the generated values with database values
                session = PokerSession(
                    date: date,
                    location: location,
                    blinds: blinds,
                    currency: currency,
                    tableSize: tableSize,
                    effectiveStack: effectiveStack,
                    sessionTag: sessionTag,
                    buyIn: buyIn,
                    cashOut: cashOut,
                    isActive: isActive
                )
                
                loadedSessions.append(session)
            }
        }
        
        sqlite3_finalize(statement)
        
        DispatchQueue.main.async {
            self.sessions = loadedSessions
        }
    }
    
    private func loadHands() {
        let querySQL = "SELECT * FROM hands ORDER BY created_at DESC;"
        var statement: OpaquePointer?
        var loadedHands: [PokerHand] = []
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = UUID(uuidString: String(cString: sqlite3_column_text(statement, 0))) ?? UUID()
                let sessionId = UUID(uuidString: String(cString: sqlite3_column_text(statement, 1))) ?? UUID()
                let position = Position(rawValue: String(cString: sqlite3_column_text(statement, 2))) ?? .button
                
                let holeCardsString = String(cString: sqlite3_column_text(statement, 3))
                let boardCardsString = String(cString: sqlite3_column_text(statement, 4))
                let actionsString = String(cString: sqlite3_column_text(statement, 5))
                
                let holeCards = try! JSONDecoder().decode([Card].self, from: holeCardsString.data(using: .utf8)!)
                let boardCards = try! JSONDecoder().decode([Card].self, from: boardCardsString.data(using: .utf8)!)
                let actions = try! JSONDecoder().decode([HandAction].self, from: actionsString.data(using: .utf8)!)
                
                let result = HandResult(rawValue: String(cString: sqlite3_column_text(statement, 6))) ?? .fold
                let potSize = sqlite3_column_double(statement, 7)
                let netResult = sqlite3_column_double(statement, 8)
                let notes = String(cString: sqlite3_column_text(statement, 9))
                let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 10))
                let updatedAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 11))
                
                let hand = PokerHand(
                    sessionId: sessionId,
                    position: position,
                    holeCards: holeCards,
                    boardCards: boardCards,
                    actions: actions,
                    result: result,
                    potSize: potSize,
                    netResult: netResult,
                    notes: notes
                )
                
                loadedHands.append(hand)
            }
        }
        
        sqlite3_finalize(statement)
        
        DispatchQueue.main.async {
            self.hands = loadedHands
        }
    }
    
    // MARK: - Helper Methods
    
    func getHandsForSession(_ sessionId: UUID) -> [PokerHand] {
        return hands.filter { $0.sessionId == sessionId }
    }
    
    func getActiveSession() -> PokerSession? {
        return sessions.first { $0.isActive }
    }
} 