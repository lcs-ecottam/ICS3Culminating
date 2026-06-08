import SwiftUI
import SwiftData

struct MainTabView: View {
    // MARK: - Stored properties
    
    // MARK: - Body
    
    var body: some View {
        TabView {
            MancalaView()
                .tabItem {
                    Label("Game", systemImage: "gamecontroller")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: GameHistory.self, inMemory: true)
}
