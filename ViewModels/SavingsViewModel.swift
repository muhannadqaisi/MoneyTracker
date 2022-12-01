//
//  SavingsModelView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 5/31/22.
//

import SwiftUI
import Foundation
import CoreData

class SingleLineSavingViewModel: ObservableObject
{
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var savingsMO: MTSavings
    init(savingsMO:MTSavings)
    {
        self.savingsMO = savingsMO
        if let name = savingsMO.name{
            self.name = name
        }
        if let amount = savingsMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        if let moc = self.savingsMO.managedObjectContext
        {
            moc.performAndWait {
                self.savingsMO.name = self.name
                self.savingsMO.amount = NSDecimalNumber(decimal: self.amount)
                do {
                    try self.savingsMO.managedObjectContext?.save()
                    print("Saved")
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

struct SingleLineSavingView: View
{
    @StateObject var viewModel: SingleLineSavingViewModel
    @FocusState var isInputActive: Bool

    var body: some View {
        HStack {
            TextField("New Item", text: $viewModel.name)
                .onSubmit {
                    viewModel.save()
                }
                .multilineTextAlignment(.leading)
                .focused($isInputActive)
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


class LineSavingsViewModel: ObservableObject
{
    @Published var savings: [MTSavings] = []

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
        let expense = MTSavings(context: contextMOC)
        expense.amount = .zero
        expense.name = ""
        do {
            try contextMOC.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchData()
    {
        let rq = MTSavings.fetchRequest()
        do {
            self.savings = try self.contextMOC.fetch(rq)
        } catch {
            print(error)
        }
    }
}

struct LineSavingsView: View {
    @State private var showingSheet = false
    @State var isPresenting = false /// 1.
    
    @StateObject var viewModel: LineSavingsViewModel
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        Group{
            ForEach(viewModel.savings) { saving in
                    SingleLineSavingView(viewModel: SingleLineSavingViewModel(savingsMO: saving))
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
                Text("Add saving item")
                    .foregroundColor(Color.gray)
            }
            
        }
        .onAppear(perform: loadData)
    }

    private func deleteExpense(offset: IndexSet)
    {
        withAnimation{
            offset.map{ viewModel.savings[$0]} .forEach(viewContext.delete)
            do {
                try viewContext.save()
                print("Deleted and saved.")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addExpense(name: String, amount: Decimal)
    {
            let expense = MTSavings(context: viewContext)
            expense.amount = NSDecimalNumber(decimal: amount)
            expense.name = name
            do {
                try viewContext.save()
                print("Added Expense")
            } catch {
                print(error.localizedDescription)
            }
    }
    func loadData() {
        if viewModel.savings.count == 0 {
            addExpense(name: "Emergency Fund", amount: 0)
            addExpense(name: "Other Savings", amount: 0)
      }
    }

}

