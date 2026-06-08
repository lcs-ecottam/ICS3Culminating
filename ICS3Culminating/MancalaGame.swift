import Foundation
import Observation

@Observable
class MancalaGame {
    // MARK: - Stored properties
    
    var board: MancalaBoard = MancalaBoard.defaultBoard()
    var message: String = "Player One's Turn"
    var isVsCPU: Bool = false
    var isThinking: Bool = false
    
    // MARK: - Initializer
    
    init() {
        resetGame()
    }
    
    // MARK: - Functions
    
    func resetGame() {
        self.board = MancalaBoard.defaultBoard()
        self.isThinking = false
        updateMessage()
    }
    
    func makeMove(at index: Int) {
        guard !board.isGameOver else { return }
        guard !isThinking else { return } // Prevent human moves while AI is thinking
        
        let (newBoard, getsExtraTurn) = MancalaEngine.applyMove(at: index, on: board)
        
        // If move was invalid (e.g. wrong side), nothing changes
        if newBoard.pits == board.pits && newBoard.currentPlayer == board.currentPlayer {
            return
        }
        
        self.board = newBoard
        updateMessage()
        
        if getsExtraTurn && !board.isGameOver {
            message = "\(board.currentPlayer == .playerOne ? "Player One" : "Player Two") gets an extra turn!"
        }
        
        // Trigger AI if it's CPU's turn
        checkAITurn()
    }
    
    func checkAITurn() {
        guard isVsCPU && board.currentPlayer == .playerTwo && !board.isGameOver else { return }
        
        isThinking = true
        message = "CPU is thinking..."
        
        // Run AI move after a delay on a background task
        Task {
            // Delay for "thinking" effect
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            if let bestMove = MancalaAI.bestMove(for: board) {
                await MainActor.run {
                    self.isThinking = false
                    self.applyAIMove(at: bestMove)
                }
            } else {
                await MainActor.run {
                    self.isThinking = false
                }
            }
        }
    }
    
    private func applyAIMove(at index: Int) {
        let (newBoard, getsExtraTurn) = MancalaEngine.applyMove(at: index, on: board)
        self.board = newBoard
        updateMessage()
        
        if getsExtraTurn && !board.isGameOver {
            message = "CPU gets an extra turn!"
            checkAITurn() // AI takes another turn
        } else {
            checkAITurn() // Check if it's somehow still AI's turn or game ended
        }
    }
    
    var winnerName: String {
        if !board.isGameOver { return "" }
        let p1Score = board.pits[6]
        let p2Score = board.pits[13]
        
        if p1Score > p2Score {
            return "Player One"
        } else if p2Score > p1Score {
            return isVsCPU ? "CPU" : "Player Two"
        } else {
            return "Tie"
        }
    }
    
    private func updateMessage() {
        if board.isGameOver {
            let p1Score = board.pits[6]
            let p2Score = board.pits[13]
            
            if p1Score > p2Score {
                message = "Game Over! Player One wins \(p1Score) to \(p2Score)!"
            } else if p2Score > p1Score {
                message = "Game Over! \(isVsCPU ? "CPU wins" : "Player Two wins") \(p2Score) to \(p1Score)!"
            } else {
                message = "Game Over! It's a tie \(p1Score) to \(p2Score)!"
            }
        } else {
            if board.currentPlayer == .playerOne {
                message = "Player One's Turn"
            } else {
                message = isVsCPU ? "CPU's Turn" : "Player Two's Turn"
            }
        }
    }
}
