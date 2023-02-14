//
//  TransportationLineViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import SwiftUI
import CoreData

class TransportationLineViewModel: ObservableObject {
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var transportationMO: MTTransportation
    init(transportationMO: MTTransportation)
    {
        self.transportationMO = transportationMO
        if let name = transportationMO.name{
            self.name = name
        }
        if let amount = transportationMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        
        self.transportationMO.managedObjectContext?.performAndWait {
            self.transportationMO.name = self.name
            self.transportationMO.amount = NSDecimalNumber(decimal: self.amount)
            do {
                try self.transportationMO.managedObjectContext?.save()
                print("Saved")
            } catch {
                print(error)
            }
        }
    }
}
