//
//  IncomeListView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/13/23.
//

import SwiftUI

struct IncomeListView: View {
    @StateObject var viewModel: IncomeListViewModel
    var body: some View {
        Section("Income"){
            ForEach(viewModel.Incomes) { income in
                let vm = IncomeLineViewModel(IncomesMO: income)
                IncomeLineView(viewModel: vm)
            }
            .onDelete(perform: viewModel.deleteExpense)
            HStack{
                Button(action: {
                    viewModel.addEmptyLine()
                   }, label: {
                       Image(systemName: "plus.circle")
                           .imageScale(.medium)
                           .tint(Color.green)

                   })
                Text("Add incomes item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear{
            viewModel.loadData()
        }
    }
    
}

