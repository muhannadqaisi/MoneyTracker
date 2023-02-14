//
//  FoodsListViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import Foundation
import CoreData
import SwiftUI

class FoodsListViewModel: ObservableObject{
    @Published var foods: [MTFood] = []

    var moc: NSManagedObjectContext
    init(moc: NSManagedObjectContext)
    {
        self.moc = moc
        fetchFoods()
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { note in
              self.fetchFoods()
            }
    }
    
    func addEmptyLine()
    {
        let expense = MTFood(context: moc)
        expense.amount = .zero
        expense.name = ""
        do {
            try self.moc.save()
            print("Saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchFoods()
    {
        let rq = MTFood.fetchRequest()
        do {
            
            let results = try self.moc.fetch(rq)
            self.foods = results
            
        } catch {
            debugPrint(error)
        }
    }
    func deleteFood(offset: IndexSet)
    {
        withAnimation{
            offset.map{ self.foods[$0]} .forEach(self.moc.delete)
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addFood(name: String, amount: Decimal)
    {
            let expense = MTFood(context: self.moc)
            expense.amount = NSDecimalNumber(decimal: amount)
            expense.name = name
            do {
                try self.moc.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
    }
    func loadFoodData() {
        if self.foods.count == 0 {
            addFood(name: "Grocories", amount: 0)
            addFood(name: "Restaurants", amount: 0)

      }
    }
    
}
