//
//  LawCountApp.swift
//  LawCount
//
//  Created by Morris Albers on 8/21/24.
//

import SwiftUI
import SwiftData

@main
struct LawCountApp: App {
/*
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
*/
    @StateObject var cvm:CVM = CVM()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cvm)
        }
//        .modelContainer(sharedModelContainer)
    }
}
