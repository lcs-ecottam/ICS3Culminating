import SwiftUI

struct MancalaView: View {
    // MARK: - Stored properties
    
    @State private var game = MancalaGame()
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Mancala")
                .font(.largeTitle)
                .bold()
            
            Text(game.message)
                .font(.headline)
                .foregroundStyle(game.currentPlayer == .playerOne ? .blue : .red)
            
            HStack(spacing: 20) {
                // Player Two's Store
                StoreView(count: game.pits[13], label: "P2 Store", color: .red)
                
                VStack(spacing: 20) {
                    // Player Two's Pits (Top row, reversed for board orientation)
                    HStack(spacing: 15) {
                        ForEach((7...12).reversed(), id: \.self) { index in
                            PitView(count: game.pits[index], color: .red) {
                                game.makeMove(at: index)
                            }
                        }
                    }
                    
                    // Player One's Pits (Bottom row)
                    HStack(spacing: 15) {
                        ForEach(0...5, id: \.self) { index in
                            PitView(count: game.pits[index], color: .blue) {
                                game.makeMove(at: index)
                            }
                        }
                    }
                }
                
                // Player One's Store
                StoreView(count: game.pits[6], label: "P1 Store", color: .blue)
            }
            .padding()
            .background(Color.brown.opacity(0.2))
            .cornerRadius(20)
            
            Button("Reset Game") {
                game.resetGame()
            }
            .buttonStyle(.borderedProminent)
            .tint(.brown)
        }
        .padding()
    }
}

// MARK: - Helper Views

struct PitView: View {
    let count: Int
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Text("\(count)")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.primary)
            }
        }
    }
}

struct StoreView: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .bold()
            
            ZStack {
                Capsule()
                    .fill(color.opacity(0.3))
                    .frame(width: 60, height: 120)
                
                Text("\(count)")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.primary)
            }
        }
    }
}

#Preview {
    MancalaView()
}
