import Foundation

class MancalaAI {
    // MARK: - Functions
    
    /// Finds the best move for the current player using Minimax with Alpha-Beta pruning.
    static func bestMove(for board: MancalaBoard, depth: Int = 5) -> Int? {
        let player = board.currentPlayer
        var bestScore = Int.min
        var bestMoveIndex: Int?
        
        let validMoves = getValidMoves(for: board)
        
        // If there are no moves or game is over, return nil
        if validMoves.isEmpty || board.isGameOver {
            return nil
        }
        
        for move in validMoves {
            let (newBoard, getsExtraTurn) = MancalaEngine.applyMove(at: move, on: board)
            
            let score: Int
            if getsExtraTurn && !newBoard.isGameOver {
                // If same player gets another turn, keep maximizing
                score = minimax(board: newBoard, depth: depth - 1, alpha: Int.min, beta: Int.max, isMaximizing: true, player: player)
            } else {
                // Switch to opponent's turn (minimizing)
                score = minimax(board: newBoard, depth: depth - 1, alpha: Int.min, beta: Int.max, isMaximizing: false, player: player)
            }
            
            if score > bestScore {
                bestScore = score
                bestMoveIndex = move
            }
        }
        
        return bestMoveIndex
    }
    
    private static func minimax(board: MancalaBoard, depth: Int, alpha: Int, beta: Int, isMaximizing: Bool, player: MancalaPlayer) -> Int {
        if depth == 0 || board.isGameOver {
            return evaluate(board: board, for: player)
        }
        
        var currentAlpha = alpha
        var currentBeta = beta
        
        let validMoves = getValidMoves(for: board)
        
        if isMaximizing {
            var maxEval = Int.min
            for move in validMoves {
                let (newBoard, getsExtraTurn) = MancalaEngine.applyMove(at: move, on: board)
                
                let eval: Int
                if getsExtraTurn && !newBoard.isGameOver {
                    eval = minimax(board: newBoard, depth: depth - 1, alpha: currentAlpha, beta: currentBeta, isMaximizing: true, player: player)
                } else {
                    eval = minimax(board: newBoard, depth: depth - 1, alpha: currentAlpha, beta: currentBeta, isMaximizing: false, player: player)
                }
                
                maxEval = max(maxEval, eval)
                currentAlpha = max(currentAlpha, eval)
                if currentBeta <= currentAlpha {
                    break
                }
            }
            return maxEval
        } else {
            var minEval = Int.max
            for move in validMoves {
                let (newBoard, getsExtraTurn) = MancalaEngine.applyMove(at: move, on: board)
                
                let eval: Int
                if getsExtraTurn && !newBoard.isGameOver {
                    // This is the opponent getting an extra turn, so we stay in minimizing mode
                    eval = minimax(board: newBoard, depth: depth - 1, alpha: currentAlpha, beta: currentBeta, isMaximizing: false, player: player)
                } else {
                    // Back to our turn
                    eval = minimax(board: newBoard, depth: depth - 1, alpha: currentAlpha, beta: currentBeta, isMaximizing: true, player: player)
                }
                
                minEval = min(minEval, eval)
                currentBeta = min(currentBeta, eval)
                if currentBeta <= currentAlpha {
                    break
                }
            }
            return minEval
        }
    }
    
    /// Heuristic evaluation function for the board state.
    private static func evaluate(board: MancalaBoard, for player: MancalaPlayer) -> Int {
        let myStoreIndex = (player == .playerOne) ? 6 : 13
        let opponentStoreIndex = (player == .playerOne) ? 13 : 6
        
        let myScore = board.pits[myStoreIndex]
        let opponentScore = board.pits[opponentStoreIndex]
        
        // 1. Primary factor: Score differential in stores
        var totalEval = (myScore - opponentScore) * 10
        
        // 2. Secondary factor: Number of stones on own side (tactical flexibility)
        var mySideStones = 0
        var opponentSideStones = 0
        
        if player == .playerOne {
            for i in 0...5 { mySideStones += board.pits[i] }
            for i in 7...12 { opponentSideStones += board.pits[i] }
        } else {
            for i in 7...12 { mySideStones += board.pits[i] }
            for i in 0...5 { opponentSideStones += board.pits[i] }
        }
        
        totalEval += (mySideStones - opponentSideStones) * 2
        
        // 3. Game over bonus
        if board.isGameOver {
            if board.winner == player {
                totalEval += 1000
            } else if board.winner == player.opposite {
                totalEval -= 1000
            }
        }
        
        return totalEval
    }
    
    private static func getValidMoves(for board: MancalaBoard) -> [Int] {
        var moves: [Int] = []
        if board.currentPlayer == .playerOne {
            for i in 0...5 {
                if board.pits[i] > 0 { moves.append(i) }
            }
        } else {
            for i in 7...12 {
                if board.pits[i] > 0 { moves.append(i) }
            }
        }
        return moves
    }
}
