//
//  FoodsListView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import SwiftUI

struct FoodsListView: View {
    @StateObject var viewModel: FoodsListViewModel
    var body: some View {
        Section(header: Text("Food").font(.title3).foregroundColor(Color("Red"))){
            ForEach(viewModel.foods) { food in
                let vm = FoodsLineViewModel(foodsMO: food)
                FoodsLineView(viewModel: vm)
            }
            .onDelete(perform: viewModel.deleteFood)
            HStack{
                Button(action: {
                    viewModel.addEmptyLine()
                   }, label: {
                       Image(systemName: "plus.circle")
                           .imageScale(.medium)
                           .tint(Color("Red"))

                   })
                Text("Add food item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear{
            viewModel.loadFoodData()
        }
    }
    
}
