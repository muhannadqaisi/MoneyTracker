//
//  IncomeAndExpenseViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/13/23.
//

import Foundation
import CoreData

class IncomeAndExpenseViewModel: ObservableObject{
    @Published var Incomes: [MTIncome] = []
    @Published var savings: [MTSavings] = []
    @Published var housing: [MTHousing] = []
    @Published var personal: [MTPersonal] = []
    @Published var trans: [MTTransportation] = []
    @Published var food: [MTFood] = []
    @Published var insurance: [MTInsurance] = []
    @Published var memberships: [MTMembership] = []

    var moc: NSManagedObjectContext
    init()
    {
        self.moc = PersistenceController.shared.container.viewContext
        fetchData()
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { note in
              self.fetchData()
            }
    }
    func fetchData()
    {
        let incomeRq = MTIncome.fetchRequest()
        let savingRq = MTSavings.fetchRequest()
        let housingRq = MTHousing.fetchRequest()
        let personalRq = MTPersonal.fetchRequest()
        let transRq = MTTransportation.fetchRequest()
        let foodRq = MTFood.fetchRequest()
        let insuranceRq = MTInsurance.fetchRequest()
        let membershipsRq = MTMembership.fetchRequest()

        do {
            
            let incomeResult = try self.moc.fetch(incomeRq)
            self.Incomes = incomeResult
            let savingsResults = try self.moc.fetch(savingRq)
            self.savings = savingsResults
            let housingResults = try self.moc.fetch(housingRq)
            self.housing = housingResults
            let personalResults = try self.moc.fetch(personalRq)
            self.personal = personalResults
            let transResults = try self.moc.fetch(transRq)
            self.trans = transResults
            let foodResults = try self.moc.fetch(foodRq)
            self.food = foodResults
            let InsuranceResults = try self.moc.fetch(insuranceRq)
            self.insurance = InsuranceResults
            let membershipsResults = try self.moc.fetch(membershipsRq)
            self.memberships = membershipsResults

            
            
        } catch {
            debugPrint(error)
        }
    }
    
    func total() -> Int {
        var totalToday: Int = 0
        for item in Incomes {
            totalToday += item.amount!.intValue
        }
        return totalToday
    }
    
    func totalExpense() -> Int {
        var totalToday: Int = 0
        for item in savings {
            totalToday += item.amount!.intValue
        }
        for item2 in housing {
            totalToday += item2.amount!.intValue
        }
        for item3 in trans {
            totalToday += item3.amount!.intValue
        }
        for item4 in food {
            totalToday += item4.amount!.intValue
        }
        for item5 in personal {
            totalToday += item5.amount!.intValue
        }
        for item6 in insurance {
            totalToday += item6.amount!.intValue
        }
        for item7 in memberships {
            totalToday += item7.amount!.intValue
        }
        return totalToday
    }
}
