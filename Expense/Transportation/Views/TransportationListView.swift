//
//  TransportationListView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import SwiftUI

struct TransportationListView: View {
    @StateObject var viewModel: TransportationListViewModel
    var body: some View {
        Section(header: Text("Transportation").font(.title3)){
            ForEach(viewModel.transportation) { transportation in
                let vm = TransportationLineViewModel(transportationMO: transportation)
                TransportationLineView(viewModel: vm)
            }
            .onDelete(perform: viewModel.deleteTransportation)
            HStack{
                Button(action: {
                    viewModel.addEmptyLine()
                   }, label: {
                       Image(systemName: "plus.circle")
                           .imageScale(.medium)
                           .tint(Color.green)

                   })
                Text("Add Transportation item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear{
            viewModel.loadTransportationData()
        }
    }
    
}
