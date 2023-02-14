//
//  HousingLineViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import SwiftUI
import CoreData

class HousingLineViewModel: ObservableObject {
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var housingMO: MTHousing
    init(housingMO: MTHousing)
    {
        self.housingMO = housingMO
        if let name = housingMO.name{
            self.name = name
        }
        if let amount = housingMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        
        self.housingMO.managedObjectContext?.performAndWait {
            self.housingMO.name = self.name
            self.housingMO.amount = NSDecimalNumber(decimal: self.amount)
            do {
                try self.housingMO.managedObjectContext?.save()
                print("Saved")
            } catch {
                print(error)
            }
        }
    }
}
