//
//  FoodsLineViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import SwiftUI
import CoreData

class FoodsLineViewModel: ObservableObject {
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var foodsMO: MTFood
    init(foodsMO: MTFood)
    {
        self.foodsMO = foodsMO
        if let name = foodsMO.name{
            self.name = name
        }
        if let amount = foodsMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        
        self.foodsMO.managedObjectContext?.performAndWait {
            self.foodsMO.name = self.name
            self.foodsMO.amount = NSDecimalNumber(decimal: self.amount)
            do {
                try self.foodsMO.managedObjectContext?.save()
                print("Saved")
            } catch {
                print(error)
            }
        }
    }
}
