//
//  SavingsListView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import SwiftUI

struct SavingsListView: View {
    @StateObject var viewModel: SavingsListViewModel
    var body: some View {
        Section(header: Text("Savings").font(.title3)){
            ForEach(viewModel.savings) { saving in
                let vm = SavingsLineViewModel(savingsMO: saving)
                SavingsLineView(viewModel: vm)
            }
            .onDelete(perform: viewModel.deleteSavings)
            HStack{
                Button(action: {
                    viewModel.addEmptyLine()
                   }, label: {
                       Image(systemName: "plus.circle")
                           .imageScale(.medium)
                           .tint(Color.green)

                   })
                Text("Add saving item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear{
            viewModel.loadSavingsData()
        }
    }
    
}
