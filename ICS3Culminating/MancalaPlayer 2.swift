import Foundation

enum MancalaPlayer {
    case playerOne
    case playerTwo
    
    var opposite: MancalaPlayer {
        switch self {
        case .playerOne:
            return .playerTwo
        case .playerTwo:
            return .playerOne
        }
    }
}
