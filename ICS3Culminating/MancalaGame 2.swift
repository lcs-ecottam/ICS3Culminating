import Foundation
import Observation

@Observable
class MancalaGame {
    // MARK: - Stored properties
    
    /// The pits on the board.
    /// Index 0-5: Player One's pits
    /// Index 6: Player One's store
    /// Index 7-12: Player Two's pits
    /// Index 13: Player Two's store
    var pits: [Int] = Array(repeating: 4, count: 14)
    
    var currentPlayer: MancalaPlayer = .playerOne
    var isGameOver: Bool = false
    var winner: MancalaPlayer? = nil
    var message: String = "Player One's Turn"
    
    // MARK: - Initializer
    
    init() {
        resetGame()
    }
    
    // MARK: - Functions
    
    func resetGame() {
        var newPits: [Int] = []
        for index in 0..<14 {
            if index == 6 || index == 13 {
                newPits.append(0)
            } else {
                newPits.append(4)
            }
        }
        self.pits = newPits
        self.currentPlayer = .playerOne
        self.isGameOver = false
        self.winner = nil
        self.message = "Player One's Turn"
    }
    
    func makeMove(at index: Int) {
        guard !isGameOver else { return }
        guard isValidMove(at: index) else { return }
        
        var stonesInHand = pits[index]
        pits[index] = 0
        
        var currentIndex = index
        
        while stonesInHand > 0 {
            currentIndex = (currentIndex + 1) % 14
            
            // Skip opponent's store
            if isOpponentStore(at: currentIndex) {
                continue
            }
            
            pits[currentIndex] += 1
            stonesInHand -= 1
        }
        
        handleTurnEnd(lastIndex: currentIndex)
    }
    
    private func isValidMove(at index: Int) -> Bool {
        // Must be a small pit (not a store)
        if index == 6 || index == 13 {
            return false
        }
        
        // Must be the current player's side
        if currentPlayer == .playerOne && (index < 0 || index > 5) {
            return false
        }
        if currentPlayer == .playerTwo && (index < 7 || index > 12) {
            return false
        }
        
        // Must have stones
        if pits[index] == 0 {
            return false
        }
        
        return true
    }
    
    private func isOpponentStore(at index: Int) -> Bool {
        if currentPlayer == .playerOne && index == 13 {
            return true
        }
        if currentPlayer == .playerTwo && index == 6 {
            return true
        }
        return false
    }
    
    private func handleTurnEnd(lastIndex: Int) {
        // Rule: Extra turn if last stone lands in own store
        let landedInOwnStore = (currentPlayer == .playerOne && lastIndex == 6) ||
                               (currentPlayer == .playerTwo && lastIndex == 13)
        
        // Rule: Capture if last stone lands in empty pit on own side
        if !landedInOwnStore {
            handleCapture(at: lastIndex)
        }
        
        checkEndGame()
        
        if isGameOver {
            determineWinner()
        } else if !landedInOwnStore {
            currentPlayer = currentPlayer.opposite
            updateMessage()
        } else {
            message = "\(currentPlayer == .playerOne ? "Player One" : "Player Two") gets an extra turn!"
        }
    }
    
    private func handleCapture(at index: Int) {
        // Check if index is on current player's side
        let isOnOwnSide: Bool
        if currentPlayer == .playerOne {
            isOnOwnSide = (index >= 0 && index <= 5)
        } else {
            isOnOwnSide = (index >= 7 && index <= 12)
        }
        
        // Must land in a pit that was previously empty (now has 1 stone)
        if isOnOwnSide && pits[index] == 1 {
            let oppositeIndex = 12 - index
            let capturedStones = pits[oppositeIndex]
            
            if capturedStones > 0 {
                pits[oppositeIndex] = 0
                pits[index] = 0
                
                let storeIndex = (currentPlayer == .playerOne) ? 6 : 13
                pits[storeIndex] += (capturedStones + 1)
                message = "\(currentPlayer == .playerOne ? "Player One" : "Player Two") captured \(capturedStones) stones!"
            }
        }
    }
    
    private func checkEndGame() {
        var playerOnePitsEmpty = true
        for i in 0...5 {
            if pits[i] > 0 {
                playerOnePitsEmpty = false
                break
            }
        }
        
        var playerTwoPitsEmpty = true
        for i in 7...12 {
            if pits[i] > 0 {
                playerTwoPitsEmpty = false
                break
            }
        }
        
        if playerOnePitsEmpty || playerTwoPitsEmpty {
            isGameOver = true
            sweepRemainingStones()
        }
    }
    
    private func sweepRemainingStones() {
        var p1Total = 0
        for i in 0...5 {
            p1Total += pits[i]
            pits[i] = 0
        }
        pits[6] += p1Total
        
        var p2Total = 0
        for i in 7...12 {
            p2Total += pits[i]
            pits[i] = 0
        }
        pits[13] += p2Total
    }
    
    private func determineWinner() {
        let p1Score = pits[6]
        let p2Score = pits[13]
        
        if p1Score > p2Score {
            winner = .playerOne
            message = "Game Over! Player One wins \(p1Score) to \(p2Score)!"
        } else if p2Score > p1Score {
            winner = .playerTwo
            message = "Game Over! Player Two wins \(p2Score) to \(p1Score)!"
        } else {
            winner = nil
            message = "Game Over! It's a tie \(p1Score) to \(p2Score)!"
        }
    }
    
    private func updateMessage() {
        message = (currentPlayer == .playerOne) ? "Player One's Turn" : "Player Two's Turn"
    }
}
