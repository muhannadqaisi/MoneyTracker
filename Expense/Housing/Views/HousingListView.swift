//
//  HousingListView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import SwiftUI

struct HousingListView: View {
    @StateObject var viewModel: HousingListViewModel
    var body: some View {
        Section(header: Text("Housing").font(.title3).foregroundColor(Color("Red"))){
            ForEach(viewModel.housings) { housing in
                let vm = HousingLineViewModel(housingMO: housing)
                HousingLineView(viewModel: vm)
            }
            .onDelete(perform: viewModel.deleteHousing)
            HStack{
                Button(action: {
                    viewModel.addEmptyLine()
                   }, label: {
                       Image(systemName: "plus.circle")
                           .imageScale(.medium)
                           .tint(Color("Red"))

                   })
                Text("Add housing item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear{
            viewModel.loadHousingData()
        }
    }
    
}
