//
//  PersonalLineViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import SwiftUI
import CoreData

class PersonalLineViewModel: ObservableObject {
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var personalMO: MTPersonal
    init(personalMO: MTPersonal)
    {
        self.personalMO = personalMO
        if let name = personalMO.name{
            self.name = name
        }
        if let amount = personalMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        
        self.personalMO.managedObjectContext?.performAndWait {
            self.personalMO.name = self.name
            self.personalMO.amount = NSDecimalNumber(decimal: self.amount)
            do {
                try self.personalMO.managedObjectContext?.save()
                print("Saved")
            } catch {
                print(error)
            }
        }
    }
}
