//
//  IncomeViewModel2.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/13/23.
//

import Foundation
import SwiftUI
import CoreData

class IncomeListViewModel: ObservableObject{
    @Published var Incomes: [MTIncome] = []

    var moc: NSManagedObjectContext
    init(moc: NSManagedObjectContext)
    {
        self.moc = moc
        fetchIncome()
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { note in
              self.fetchIncome()
            }
    }
    
    func addEmptyLine()
    {
        let expense = MTIncome(context: moc)
        expense.amount = .zero
        expense.name = ""
        do {
            try self.moc.save()
            print("Saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchIncome()
    {
        let rq = MTIncome.fetchRequest()
        do {
            
            let results = try self.moc.fetch(rq)
            self.Incomes = results
            
        } catch {
            debugPrint(error)
        }
    }
    func deleteIncome(offset: IndexSet)
    {
        withAnimation{
            offset.map{ self.Incomes[$0]} .forEach(self.moc.delete)
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addIncome(name: String, amount: Decimal)
    {
            let expense = MTIncome(context: self.moc)
            expense.amount = NSDecimalNumber(decimal: amount)
            expense.name = name
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
    }
    func loadIncomeData() {
        print(self.Incomes.count)
        if self.Incomes.count == 0 {
            addIncome(name: "Paycheck", amount: 0)
            addIncome(name: "Paycheck", amount: 0)
      }
    }
    
}
