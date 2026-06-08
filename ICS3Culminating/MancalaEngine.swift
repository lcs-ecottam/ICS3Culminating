import Foundation

class MancalaEngine {
    // MARK: - Functions
    
    static func applyMove(at index: Int, on board: MancalaBoard) -> (MancalaBoard, Bool) {
        var newBoard = board
        
        guard !newBoard.isGameOver else { return (newBoard, false) }
        guard isValidMove(at: index, on: newBoard) else { return (newBoard, false) }
        
        var stonesInHand = newBoard.pits[index]
        newBoard.pits[index] = 0
        
        var currentIndex = index
        
        while stonesInHand > 0 {
            currentIndex = (currentIndex + 1) % 14
            
            // Skip opponent's store
            if isOpponentStore(at: currentIndex, for: newBoard.currentPlayer) {
                continue
            }
            
            newBoard.pits[currentIndex] += 1
            stonesInHand -= 1
        }
        
        // Rule: Extra turn if last stone lands in own store
        let landedInOwnStore = (newBoard.currentPlayer == .playerOne && currentIndex == 6) ||
                               (newBoard.currentPlayer == .playerTwo && currentIndex == 13)
        
        // Rule: Capture if last stone lands in empty pit on own side
        if !landedInOwnStore {
            newBoard = handleCapture(at: currentIndex, on: newBoard)
        }
        
        newBoard = checkEndGame(on: newBoard)
        
        if newBoard.isGameOver {
            newBoard = determineWinner(on: newBoard)
        } else if !landedInOwnStore {
            newBoard.currentPlayer = newBoard.currentPlayer.opposite
        }
        
        return (newBoard, landedInOwnStore)
    }
    
    static func isValidMove(at index: Int, on board: MancalaBoard) -> Bool {
        // Must be a small pit (not a store)
        if index == 6 || index == 13 {
            return false
        }
        
        // Must be the current player's side
        if board.currentPlayer == .playerOne && (index < 0 || index > 5) {
            return false
        }
        if board.currentPlayer == .playerTwo && (index < 7 || index > 12) {
            return false
        }
        
        // Must have stones
        if board.pits[index] == 0 {
            return false
        }
        
        return true
    }
    
    private static func isOpponentStore(at index: Int, for player: MancalaPlayer) -> Bool {
        if player == .playerOne && index == 13 {
            return true
        }
        if player == .playerTwo && index == 6 {
            return true
        }
        return false
    }
    
    private static func handleCapture(at index: Int, on board: MancalaBoard) -> MancalaBoard {
        var newBoard = board
        
        // Check if index is on current player's side
        let isOnOwnSide: Bool
        if newBoard.currentPlayer == .playerOne {
            isOnOwnSide = (index >= 0 && index <= 5)
        } else {
            isOnOwnSide = (index >= 7 && index <= 12)
        }
        
        // Must land in a pit that was previously empty (now has 1 stone)
        if isOnOwnSide && newBoard.pits[index] == 1 {
            let oppositeIndex = 12 - index
            let capturedStones = newBoard.pits[oppositeIndex]
            
            if capturedStones > 0 {
                newBoard.pits[oppositeIndex] = 0
                newBoard.pits[index] = 0
                
                let storeIndex = (newBoard.currentPlayer == .playerOne) ? 6 : 13
                newBoard.pits[storeIndex] += (capturedStones + 1)
            }
        }
        
        return newBoard
    }
    
    private static func checkEndGame(on board: MancalaBoard) -> MancalaBoard {
        var newBoard = board
        
        var playerOnePitsEmpty = true
        for i in 0...5 {
            if newBoard.pits[i] > 0 {
                playerOnePitsEmpty = false
                break
            }
        }
        
        var playerTwoPitsEmpty = true
        for i in 7...12 {
            if newBoard.pits[i] > 0 {
                playerTwoPitsEmpty = false
                break
            }
        }
        
        if playerOnePitsEmpty || playerTwoPitsEmpty {
            newBoard.isGameOver = true
            newBoard = sweepRemainingStones(on: newBoard)
        }
        
        return newBoard
    }
    
    private static func sweepRemainingStones(on board: MancalaBoard) -> MancalaBoard {
        var newBoard = board
        
        var p1Total = 0
        for i in 0...5 {
            p1Total += newBoard.pits[i]
            newBoard.pits[i] = 0
        }
        newBoard.pits[6] += p1Total
        
        var p2Total = 0
        for i in 7...12 {
            p2Total += newBoard.pits[i]
            newBoard.pits[i] = 0
        }
        newBoard.pits[13] += p2Total
        
        return newBoard
    }
    
    private static func determineWinner(on board: MancalaBoard) -> MancalaBoard {
        var newBoard = board
        let p1Score = newBoard.pits[6]
        let p2Score = newBoard.pits[13]
        
        if p1Score > p2Score {
            newBoard.winner = .playerOne
        } else if p2Score > p1Score {
            newBoard.winner = .playerTwo
        } else {
            newBoard.winner = nil
        }
        
        return newBoard
    }
}
