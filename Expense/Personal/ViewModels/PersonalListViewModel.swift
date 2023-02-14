//
//  PersonalListViewMode.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import CoreData
import SwiftUI

class PersonalListViewModel: ObservableObject{
    @Published var personal: [MTPersonal] = []

    var moc: NSManagedObjectContext
    init(moc: NSManagedObjectContext)
    {
        self.moc = moc
        fetchPeronal()
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { note in
              self.fetchPeronal()
            }
    }
    
    func addEmptyLine()
    {
        let expense = MTPersonal(context: moc)
        expense.amount = .zero
        expense.name = ""
        do {
            try self.moc.save()
            print("Saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchPeronal()
    {
        let rq = MTPersonal.fetchRequest()
        do {
            
            let results = try self.moc.fetch(rq)
            self.personal = results
            
        } catch {
            debugPrint(error)
        }
    }
    
    func deletePersonal(offset: IndexSet)
    {
        withAnimation{
            offset.map{ self.personal[$0]} .forEach(self.moc.delete)
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addPersonal(name: String, amount: Decimal)
    {
            let expense = MTPersonal(context: self.moc)
            expense.amount = NSDecimalNumber(decimal: amount)
            expense.name = name
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
    }
    func loadPersonalData() {
        if self.personal.count == 0 {
            addPersonal(name: "Clothing", amount: 0)
            addPersonal(name: "Entertainment", amount: 0)
            addPersonal(name: "Fun Money", amount: 0)
            addPersonal(name: "Cosmetics/Hair", amount: 0)
      }
    }
    
}
