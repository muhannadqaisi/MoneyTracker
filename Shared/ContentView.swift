//
//  ContentView.swift
//  Shared
//
//  Created by Muhannad Qaisi on 5/20/22.
//

import SwiftUI
import CoreData
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: IncomeAndExpenseViewModel
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    enum FocusText{
        case item, amount
    }
    
    @State var showDetailedSheet = false
    @State private var showingAlert = false
    @State private var showWelcome: Bool = false
    @State var tabSelectedValue = 0
    @State var showViews: [Bool] = Array(repeating: false, count: 5)
    
    @Query var incomes: [Income] = []

    var body: some View {
        let firstIncome = incomes.first
        if showWelcome || UserDefaults.standard.welcomeScreenShownPlay4 {
            VStack{
//                RingCardView(viewModel: viewModel)
//                    .opacity(showViews[0] ? 1 : 0)
//                    .offset(y: showViews[0] ? 0 : 200)
                VStack {
                    HStack {
                        Text("Income")
                            .fontWeight(.thin)
                        Text(self.incomeTotal(),format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    }
                    HStack {
                        Text("Expense")
                            .fontWeight(.thin)
                        Text("$0.00")
                    }
                }

                LeftToBudget()
//                    .opacity(showViews[1] ? 1 : 0)
//                    .offset(y: showViews[1] ? 0 : 250)
                List{
                    IncomeListView()
                    HousingListView(viewModel: HousingListViewModel(moc: viewContext))
                    SavingsListView(viewModel: SavingsListViewModel(moc: viewContext))
                    FoodsListView(viewModel: FoodsListViewModel(moc: viewContext))
                    TransportationListView(viewModel: TransportationListViewModel(moc: viewContext))
                    PersonalListView(viewModel: PersonalListViewModel(moc: viewContext))
                    InsuranceListView(viewModel: InsuranceListViewModel(moc:viewContext))
                    MembershipsListView(viewModel: MembershipsListViewModel(moc:viewContext))
                    Section("Reset Data?"){
                        Button(role: .destructive) {
                            showingAlert = true
                        } label: {
                            Label("Reset Data", systemImage: "trash")
                        }
                        .alert("Reset Data?", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) {
                                self.didClickReset()
                                do {
                                    try viewContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                }
                Spacer(minLength: 0.2)
                .opacity(showViews[2] ? 1 : 0)
                .offset(y: showViews[2] ? 0 : 200)
                
                .sheet(isPresented: $showDetailedSheet) {
                    OrderSheet(viewModel: viewModel)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.2)))
                
            }
            .onAppear(perform: animateViews)
            .background{
                ZStack{
                    VStack{
                        if (viewModel.total() > viewModel.totalExpense()){
                            Circle()
                                .fill(Color.green)
                                .scaleEffect(0.6)
                                .offset(x: 20)
                                .blur(radius: 120)
                            
                        } else {
                            Circle()
                                .fill(Color("Red"))
                                .scaleEffect(0.6,anchor: .leading)
                                .offset(y: -20)
                                .blur(radius: 120)
                        }
                    }
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
                .ignoresSafeArea()
            }
        } else {
            WelcomeScreen(done: $showWelcome)
        }
        
    }
    
    func animateViews(){
        withAnimation(.easeInOut){
            showViews[0] = true
        }
        
        withAnimation(.easeInOut.delay(0.1)){
            showViews[1] = true
        }
        
        withAnimation(.easeInOut.delay(0.15)){
            showViews[2] = true
        }
    }
    
    private func didClickReset() {
        PersistenceController.shared.reset()
        do {
            try modelContext.delete(model: Income.self)
        } catch {
            print("Failed to clear all Country and City data.")
        }
    }
    
    
    func addEmptyLine()
    {
        let expense = Expenses(context: viewContext)
        expense.amount = .zero
        expense.name = ""
        do {
            try viewContext.save()
            print("Saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @ViewBuilder
    func ExpenseCardView()-> some View
    {
        VStack {
            Spacer().frame(height:5)
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
                    Text(viewModel.total(), format: .currency(code: "USD"))
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
                    
                    Text(viewModel.totalExpense(), format: .currency(code: "USD"))
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 5)
                }
                
            }
        }
        .background{
            BlurredHeaderView()
        }
    }
    
    func LeftToBudget()-> some View {
        HStack{
            if (viewModel.total() - viewModel.totalExpense() >= 0) {
                Text(viewModel.total() - viewModel.totalExpense(), format: .currency(code: "USD"))
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color.blue)
            } else {
                Text(viewModel.total() - viewModel.totalExpense(), format: .currency(code: "USD"))
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color("Red"))
            }
            Text("left to budget")
                .font(.system(size: 18, weight: .light))
            Button(action: {
                showDetailedSheet = true
            }, label: {
                Image(systemName: "arrow.up.circle")
                    .imageScale(.large)
                    .tint(Color.blue)
                
            })
        }
        
    }
    func incomeTotal() -> Decimal {
        var totalToday: Decimal = .zero
        for item in incomes {
            totalToday += item.amount
        }
        return totalToday
    }
    
}

struct BlurredHeaderView: View {
    var body: some View{
        ZStack{
            ZStack{
                HStack{
                    Circle()
                        .fill(Color.green)
                        .scaleEffect(1.0)
                        .offset(x:-120)
                        .offset(y:40)
                        .blur(radius: 120)
                }
                HStack{
                    Circle()
                        .fill(Color("Red"))
                        .scaleEffect(1.0)
                        .offset(x:120)
                        .offset(y:40)
                        .blur(radius: 120)
                }
            }
        }
    }
}


struct OrderSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode
    @ObservedObject var viewModel = IncomeAndExpenseViewModel()
    
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
            DetailedView(title: "Month", subTitle: 1, imageName: "1.circle", distance: 11, viewModel: viewModel)
            Divider()
            DetailedView(title: "Months", subTitle: 6, imageName: "6.circle", distance: 0, viewModel: viewModel)
            Divider()
            DetailedView(title: "Months", subTitle: 12, imageName: "12.circle", distance: 0, viewModel: viewModel)
            
        }
        .padding(.horizontal)
    }
}



struct DetailedView: View {
    var title: String = ""
    var subTitle: Int = 0
    var imageName: String = ""
    var distance: Int = 0
    var viewModel = IncomeAndExpenseViewModel()
    
    @Query var incomes: [Income] = []
    
    var body: some View {
        HStack(alignment: .center, spacing: -12) {
            Image(systemName: imageName)
                .font(.system(size: 25, weight: .regular))
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
                Text("Income: \(subTitle * NSDecimalNumber(decimal: self.incomeTotal()).intValue, format: .currency(code: "USD"))")
                    .font(.system(size: 17, weight: .regular))
                    .accessibility(addTraits: .isHeader)
                    .foregroundColor(Color.green)
                Text("Expenses: \(subTitle * viewModel.totalExpense(), format: .currency(code: "USD"))")
                    .font(.system(size: 17, weight: .regular))
                    .accessibility(addTraits: .isHeader)
                    .foregroundColor(Color("Red"))
                Text("Saved: \(subTitle * (viewModel.total() - viewModel.totalExpense()), format: .currency(code: "USD"))")
                    .font(.system(size: 17, weight: .regular))
                    .accessibility(addTraits: .isHeader)
                    .foregroundColor(Color.blue)
            }
        }
        
        .padding(.top)
    }
    
    func incomeTotal() -> Decimal {
        var totalToday: Decimal = .zero
        for item in incomes {
            totalToday += item.amount
        }
        return totalToday
    }
}


