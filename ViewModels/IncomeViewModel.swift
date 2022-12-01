//
//  IncomeViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 5/31/22.
//
import SwiftUI
import Foundation
import CoreData

class SingleLineIncomeViewModel: ObservableObject
{
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var IncomesMO: MTIncome
    init(IncomesMO:MTIncome)
    {
        self.IncomesMO = IncomesMO
        if let name = IncomesMO.name{
            self.name = name
        }
        if let amount = IncomesMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        if let moc = self.IncomesMO.managedObjectContext
        {
            moc.performAndWait {
                self.IncomesMO.name = self.name
                self.IncomesMO.amount = NSDecimalNumber(decimal: self.amount)
                do {
                    try self.IncomesMO.managedObjectContext?.save()
                    print("Saved")
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

struct SingleLineIncomeView: View
{
    @StateObject var viewModel: SingleLineIncomeViewModel
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


class LineIncomesViewModel: ObservableObject
{
    @Published var Incomes: [MTIncome] = []

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
        let expense = MTIncome(context: contextMOC)
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
        let rq = MTIncome.fetchRequest()
        do {
            self.Incomes = try self.contextMOC.fetch(rq)
        } catch {
            print(error)
        }
    }
}

struct LineIncomesView: View {
    @State private var showingSheet = false
    @State var isPresenting = false /// 1.
    
    @ObservedObject var viewModel: LineIncomesViewModel
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        Group{
            ForEach(viewModel.Incomes) { Income in
                    SingleLineIncomeView(viewModel: SingleLineIncomeViewModel(IncomesMO: Income))
            }
            .onDelete(perform: deleteExpense)
            HStack{
                Button(action: {
                    viewModel.addEmptyLine()
                   }, label: {
                       Image(systemName: "plus.circle")
                           .imageScale(.medium)
                           .tint(Color.green)

                   })
                Text("Add incomes item")
                    .foregroundColor(Color.gray)
            }
            
        }
        .onAppear(perform: loadData)
        
    }

    private func deleteExpense(offset: IndexSet)
    {
        withAnimation{
            offset.map{ viewModel.Incomes[$0]} .forEach(viewContext.delete)
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
            let expense = MTIncome(context: viewContext)
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
        print($viewModel.Incomes.count)
        if viewModel.Incomes.count == 0 {
            addExpense(name: "Paycheck", amount: 0)
            addExpense(name: "Paycheck", amount: 0)
      }
    }

}

