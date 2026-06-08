import Foundation
import SwiftData

@Model
class GameHistory {
    // MARK: - Stored properties
    
    var date: Date
    var playerOneScore: Int
    var playerTwoScore: Int
    var isVsCPU: Bool
    var winnerName: String
    
    // MARK: - Initializer
    
    init(date: Date = Date(), 
         playerOneScore: Int, 
         playerTwoScore: Int, 
         isVsCPU: Bool, 
         winnerName: String) {
        self.date = date
        self.playerOneScore = playerOneScore
        self.playerTwoScore = playerTwoScore
        self.isVsCPU = isVsCPU
        self.winnerName = winnerName
    }
}
