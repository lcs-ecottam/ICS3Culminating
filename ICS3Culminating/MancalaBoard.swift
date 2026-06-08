import Foundation

struct MancalaBoard {
    // MARK: - Stored properties
    
    /// Index 0-5: Player One's pits
    /// Index 6: Player One's store
    /// Index 7-12: Player Two's pits
    /// Index 13: Player Two's store
    var pits: [Int]
    var currentPlayer: MancalaPlayer
    var isGameOver: Bool
    var winner: MancalaPlayer?
    
    // MARK: - Initializer
    
    init(pits: [Int] = Array(repeating: 4, count: 14), 
         currentPlayer: MancalaPlayer = .playerOne,
         isGameOver: Bool = false,
         winner: MancalaPlayer? = nil) {
        self.pits = pits
        self.currentPlayer = currentPlayer
        self.isGameOver = isGameOver
        self.winner = winner
    }
    
    static func defaultBoard() -> MancalaBoard {
        var pits = Array(repeating: 4, count: 14)
        pits[6] = 0
        pits[13] = 0
        return MancalaBoard(pits: pits)
    }
}
