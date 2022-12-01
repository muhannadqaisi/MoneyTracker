//
//  FoodModelView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 5/31/22.
//

import SwiftUI
import Foundation
import CoreData

class SingleLineFoodViewModel: ObservableObject
{
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var FoodsMO: MTFood
    init(FoodsMO:MTFood)
    {
        self.FoodsMO = FoodsMO
        if let name = FoodsMO.name{
            self.name = name
        }
        if let amount = FoodsMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        if let moc = self.FoodsMO.managedObjectContext
        {
            moc.performAndWait {
                self.FoodsMO.name = self.name
                self.FoodsMO.amount = NSDecimalNumber(decimal: self.amount)
                do {
                    try self.FoodsMO.managedObjectContext?.save()
                    print("Saved")
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

struct SingleLineFoodView: View
{
    @StateObject var viewModel: SingleLineFoodViewModel
    @FocusState var isInputActive: Bool

    var body: some View {
        HStack {
            TextField("New Item", text: $viewModel.name)
                .onSubmit {
                    viewModel.save()
                }
                .multilineTextAlignment(.leading)
               // .focused($isInputActive)
            Spacer()
            
            TextField("Amount...", value: $viewModel.amount, format: .currency(code: "USD"))
                .onSubmit {
                    viewModel.save()
                }
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            viewModel.save()
        }
    }
}

class LineFoodsViewModel: ObservableObject
{
    @Published var Foods: [MTFood] = []

    var contextMOC: NSManagedObjectContext
    init(moc: NSManagedObjectContext)
    {
        self.contextMOC = moc
        fetchData()
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { note in
              self.fetchData()
            }
    }
    
    func addEmptyLine()
    {
        let expense = MTFood(context: contextMOC)
        expense.amount = .zero
        expense.name = ""
        do {
            try contextMOC.save()
            print("Order saved.")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchData()
    {
        let rq = MTFood.fetchRequest()
        do {
            self.Foods = try self.contextMOC.fetch(rq)
        } catch {
            print(error)
        }
    }
}

struct LineFoodsView: View {
    @State private var showingSheet = false
    @State var isPresenting = false /// 1.

    @StateObject var viewModel: LineFoodsViewModel
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        Group{
            ForEach(viewModel.Foods) { Food in
                    SingleLineFoodView(viewModel: SingleLineFoodViewModel(FoodsMO: Food))
            }
            .onDelete(perform: deleteExpense)
            HStack{
                Button(action: {
                    viewModel.addEmptyLine()
                   }, label: {
                       Image(systemName: "plus.circle")
                           .imageScale(.medium)
                           .tint(Color.red)
            
                   })
                Text("Add food item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear(perform: loadData)
    }

    private func deleteExpense(offset: IndexSet)
    {
        withAnimation{
            offset.map{ viewModel.Foods[$0]} .forEach(viewContext.delete)
            do {
                try viewContext.save()
                print("Order saved.")
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func addExpense(name: String, amount: Decimal)
    {
            let expense = MTFood(context: viewContext)
            expense.amount = NSDecimalNumber(decimal: amount)
            expense.name = name
            do {
                try viewContext.save()
                print("Order saved.")
            } catch {
                print(error.localizedDescription)
            }
    }
    
    func loadData() {
        if viewModel.Foods.count == 0 {
            addExpense(name: "Grocories", amount: 0)
            addExpense(name: "Restaurants", amount: 0)

      }
    }
}
