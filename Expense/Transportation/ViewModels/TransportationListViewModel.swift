//
//  TransportationListViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import CoreData
import SwiftUI

class TransportationListViewModel: ObservableObject{
    @Published var transportation: [MTTransportation] = []

    var moc: NSManagedObjectContext
    init(moc: NSManagedObjectContext)
    {
        self.moc = moc
        fetchTransportation()
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { note in
              self.fetchTransportation()
            }
    }
    
    func addEmptyLine()
    {
        let expense = MTTransportation(context: moc)
        expense.amount = .zero
        expense.name = ""
        do {
            try self.moc.save()
            print("Saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchTransportation()
    {
        let rq = MTTransportation.fetchRequest()
        do {
            
            let results = try self.moc.fetch(rq)
            self.transportation = results
            
        } catch {
            debugPrint(error)
        }
    }
    func deleteTransportation(offset: IndexSet)
    {
        withAnimation{
            offset.map{ self.transportation[$0]} .forEach(self.moc.delete)
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addTransportation(name: String, amount: Decimal)
    {
            let expense = MTTransportation(context: self.moc)
            expense.amount = NSDecimalNumber(decimal: amount)
            expense.name = name
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
    }
    func loadTransportationData() {
        if self.transportation.count == 0 {
            addTransportation(name: "Car Payments ", amount: 0)
            addTransportation(name: "Gas", amount: 0)
            addTransportation(name: "Maintenance ", amount: 0)
      }
    }
    
}
