//
//  SavingsLineView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 2/14/23.
//

import SwiftUI

struct SavingsLineView: View {
    @StateObject var viewModel: SavingsLineViewModel
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
