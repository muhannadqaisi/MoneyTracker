//
//  MembershipsViewModel.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 6/16/22.
//

import Foundation
import SwiftUI
import CoreData

class SingleLineMembershipViewModel: ObservableObject
{
    @Published var amount: Decimal = .zero
    @Published var name: String = ""
    var MembershipsMO: MTMembership
    init(MembershipsMO:MTMembership)
    {
        self.MembershipsMO = MembershipsMO
        if let name = MembershipsMO.name{
            self.name = name
        }
        if let amount = MembershipsMO.amount{
            self.amount = amount as Decimal
        }
    }
    
    func save()
    {
        if let moc = self.MembershipsMO.managedObjectContext
        {
            moc.performAndWait {
                self.MembershipsMO.name = self.name
                self.MembershipsMO.amount = NSDecimalNumber(decimal: self.amount)
                do {
                    try self.MembershipsMO.managedObjectContext?.save()
                    print("Saved")
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

struct SingleLineMembershipView: View
{
    @StateObject var viewModel: SingleLineMembershipViewModel
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

class LineMembershipsViewModel: ObservableObject
{
    @Published var Memberships: [MTMembership] = []

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
        let expense = MTMembership(context: contextMOC)
        expense.amount = .zero
        expense.name = ""
        do {
            try contextMOC.save()
            print("Saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchData()
    {
        let rq = MTMembership.fetchRequest()
        do {
            self.Memberships = try self.contextMOC.fetch(rq)
        } catch {
            print(error)
        }
    }
}

struct LineMembershipsView: View {
    @State private var showingSheet = false
    @State var isPresenting = false /// 1.
    
    @StateObject var viewModel: LineMembershipsViewModel
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        Group{
            ForEach(viewModel.Memberships) { Membership in
                    SingleLineMembershipView(viewModel: SingleLineMembershipViewModel(MembershipsMO: Membership))
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
                Text("Add Membership item")
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear(perform: loadData)
    }

    private func deleteExpense(offset: IndexSet)
    {
        withAnimation{
            offset.map{ viewModel.Memberships[$0]} .forEach(viewContext.delete)
            do {
                try viewContext.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func addExpense(name: String, amount: Decimal)
    {
            let expense = MTMembership(context: viewContext)
            expense.amount = NSDecimalNumber(decimal: amount)
            expense.name = name
            do {
                try viewContext.save()
                print("Saved")
            } catch {
                print(error.localizedDescription)
            }
    }
    
    func loadData() {
        if viewModel.Memberships.count == 0 {
            addExpense(name: "Gym Membership", amount: 0)
            addExpense(name: "Music Membership", amount: 0)
            addExpense(name: "TV Membership", amount: 0)
            addExpense(name: "Gaming Membership", amount: 0)
      }
    }
    
}
