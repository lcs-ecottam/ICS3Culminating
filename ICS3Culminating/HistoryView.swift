import SwiftUI
import SwiftData

struct HistoryView: View {
    // MARK: - Stored properties
    
    @Query(sort: \GameHistory.date, order: .reverse) var games: [GameHistory]
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                if games.isEmpty {
                    ContentUnavailableView("No Games Yet", systemImage: "clock.arrow.circlepath", description: Text("Play a match of Mancala to see your history here!"))
                } else {
                    ForEach(games) { game in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(game.winnerName + " Won!")
                                    .font(.headline)
                                Spacer()
                                Text(game.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Label("\(game.playerOneScore)", systemImage: "person.fill")
                                    .foregroundStyle(.blue)
                                Spacer()
                                Text("vs")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Label("\(game.playerTwoScore)", systemImage: game.isVsCPU ? "cpu" : "person.2.fill")
                                    .foregroundStyle(.red)
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteGames)
                }
            }
            .navigationTitle("Game History")
            .toolbar {
                if !games.isEmpty {
                    EditButton()
                }
            }
        }
    }
    
    // MARK: - Functions
    
    private func deleteGames(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(games[index])
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: GameHistory.self, inMemory: true)
}
