//
//  PersonalViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 5/31/22.
//

import SwiftUI
import Foundation
import CoreData

class SingleLinePersonalViewModel: ObservableObject
{
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var PersonalsMO: MTPersonal
    init(PersonalsMO:MTPersonal)
    {
        self.PersonalsMO = PersonalsMO
        if let name = PersonalsMO.name{
            self.name = name
        }
        if let amount = PersonalsMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        if let moc = self.PersonalsMO.managedObjectContext
        {
            moc.performAndWait {
                self.PersonalsMO.name = self.name
                self.PersonalsMO.amount = NSDecimalNumber(decimal: self.amount)
                do {
                    try self.PersonalsMO.managedObjectContext?.save()
                    print("Saved")
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

struct SingleLinePersonalView: View
{
    @StateObject var viewModel: SingleLinePersonalViewModel
    @FocusState var isInputActive: Bool

    var body: some View {
        HStack {
            TextField("New Item", text: $viewModel.name)
                .onSubmit {
                    viewModel.save()
                }
                .multilineTextAlignment(.leading)
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

class LinePersonalsViewModel: ObservableObject
{
    @Published var Personals: [MTPersonal] = []

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
        let expense = MTPersonal(context: contextMOC)
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
        let rq = MTPersonal.fetchRequest()
        do {
            self.Personals = try self.contextMOC.fetch(rq)
        } catch {
            print(error)
        }
    }
}

struct LinePersonalsView: View {
    @State private var showingSheet = false
    @State var isPresenting = false /// 1.
    
    @StateObject var viewModel: LinePersonalsViewModel
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        Group{
            ForEach(viewModel.Personals) { Personal in
                    SingleLinePersonalView(viewModel: SingleLinePersonalViewModel(PersonalsMO: Personal))
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
                Text("Add personal item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear(perform: loadData)
    }

    private func deleteExpense(offset: IndexSet)
    {
        withAnimation{
            offset.map{ viewModel.Personals[$0]} .forEach(viewContext.delete)
            do {
                try viewContext.save()
                print("Expense saved.")
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func addExpense(name: String, amount: Decimal)
    {
            let expense = MTPersonal(context: viewContext)
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
        if viewModel.Personals.count == 0 {
            addExpense(name: "Clothing", amount: 0)
            addExpense(name: "Entertainment", amount: 0)
            addExpense(name: "Fun Money", amount: 0)
            addExpense(name: "Cosmetics/Hair", amount: 0)
      }
    }
    
}
