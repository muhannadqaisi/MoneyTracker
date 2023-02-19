//
//  IncomeLineViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/13/23.
//

import Foundation
import SwiftUI
import CoreData

class IncomeLineViewModel: ObservableObject {
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var IncomesMO: MTIncome
    init(IncomesMO: MTIncome)
    {
        self.IncomesMO = IncomesMO
        if let name = IncomesMO.name{
            self.name = name
        }
        if let amount = IncomesMO.amount{
            self.amount = amount as Decimal
        }
        NotificationCenter.default.addObserver(forName: Notification.Name("Save"), object: self, queue: nil) { note in
            self.save()
        }
    }
    
    func save()
    {
        
        self.IncomesMO.managedObjectContext?.performAndWait {
            self.IncomesMO.name = self.name
            self.IncomesMO.amount = NSDecimalNumber(decimal: self.amount)
            do {
                try self.IncomesMO.managedObjectContext?.save()
                print("Saved")
            } catch {
                print(error)
            }
        }
    }
}
