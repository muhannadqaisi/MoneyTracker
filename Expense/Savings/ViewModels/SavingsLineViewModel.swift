//
//  SavingsLineViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import SwiftUI
import CoreData

class SavingsLineViewModel: ObservableObject {
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var savingsMO: MTSavings
    init(savingsMO: MTSavings)
    {
        self.savingsMO = savingsMO
        if let name = savingsMO.name{
            self.name = name
        }
        if let amount = savingsMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        
        self.savingsMO.managedObjectContext?.performAndWait {
            self.savingsMO.name = self.name
            self.savingsMO.amount = NSDecimalNumber(decimal: self.amount)
            do {
                try self.savingsMO.managedObjectContext?.save()
                print("Saved")
            } catch {
                print(error)
            }
        }
    }
}
