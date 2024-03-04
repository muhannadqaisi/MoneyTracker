//
//  IncomeLineView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/13/23.
//

import SwiftUI

struct IncomeLineView: View {
    
    @Environment(\.modelContext) private var modelContext

    @State var income: Income
    
    @State var amount: Decimal = 0.0

    var body: some View {
            HStack {
                
                TextField("New Item", text: $income.name)

                Spacer()

                TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .onSubmit {
                        income.amount = amount
                    }

            }
            .onAppear {
                if income.amount != .zero {
                    amount = income.amount
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                income.amount = amount
            }

    }
}

