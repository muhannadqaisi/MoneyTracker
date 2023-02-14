//
//  InsuranceListViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import CoreData
import SwiftUI

class InsuranceListViewModel: ObservableObject{
    @Published var insurance: [MTInsurance] = []

    var moc: NSManagedObjectContext
    init(moc: NSManagedObjectContext)
    {
        self.moc = moc
        fetchInsurance()
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { note in
              self.fetchInsurance()
            }
    }
    
    func addEmptyLine()
    {
        let expense = MTInsurance(context: moc)
        expense.amount = .zero
        expense.name = ""
        do {
            try self.moc.save()
            print("Saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchInsurance()
    {
        let rq = MTInsurance.fetchRequest()
        do {
            
            let results = try self.moc.fetch(rq)
            self.insurance = results
            
        } catch {
            debugPrint(error)
        }
    }
    
    func deleteInsurance(offset: IndexSet)
    {
        withAnimation{
            offset.map{ self.insurance[$0]} .forEach(self.moc.delete)
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addInsurance(name: String, amount: Decimal)
    {
            let expense = MTInsurance(context: self.moc)
            expense.amount = NSDecimalNumber(decimal: amount)
            expense.name = name
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
    }
    func loadInsuranceData() {
        if self.insurance.count == 0 {
            addInsurance(name: "Health Insurance", amount: 0)
            addInsurance(name: "Car Insurance", amount: 0)
            addInsurance(name: "Home Insurance", amount: 0)
            addInsurance(name: "Life Insurance", amount: 0)
      }
    }
    
}
