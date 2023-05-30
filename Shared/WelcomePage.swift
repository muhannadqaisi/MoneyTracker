//
//  WelcomePage.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 6/4/22.
//

import Foundation
import SwiftUI

extension UserDefaults {
    var welcomeScreenShownPlay4: Bool {
        get {
            return (UserDefaults.standard.value(forKey: "welcomeScreenShownPlay4") as? Bool) ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "welcomeScreenShownPlay4")
        }
    }
}


struct InformationDetailView: View {
    var title: String = "title"
    var subTitle: String = "subTitle"
    var imageName: String = "car"

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .foregroundColor(.mainColor)
                .padding()
                .accessibility(hidden: true)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)
                Spacer()
                Text(subTitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top)
    }
}


struct WelcomeScreen: View {
    @State private var phoneNumber = ""
    @AppStorage("welcomeScreenShownPlay4")
    var welcomeScreenShownPlay4: Bool = false
    @Binding var done: Bool
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .center) {

                    Spacer().frame(height:50)

                    TitleView()

                    InformationContainerView()

                    .padding(.bottom, 40)

                    Button(action: {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        UserDefaults.standard.welcomeScreenShownPlay4 = true
                        done.toggle()
                    }) {
                        Text("Continue")
                            .customButton()
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct InformationContainerView: View {
    var body: some View {
        VStack(alignment: .leading) {
            InformationDetailView(title: "Track", subTitle: "Money Tracker lets you know exactly how much you spend throughout the month using two categories; income and expenses.", imageName: "minus.slash.plus")

            InformationDetailView(title: "Save Money", subTitle: "After adding all your income and expenses items you can see exactly how much you have left to budget so you can save money smarter.", imageName: "checkmark.square")
            
            InformationDetailView(title: "Simple", subTitle: "Money tracker let's you add and edit items on the go so you can see all your expenses in one place.", imageName: "eye.square")

        }
        .padding(.horizontal)
    }
}

struct TitleView: View {
    var body: some View {
        VStack {
           // Spacer().frame(height:40)

            Text("Welcome to")

            Text("Money Tracker")
                .foregroundColor(.mainColor)
                .font(.system(size: 40))
          //  Spacer().frame(height:30)

        }
    }
}

struct ButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.headline)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.mainColor))
            .padding(.bottom)
    }
}

extension View {
    func customButton() -> ModifiedContent<Self, ButtonModifier> {
        return modifier(ButtonModifier())
    }
}

extension Color {
    static var mainColor = Color.green
}
