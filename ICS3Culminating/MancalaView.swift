import SwiftUI
import SwiftData

struct MancalaView: View {
    // MARK: - Stored properties
    
    @State private var game = MancalaGame()
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Main App Background
            Color(red: 0.15, green: 0.1, blue: 0.05)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Engraved Title
                Text("MANCALA")
                    .font(.custom("Georgia", size: 40))
                    .bold()
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(white: 0.1), Color(white: 0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: 1)
                
                HStack {
                    Toggle("Play vs CPU", isOn: $game.isVsCPU)
                        .toggleStyle(.switch)
                        .foregroundStyle(.white.opacity(0.8))
                        .onChange(of: game.isVsCPU) {
                            game.resetGame()
                        }
                    Spacer()
                }
                .padding(.horizontal)
                
                // Status Message
                Text(game.message)
                    .font(.custom("Georgia-Italic", size: 18))
                    .foregroundStyle(game.board.currentPlayer == .playerOne ? Color.blue.opacity(0.8) : Color.red.opacity(0.8))
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                
                // The Wooden Board
                VStack(spacing: 0) {
                    HStack(spacing: 20) {
                        // CPU / Player Two Store
                        StoreView(count: game.board.pits[13], label: game.isVsCPU ? "CPU" : "P2", color: .red)
                        
                        VStack(spacing: 25) {
                            // Player Two's Pits (Top row)
                            HStack(spacing: 15) {
                                ForEach((7...12).reversed(), id: \.self) { index in
                                    PitView(count: game.board.pits[index], color: .red, isEnabled: !game.isThinking) {
                                        game.makeMove(at: index)
                                    }
                                }
                            }
                            
                            // Player One's Pits (Bottom row)
                            HStack(spacing: 15) {
                                ForEach(0...5, id: \.self) { index in
                                    PitView(count: game.board.pits[index], color: .blue, isEnabled: !game.isThinking) {
                                        game.makeMove(at: index)
                                    }
                                }
                            }
                        }
                        
                        // Player One's Store
                        StoreView(count: game.board.pits[6], label: "P1", color: .blue)
                    }
                    .padding(30)
                    .background(
                        // Wood Texture Background
                        LinearGradient(
                            colors: [
                                Color(red: 0.45, green: 0.25, blue: 0.1),
                                Color(red: 0.35, green: 0.2, blue: 0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .strokeBorder(Color.black.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
                }
                
                Button("Reset Game") {
                    game.resetGame()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.3, green: 0.15, blue: 0.05))
                .foregroundStyle(.white.opacity(0.9))
                .disabled(game.isThinking)
                
                Spacer()
            }
            .padding()
        }
        .onChange(of: game.board.isGameOver) {
            if game.board.isGameOver {
                saveGame()
            }
        }
    }
    
    // MARK: - Functions
    
    private func saveGame() {
        let history = GameHistory(
            playerOneScore: game.board.pits[6],
            playerTwoScore: game.board.pits[13],
            isVsCPU: game.isVsCPU,
            winnerName: game.winnerName
        )
        modelContext.insert(history)
    }
}

// MARK: - Helper Views

struct StoneView: View {
    let index: Int
    
    // Deterministic random color and offset based on index
    private var stoneColor: Color {
        let colors: [Color] = [
            .white.opacity(0.8),
            .gray.opacity(0.8),
            Color(white: 0.9),
            Color(red: 0.7, green: 0.7, blue: 0.8)
        ]
        return colors[index % colors.count]
    }
    
    private var offset: CGSize {
        // Use sine/cosine for deterministic spread
        let angle = Double(index) * 1.5
        let radius = Double(min(index * 2, 12))
        return CGSize(
            width: cos(angle) * radius,
            height: sin(angle) * radius
        )
    }
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [stoneColor, stoneColor.opacity(0.6)],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 10
                )
            )
            .frame(width: 12, height: 12)
            .shadow(color: .black.opacity(0.4), radius: 1, x: 1, y: 1)
            .offset(offset)
    }
}

struct PitView: View {
    let count: Int
    let color: Color
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // The Carved Pit
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.black.opacity(0.6), Color(red: 0.2, green: 0.1, blue: 0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .frame(width: 55, height: 55)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
                            .padding(-1)
                    )
                
                // The Stones
                ZStack {
                    ForEach(0..<count, id: \.self) { i in
                        StoneView(index: i)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: count)
                
                // Count Overlay (Small and subtle)
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.white.opacity(0.3))
                        .offset(y: 20)
                }
            }
        }
        .disabled(!isEnabled || count == 0)
    }
}

struct StoreView: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.custom("Georgia-Bold", size: 14))
                .foregroundStyle(.white.opacity(0.5))
            
            ZStack {
                // The Carved Store
                Capsule()
                    .fill(
                        RadialGradient(
                            colors: [Color.black.opacity(0.6), Color(red: 0.2, green: 0.1, blue: 0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 65, height: 140)
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
                            .padding(-1)
                    )
                
                // The Stones (More spread out in the store)
                ZStack {
                    ForEach(0..<count, id: \.self) { i in
                        StoneView(index: i)
                            .scaleEffect(1.2)
                            .offset(y: CGFloat((i / 4) * 4 - 20)) // Stack them slightly
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: count)
                
                // Score Overlay
                Text("\(count)")
                    .font(.custom("Georgia-Bold", size: 32))
                    .foregroundStyle(.white.opacity(0.2))
                    .shadow(color: .black, radius: 1, x: 0, y: 1)
            }
        }
    }
}

#Preview {
    MancalaView()
}
