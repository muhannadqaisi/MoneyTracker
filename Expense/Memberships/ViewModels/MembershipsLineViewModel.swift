//
//  MembershipsLineViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import SwiftUI
import CoreData

class MembershipsLineViewModel: ObservableObject {
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var membershipsMO: MTMembership
    init(membershipsMO: MTMembership)
    {
        self.membershipsMO = membershipsMO
        if let name = membershipsMO.name{
            self.name = name
        }
        if let amount = membershipsMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        
        self.membershipsMO.managedObjectContext?.performAndWait {
            self.membershipsMO.name = self.name
            self.membershipsMO.amount = NSDecimalNumber(decimal: self.amount)
            do {
                try self.membershipsMO.managedObjectContext?.save()
                print("Saved")
            } catch {
                print(error)
            }
        }
    }
}
