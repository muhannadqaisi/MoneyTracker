//
//  InsuranceListView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import SwiftUI

struct InsuranceListView: View {
    @StateObject var viewModel: InsuranceListViewModel
    var body: some View {
        Section(header: Text("Insurance").font(.title3)){
            ForEach(viewModel.insurance) { Insurance in
                let vm = InsuranceLineViewModel(InsuranceMO: Insurance)
                InsuranceLineView(viewModel: vm)
            }
            .onDelete(perform: viewModel.deleteInsurance)
            HStack{
                Button(action: {
                    viewModel.addEmptyLine()
                   }, label: {
                       Image(systemName: "plus.circle")
                           .imageScale(.medium)
                           .tint(Color.green)

                   })
                Text("Add insurance item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear{
            viewModel.loadInsuranceData()
        }
    }
    
}
