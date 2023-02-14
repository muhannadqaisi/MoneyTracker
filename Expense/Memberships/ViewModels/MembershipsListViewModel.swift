//
//  MembershipsListViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import CoreData
import SwiftUI

class MembershipsListViewModel: ObservableObject{
    @Published var memberships: [MTMembership] = []

    var moc: NSManagedObjectContext
    init(moc: NSManagedObjectContext)
    {
        self.moc = moc
        fetchMemberships()
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { note in
              self.fetchMemberships()
            }
    }
    
    func addEmptyLine()
    {
        let expense = MTMembership(context: moc)
        expense.amount = .zero
        expense.name = ""
        do {
            try self.moc.save()
            print("Saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchMemberships()
    {
        let rq = MTMembership.fetchRequest()
        do {
            
            let results = try self.moc.fetch(rq)
            self.memberships = results
            
        } catch {
            debugPrint(error)
        }
    }
    
    func deleteMembership(offset: IndexSet)
    {
        withAnimation{
            offset.map{ self.memberships[$0]} .forEach(self.moc.delete)
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addMembership(name: String, amount: Decimal)
    {
            let expense = MTMembership(context: self.moc)
            expense.amount = NSDecimalNumber(decimal: amount)
            expense.name = name
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
    }
    func loadMembershipsData() {
        if self.memberships.count == 0 {
            addMembership(name: "Gym Membership", amount: 0)
            addMembership(name: "Music Membership", amount: 0)
            addMembership(name: "TV Membership", amount: 0)
            addMembership(name: "Gaming Membership", amount: 0)
      }
    }
    
}
