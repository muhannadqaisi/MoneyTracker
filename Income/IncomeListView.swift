//
//  IncomeListView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/13/23.
//

import SwiftUI
import SwiftData

struct IncomeListView: View {

    @Environment(\.modelContext) private var modelContext

    @Query var incomes: [Income] = []
    
    var body: some View {
        Section(header: Text("Income").font(.title3).foregroundColor(Color.green)){
            ForEach(incomes) { income in
                IncomeLineView(income: income)
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            self.modelContext.delete(income)

                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                
            }

            HStack{
                Button(action: {
                    let income = Income()
                    self.modelContext.insert(income)
                    try? self.modelContext.save()

                   }, label: {
                       Image(systemName: "plus.circle")
                           .imageScale(.medium)
                           .tint(Color.green)

                   })
                Text("Add income item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear{
            self.loadIncomeData()
        }
    }
    
    func addIncome() {
        let income = Income()
        self.modelContext.insert(income)
        try? self.modelContext.save()
    }
    func loadIncomeData() {
        if incomes.count == 0 {
            addIncome()
            addIncome()
      }
    }
}

