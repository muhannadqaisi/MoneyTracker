//
//  SavingsListViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import CoreData
import SwiftUI

class SavingsListViewModel: ObservableObject{
    @Published var savings: [MTSavings] = []

    var moc: NSManagedObjectContext
    init(moc: NSManagedObjectContext)
    {
        self.moc = moc
        fetchSavings()
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { note in
              self.fetchSavings()
            }
    }
    
    func addEmptyLine()
    {
        let expense = MTSavings(context: moc)
        expense.amount = .zero
        expense.name = ""
        do {
            try self.moc.save()
            print("Saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchSavings()
    {
        let rq = MTSavings.fetchRequest()
        do {
            
            let results = try self.moc.fetch(rq)
            self.savings = results
            
        } catch {
            debugPrint(error)
        }
    }
    func deleteSavings(offset: IndexSet)
    {
        withAnimation{
            offset.map{ self.savings[$0]} .forEach(self.moc.delete)
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addSavings(name: String, amount: Decimal)
    {
            let expense = MTSavings(context: self.moc)
            expense.amount = NSDecimalNumber(decimal: amount)
            expense.name = name
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
    }
    func loadSavingsData() {
        if self.savings.count == 0 {
            addSavings(name: "Emergency Fund", amount: 0)
            addSavings(name: "Other Savings", amount: 0)
      }
    }
    
}
