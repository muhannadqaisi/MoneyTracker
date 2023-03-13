//
//  PersonalListView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import SwiftUI

struct PersonalListView: View {
    @StateObject var viewModel: PersonalListViewModel
    var body: some View {
        Section(header: Text("Personal").font(.title3).foregroundColor(Color("Red"))){
            ForEach(viewModel.personal) { personal in
                let vm = PersonalLineViewModel(personalMO: personal)
                PersonalLineView(viewModel: vm)
            }
            .onDelete(perform: viewModel.deletePersonal)
            HStack{
                Button(action: {
                    viewModel.addEmptyLine()
                   }, label: {
                       Image(systemName: "plus.circle")
                           .imageScale(.medium)
                           .tint(Color("Red"))

                   })
                Text("Add Transportation item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear{
            viewModel.loadPersonalData()
        }
    }
    
}
