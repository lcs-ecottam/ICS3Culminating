//
//  ICS3CulminatingApp.swift
//  ICS3Culminating
//
//  Created by Ella Seville-Cottam on 2026-06-01.
//

import SwiftUI
import SwiftData

@main
struct ICS3CulminatingApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: GameHistory.self)
    }
}



