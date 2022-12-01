//
//  ContentView.swift
//  Shared
//
//  Created by Muhannad Qaisi on 5/20/22.
//

import SwiftUI
import CoreData

struct HeaderView: View {
    
    var body: some View {
        VStack(alignment: .center){
            HStack{
                Text("2000")
                    .font(.title)
                Text("left to budget")
                    .foregroundColor(.white)
                    .font(.title)
            }
            .frame(maxWidth: .infinity)
        }
        .background(.green)
    }
    
}


struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: MTSavings.entity(), sortDescriptors: [])
    var savings: FetchedResults<MTSavings>
    @FetchRequest(entity: MTIncome.entity(), sortDescriptors: [])
    var income: FetchedResults<MTIncome>
    @FetchRequest(entity: MTHousing.entity(), sortDescriptors: [])
    var housing: FetchedResults<MTHousing>
    @FetchRequest(entity: MTPersonal.entity(), sortDescriptors: [])
    var personal: FetchedResults<MTPersonal>
    @FetchRequest(entity: MTTransportation.entity(), sortDescriptors: [])
    var transportation: FetchedResults<MTTransportation>
    @FetchRequest(entity: MTFood.entity(), sortDescriptors: [])
    var food: FetchedResults<MTFood>
    @FetchRequest(entity: MTInsurance.entity(), sortDescriptors: [])
    var insurance: FetchedResults<MTInsurance>
    @FetchRequest(entity: MTMembership.entity(), sortDescriptors: [])
    var memberships: FetchedResults<MTMembership>
    @Environment(\.colorScheme) var colorScheme

    @State private var numOne: Int = 0
    @State private var numTwo: Int = 0
    
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    private var result: Int {
        numOne + numTwo
    }
    enum FocusText{
        case item, amount
    }
    @State var isPresenting = false /// 1.
    
    @FocusState var isInputActive: Bool
    @FocusState private var focusField: FocusText?
    @State private var itemText = ""
    @State private var amountText = ""
    @State private var submittedText = "Display creds"
    
    //@FocusState var focusedField: Field?
    @State var showDetailedSheet = false
    @State private var showingAlert = false
    @State private var showWelcome: Bool = false
    
    
    var body: some View {
        if showWelcome || UserDefaults.standard.welcomeScreenShownPlay4 {
            VStack {
                ExpenseCardView()
                Divider()
                Spacer().frame(height:12)
                HStack{
                    if ((Int(total()) - Int(totalExpense())) >= 0) {
                        Text("$\(Int(total()) - Int(totalExpense()))")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(Color(hue: 0.303, saturation: 0.83, brightness: 0.68))
                    } else {
                        Text("$\(Int(total()) - Int(totalExpense()))")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(Color.red)
                    }
                    Text("left to budget")
                        .font(.system(size: 20, weight: .light))
                    Button(action: {
                        showDetailedSheet = true
                    }, label: {
                        Image(systemName: "arrow.up.circle")
                            .imageScale(.large)
                            .tint(Color.blue)
                        
                    })
                }
                
                KeyboardView {
                    List{
                        Section(header: Text("Income").font(.title3)) {
                            LineIncomesView(viewModel: LineIncomesViewModel(moc:viewContext))
                        }
                        Section(header: Text("Savings").font(.title3)) {
                            LineSavingsView(viewModel: LineSavingsViewModel(moc:viewContext))
                        }
                        Section(header: Text("Housing").font(.title3)) {
                            LineHousingsView(viewModel: LineHousingsViewModel(moc:viewContext))
                        }
                        Section(header: Text("Food").font(.title3)) {
                            LineFoodsView(viewModel: LineFoodsViewModel(moc:viewContext))
                        }
                        Section(header: Text("Transportation").font(.title3)) {
                            LineTransportationsView(viewModel: LineTransportationsViewModel(moc:viewContext))
                        }
                        Section(header: Text("Insurance").font(.title3)) {
                            LineInsurancesView(viewModel: LineInsurancesViewModel(moc:viewContext))
                        }
                        Section(header: Text("Personal").font(.title3)) {
                            LinePersonalsView(viewModel: LinePersonalsViewModel(moc:viewContext))
                        }
                        Section(header: Text("Memberships").font(.title3)) {
                            LineMembershipsView(viewModel: LineMembershipsViewModel(moc:viewContext))
                        }
                        Button(role: .destructive) {
                            showingAlert = true
                        } label: {
                            Label("Reset Data", systemImage: "trash")
                        }
                        .alert("Reset Data?", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) {
                                self.didClickReset()
                                addEmptyLine()
                            }
                        }
                        
                        
                    }
                    .sheet(isPresented: $showDetailedSheet) {
                        OrderSheet()
                    }
                }
            toolBar: {
                HStack {
                    Spacer()
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: { Text("Submit") }
                }.padding()
            }
                
            }
            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
            .onAppear() {
                UITableView.appearance().backgroundColor = UIColor.clear
                UITableViewCell.appearance().backgroundColor = UIColor.clear
            }
            .frame(maxWidth: .infinity)
            .background{
                ZStack{
                    VStack{
                        HStack{
                            Circle()
                                .fill(Color.green)
                                .scaleEffect(1.1)
                                .offset(x:-120)
                                .offset(y:40)
                                .blur(radius: 120)
                        }
                        HStack{
                            Circle()
                                .fill(Color.red)
                                .scaleEffect(1.1)
                                .offset(y:-290)
                                .offset(x:200)
                                .blur(radius: 120)
                        }
                        
                        HStack{
                            Circle()
                                .fill(Color.gray)
                                .scaleEffect(0.8)
                                .offset(x:20)
                                .offset(y:-129)
                                .blur(radius: 120)
                        }
                        
                    }
                }
                .ignoresSafeArea()
            }
            //.preferredColorScheme(.light)
            
        } else {
            WelcomeScreen(done: $showWelcome)
        }
        
    }
    
    private func didClickReset() {
        PersistenceController.shared.reset()
        
    }
    
    func total() -> Int {
        var totalToday: Int = 0
        for item in income {
            totalToday += item.amount!.intValue
        }
        return totalToday
    }
    
    func totalExpense() -> Int {
        var totalToday: Int = 0
        for item in savings {
            totalToday += item.amount!.intValue
        }
        for item2 in housing {
            totalToday += item2.amount!.intValue
        }
        for item3 in transportation {
            totalToday += item3.amount!.intValue
        }
        for item4 in food {
            totalToday += item4.amount!.intValue
        }
        for item5 in personal {
            totalToday += item5.amount!.intValue
        }
        for item6 in insurance {
            totalToday += item6.amount!.intValue
        }
        for item7 in memberships {
            totalToday += item7.amount!.intValue
        }
        return totalToday
    }
    
    func addEmptyLine()
    {
        let expense = Expenses(context: viewContext)
        expense.amount = .zero
        expense.name = ""
        do {
            try viewContext.save()
            print("Order saved.")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @ViewBuilder
    func ExpenseCardView()-> some View
    {
        VStack {
            Spacer().frame(height:12)
            HStack{
                Text("Money Tracker")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .font(.system(size: 30))
            }
            HStack{
                VStack(spacing: 0){
                    Text("Monthly Income")
                        .font(.system(size: 18, weight: .light))
                        .padding()
                    Text("$\(Int(total()))")
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 5)
                }
                Divider().frame(height: 60)
                    .overlay(colorScheme == .dark ? Color.white : Color.black)
                
                VStack(spacing: 0){
                    Text("Monthly Expenses")
                        .font(.system(size: 18, weight: .light))
                        .padding()
                    
                    Text("$\(Int(totalExpense()))")
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 5)
                }
                
            }
        }
        //        GeometryReader{proxy in
        //            RoundedRectangle(cornerRadius: 0, style: .continuous)
        //                .fill(
        //                    .linearGradient(colors: [Color(red: 0.0, green: 0.8, blue: 0.3),Color(red: 1.3, green: 0.1, blue: 0.1)], startPoint: .leading, endPoint: .trailing))
        //            VStack {
        //                VStack(spacing: 0){
        //                    Text("Monthly Income")
        //                        .font(.system(size: 18, weight: .light))
        //                        .padding()
        //                        .foregroundColor(Color.white)
        //                    Text("$\(Int(total()))")
        //                        .font(.system(size: 20, weight: .bold))
        //                        .foregroundColor(Color.white)
        //                        .lineLimit(1)
        //                        .multilineTextAlignment(.leading)
        //                        .padding(.bottom, 5)
        //                }
        //            }
        //            .foregroundColor(.white)
        //            .frame(maxWidth: .infinity , maxHeight: .infinity, alignment: .leading)
        //
        //            VStack {
        //                VStack(spacing: 0){
        //                    Text("Monthly Expenses")
        //                        .font(.system(size: 18, weight: .light))
        //                        .padding()
        //                        .foregroundColor(Color.white)
        //
        //
        //                    Text("$\(Int(totalExpense()))")
        //                        .font(.system(size: 20, weight: .bold))
        //                        .foregroundColor(Color.white)
        //                        .lineLimit(1)
        //                        .multilineTextAlignment(.leading)
        //                        .padding(.bottom, 5)
        //                }
        //            }
        //            .foregroundColor(.white)
        //            .frame(maxWidth: .infinity , maxHeight: .infinity, alignment: .trailing)
        //        }
        //        .frame(height: 90)
        //        .padding(.top)
        //        .clipped()
    }
    
}


struct OrderSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode
    
    @State var amount = 0.00
    @State var itemName = ""
    var body: some View {
        Spacer().frame(height:35)
        HStack(){
            Text("Detailed Budget Plan")
                .font(.system(size: 35, weight: .light))
        }
        Spacer().frame(height:40)
        VStack(alignment: .leading, spacing: 40) {
            DetailedView(title: "Month", subTitle: 1, imageName: "1.circle", distance: 11)
            Divider()
            DetailedView(title: "Months", subTitle: 6, imageName: "6.circle", distance: 0)
            Divider()
            DetailedView(title: "Months", subTitle: 12, imageName: "12.circle", distance: 0)
            
        }
        .padding(.horizontal)
    }
}



struct DetailedView: View {
    var title: String = "title"
    var subTitle: Int = 0
    var imageName: String = "car"
    var distance: Int = 0
    
    @FetchRequest(entity: MTSavings.entity(), sortDescriptors: [])
    var savings: FetchedResults<MTSavings>
    @FetchRequest(entity: MTIncome.entity(), sortDescriptors: [])
    var income: FetchedResults<MTIncome>
    @FetchRequest(entity: MTHousing.entity(), sortDescriptors: [])
    var housing: FetchedResults<MTHousing>
    @FetchRequest(entity: MTPersonal.entity(), sortDescriptors: [])
    var personal: FetchedResults<MTPersonal>
    @FetchRequest(entity: MTTransportation.entity(), sortDescriptors: [])
    var transportation: FetchedResults<MTTransportation>
    @FetchRequest(entity: MTFood.entity(), sortDescriptors: [])
    var food: FetchedResults<MTFood>
    @FetchRequest(entity: MTInsurance.entity(), sortDescriptors: [])
    var insurance: FetchedResults<MTInsurance>
    @FetchRequest(entity: MTMembership.entity(), sortDescriptors: [])
    var memberships: FetchedResults<MTMembership>
    
    var body: some View {
        HStack(alignment: .center, spacing: -12) {
            Image(systemName: imageName)
                .font(.system(size: 25, weight: .regular))
                .foregroundColor(.black)
                .padding()
                .accessibility(hidden: true)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 25, weight: .light))
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)
                
            }
            Spacer().frame(width:50 + CGFloat(distance))
            //Vertical Line in HStack
            HStack{
                Color.gray.frame(width:CGFloat(2) / UIScreen.main.scale)
            }
            Spacer().frame(width:50)
            VStack(alignment: .leading) {
                Spacer().frame(height:8)
                Text("Income: $\(subTitle * total())")
                    .font(.system(size: 17, weight: .regular))
                    .accessibility(addTraits: .isHeader)
                    .foregroundColor(Color.green)
                Text("Expenses: $\(subTitle * totalExpense())")
                    .font(.system(size: 17, weight: .regular))
                    .accessibility(addTraits: .isHeader)
                    .foregroundColor(Color.red)
                Text("Saved: $\(subTitle * ((Int(total()) - Int(totalExpense()))))")
                    .font(.system(size: 17, weight: .regular))
                    .accessibility(addTraits: .isHeader)
                    .foregroundColor(Color.blue)
            }
        }
        
        .padding(.top)
    }
    
    func total() -> Int {
        var totalToday: Int = 0
        for item in income {
            totalToday += item.amount!.intValue
        }
        return totalToday
    }
    
    func totalExpense() -> Int {
        var totalToday: Int = 0
        for item in savings {
            totalToday += item.amount!.intValue
        }
        for item2 in housing {
            totalToday += item2.amount!.intValue
        }
        for item3 in transportation {
            totalToday += item3.amount!.intValue
        }
        for item4 in food {
            totalToday += item4.amount!.intValue
        }
        for item5 in personal {
            totalToday += item5.amount!.intValue
        }
        for item6 in insurance {
            totalToday += item6.amount!.intValue
        }
        for item7 in memberships {
            totalToday += item7.amount!.intValue
        }
        return totalToday
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
