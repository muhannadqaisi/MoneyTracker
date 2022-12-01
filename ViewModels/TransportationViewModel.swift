//
//  TransportationViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 5/31/22.
//

import SwiftUI
import Foundation
import CoreData

class SingleLineTransportationViewModel: ObservableObject
{
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var TransportationsMO: MTTransportation
    init(TransportationsMO:MTTransportation)
    {
        self.TransportationsMO = TransportationsMO
        if let name = TransportationsMO.name{
            self.name = name
        }
        if let amount = TransportationsMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        if let moc = self.TransportationsMO.managedObjectContext
        {
            moc.performAndWait {
                self.TransportationsMO.name = self.name
                self.TransportationsMO.amount = NSDecimalNumber(decimal: self.amount)
                do {
                    try self.TransportationsMO.managedObjectContext?.save()
                    print("Saved")
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

struct SingleLineTransportationView: View
{
    @StateObject var viewModel: SingleLineTransportationViewModel
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

class LineTransportationsViewModel: ObservableObject
{
    @Published var Transportations: [MTTransportation] = []

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
        let expense = MTTransportation(context: contextMOC)
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
        let rq = MTTransportation.fetchRequest()
        do {
            self.Transportations = try self.contextMOC.fetch(rq)
        } catch {
            print(error)
        }
    }
}

struct LineTransportationsView: View {
    @State private var showingSheet = false
    @State var isPresenting = false /// 1.
    
    @StateObject var viewModel: LineTransportationsViewModel
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        Group{
            ForEach(viewModel.Transportations) { Transportation in
                    SingleLineTransportationView(viewModel: SingleLineTransportationViewModel(TransportationsMO: Transportation))
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
                Text("Add transportation item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear(perform: loadData)
    }

    private func deleteExpense(offset: IndexSet)
    {
        withAnimation{
            offset.map{ viewModel.Transportations[$0]} .forEach(viewContext.delete)
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
            let expense = MTTransportation(context: viewContext)
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
        if viewModel.Transportations.count == 0 {
            addExpense(name: "Car Payments ", amount: 0)
            addExpense(name: "Gas", amount: 0)
            addExpense(name: "Maintenance ", amount: 0)
      }
    }
}
