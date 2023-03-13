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
        Section(header: Text("Income").font(.title3).foregroundColor(Color("Green"))){
            ForEach(viewModel.Incomes) { income in
                let vm = IncomeLineViewModel(IncomesMO: income)
                IncomeLineView(viewModel: vm)
            }
            .onDelete(perform: viewModel.deleteIncome)
            HStack{
                Button(action: {
                    viewModel.addEmptyLine()
                   }, label: {
                       Image(systemName: "plus.circle")
                           .imageScale(.medium)
                           .tint(Color("Green"))

                   })
                Text("Add incomes item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear{
            viewModel.loadIncomeData()
        }
    }
    
}


