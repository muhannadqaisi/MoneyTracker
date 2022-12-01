//
//  InsuranceViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 6/1/22.
//

import SwiftUI
import Foundation
import CoreData

class SingleLineInsuranceViewModel: ObservableObject
{
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var InsurancesMO: MTInsurance
    init(InsurancesMO:MTInsurance)
    {
        self.InsurancesMO = InsurancesMO
        if let name = InsurancesMO.name{
            self.name = name
        }
        if let amount = InsurancesMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        if let moc = self.InsurancesMO.managedObjectContext
        {
            moc.performAndWait {
                self.InsurancesMO.name = self.name
                self.InsurancesMO.amount = NSDecimalNumber(decimal: self.amount)
                do {
                    try self.InsurancesMO.managedObjectContext?.save()
                    print("Saved")
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

struct SingleLineInsuranceView: View
{
    @StateObject var viewModel: SingleLineInsuranceViewModel
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

class LineInsurancesViewModel: ObservableObject
{
    @Published var Insurances: [MTInsurance] = []

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
        let expense = MTInsurance(context: contextMOC)
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
        let rq = MTInsurance.fetchRequest()
        do {
            self.Insurances = try self.contextMOC.fetch(rq)
        } catch {
            print(error)
        }
    }
}

struct LineInsurancesView: View {
    @State private var showingSheet = false
    @State var isPresenting = false /// 1.
    
    @StateObject var viewModel: LineInsurancesViewModel
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        Group{
            ForEach(viewModel.Insurances) { Insurance in
                    SingleLineInsuranceView(viewModel: SingleLineInsuranceViewModel(InsurancesMO: Insurance))
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
                Text("Add Insurance item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear(perform: loadData)
    }

    private func deleteExpense(offset: IndexSet)
    {
        withAnimation{
            offset.map{ viewModel.Insurances[$0]} .forEach(viewContext.delete)
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
            let expense = MTInsurance(context: viewContext)
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
        if viewModel.Insurances.count == 0 {
            addExpense(name: "Health Insurance", amount: 0)
            addExpense(name: "Car Insurance", amount: 0)
            addExpense(name: "Home Insurance", amount: 0)
            addExpense(name: "Life Insurance", amount: 0)
      }
    }
    
}
