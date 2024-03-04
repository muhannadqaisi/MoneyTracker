//
//  MoneyTrackerApp.swift
//  Shared
//
//  Created by Muhannad Qaisi on 5/20/22.
//

import SwiftUI
import SwiftData

@main
struct MoneyTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var viewModel = IncomeAndExpenseViewModel()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Income.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .modelContainer(sharedModelContainer)

    }
}
