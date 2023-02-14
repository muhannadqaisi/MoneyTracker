//
//  InsuranceLineViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import SwiftUI
import CoreData

class InsuranceLineViewModel: ObservableObject {
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var InsuranceMO: MTInsurance
    init(InsuranceMO: MTInsurance)
    {
        self.InsuranceMO = InsuranceMO
        if let name = InsuranceMO.name{
            self.name = name
        }
        if let amount = InsuranceMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        
        self.InsuranceMO.managedObjectContext?.performAndWait {
            self.InsuranceMO.name = self.name
            self.InsuranceMO.amount = NSDecimalNumber(decimal: self.amount)
            do {
                try self.InsuranceMO.managedObjectContext?.save()
                print("Saved")
            } catch {
                print(error)
            }
        }
    }
}
