//
//  MoneyTrackerApp.swift
//  Shared
//
//  Created by Muhannad Qaisi on 5/20/22.
//

import SwiftUI

@main
struct MoneyTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var viewModel = IncomeAndExpenseViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
