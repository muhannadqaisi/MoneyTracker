//
//  KeyBoardView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 6/3/22.
//

import Foundation
import SwiftUI

class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var height: CGFloat = .zero
    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func dismiss() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    deinit { notificationCenter.removeObserver(self) }
    @objc func keyBoardWillShow(_ notification: Notification) {
        height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? .zero
    }
    @objc func keyBoardWillHide(_ notification: Notification) {
        height = .zero
    }
}

struct KeyboardView<Content, ToolBar>: View where Content: View, ToolBar: View {
    @StateObject private var keyboard = KeyboardResponder()
    @State var show = false

    let toolbarFrame = CGSize(width: UIScreen.main.bounds.width, height: 40)
    var content: () -> Content
    var toolBar: () -> ToolBar
    var body: some View {
        ZStack {
            content().padding(.bottom, keyboard.height == .zero ? .zero : toolbarFrame.height)
            VStack {
                 Spacer()
                 toolBar()
                    .frame(width: toolbarFrame.width, height: toolbarFrame.height)
                    .background(Color(red: 0.949, green: 0.949, blue: 0.97, opacity: 1.0))
            }
            .opacity(keyboard.height == .zero ? .zero : 1)
            .animation(.easeInOut(duration: 1.0), value: show)
        }
        .padding(.bottom, keyboard.height)
        .edgesIgnoringSafeArea(.bottom)
        .animation(.easeInOut(duration: 1.0), value: show)
    }
}
