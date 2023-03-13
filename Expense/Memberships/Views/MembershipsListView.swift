//
//  MembershipsListView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import SwiftUI

struct MembershipsListView: View {
    @StateObject var viewModel: MembershipsListViewModel
    var body: some View {
        Section(header: Text("Memberships").font(.title3).foregroundColor(Color("Red"))){
            ForEach(viewModel.memberships) { membership in
                let vm = MembershipsLineViewModel(membershipsMO: membership)
                MembershipsLineView(viewModel: vm)
            }
            .onDelete(perform: viewModel.deleteMembership)
            HStack{
                Button(action: {
                    viewModel.addEmptyLine()
                   }, label: {
                       Image(systemName: "plus.circle")
                           .imageScale(.medium)
                           .tint(Color("Red"))
                   })
                Text("Add membership item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear{
            viewModel.loadMembershipsData()
        }
    }
    
}
