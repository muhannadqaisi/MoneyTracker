//
//  HousingModelView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 5/31/22.
//

import Foundation
import SwiftUI
import CoreData

class SingleLineHousingViewModel: ObservableObject
{
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var HousingsMO: MTHousing
    init(HousingsMO:MTHousing)
    {
        self.HousingsMO = HousingsMO
        if let name = HousingsMO.name{
            self.name = name
        }
        if let amount = HousingsMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        if let moc = self.HousingsMO.managedObjectContext
        {
            moc.performAndWait {
                self.HousingsMO.name = self.name
                self.HousingsMO.amount = NSDecimalNumber(decimal: self.amount)
                do {
                    try self.HousingsMO.managedObjectContext?.save()
                    print("Saved")
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

struct SingleLineHousingView: View
{
    @StateObject var viewModel: SingleLineHousingViewModel
    @FocusState var isInputActive: Bool

    var body: some View {
        HStack {
            TextField("New Item", text: $viewModel.name)
                .onSubmit {
                    viewModel.save()
                }
                .multilineTextAlignment(.leading)
                //.focused($isInputActive)
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

class LineHousingsViewModel: ObservableObject
{
    @Published var Housings: [MTHousing] = []

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
        let expense = MTHousing(context: contextMOC)
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
        let rq = MTHousing.fetchRequest()
        do {
            self.Housings = try self.contextMOC.fetch(rq)
        } catch {
            print(error)
        }
    }
}

struct LineHousingsView: View {
    @State private var showingSheet = false
    @State var isPresenting = false /// 1.
    
    @StateObject var viewModel: LineHousingsViewModel
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        Group{
            ForEach(viewModel.Housings) { Housing in
                    SingleLineHousingView(viewModel: SingleLineHousingViewModel(HousingsMO: Housing))
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
                Text("Add housing item")
                    .foregroundColor(Color.gray)
            }
            
            
        }
        .onAppear(perform: loadData)
    }

    private func deleteExpense(offset: IndexSet)
    {
        withAnimation{
            offset.map{ viewModel.Housings[$0]} .forEach(viewContext.delete)
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
            let expense = MTHousing(context: viewContext)
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
        if viewModel.Housings.count == 0 {
            addExpense(name: "Mortgage/Rent", amount: 0)
            addExpense(name: "Electricity", amount: 0)
            addExpense(name: "Gas", amount: 0)
            addExpense(name: "Water", amount: 0)
            addExpense(name: "Internet", amount: 0)

      }
    }
}
