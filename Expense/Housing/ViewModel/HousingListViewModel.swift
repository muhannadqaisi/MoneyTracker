//
//  HousingListViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import CoreData
import SwiftUI

class HousingListViewModel: ObservableObject{
    @Published var housings: [MTHousing] = []

    var moc: NSManagedObjectContext
    init(moc: NSManagedObjectContext)
    {
        self.moc = moc
        fetchHousings()
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { note in
              self.fetchHousings()
            }
    }
    
    func addEmptyLine()
    {
        let expense = MTHousing(context: moc)
        expense.amount = .zero
        expense.name = ""
        do {
            try self.moc.save()
            print("Saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchHousings()
    {
        let rq = MTHousing.fetchRequest()
        do {
            
            let results = try self.moc.fetch(rq)
            self.housings = results
            
        } catch {
            debugPrint(error)
        }
    }
    func deleteHousing(offset: IndexSet)
    {
        withAnimation{
            offset.map{ self.housings[$0]} .forEach(self.moc.delete)
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addHousing(name: String, amount: Decimal)
    {
            let expense = MTHousing(context: self.moc)
            expense.amount = NSDecimalNumber(decimal: amount)
            expense.name = name
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
    }
    func loadHousingData() {
        if self.housings.count == 0 {
            addHousing(name: "Mortgage/Rent", amount: 0)
            addHousing(name: "Electricity", amount: 0)
            addHousing(name: "Gas", amount: 0)
            addHousing(name: "Water", amount: 0)
            addHousing(name: "Internet", amount: 0)

      }
    }
    
}
