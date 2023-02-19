//
//  ContentView.swift
//  Shared
//
//  Created by Muhannad Qaisi on 5/20/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
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
    
    var body: some View {
        if showWelcome || UserDefaults.standard.welcomeScreenShownPlay4 {
                ExpenseCardView()
                Spacer().frame(height:12)
                LeftToBudget()
                VStack {
                    Picker(selection: $tabSelectedValue, label: Text("")) {
                        Text("Money Tracker").tag(0)
                        Text("Chart").tag(1)
                        
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 15)
                }
                    Form{
                        if self.tabSelectedValue == 1 {
                            IncomeAndExpenseGraphView()
                        } else {
                            IncomeListView(viewModel: IncomeListViewModel(moc: viewContext))
                            HousingListView(viewModel: HousingListViewModel(moc: viewContext))
                            SavingsListView(viewModel: SavingsListViewModel(moc: viewContext))
                            FoodsListView(viewModel: FoodsListViewModel(moc: viewContext))
                            TransportationListView(viewModel: TransportationListViewModel(moc: viewContext))
                            PersonalListView(viewModel: PersonalListViewModel(moc: viewContext))
                            InsuranceListView(viewModel: InsuranceListViewModel(moc:viewContext))
                            MembershipsListView(viewModel: MembershipsListViewModel(moc:viewContext))
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
            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
            
        } else {
            WelcomeScreen(done: $showWelcome)
        }
        
    }
    
    private func didClickReset() {
        PersistenceController.shared.reset()
        
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
    func IncomeAndExpenseGraphView()-> some View {
        VStack {
            if(viewModel.total() != .zero){
                PieChartView(values: [Double(viewModel.total()), Double(viewModel.totalExpense())], names: ["Total Income", "Total Expense"], formatter: {value in String(format: "$%.2f", value)}, colors: [Color(hue: 0.3, saturation: 0.70, brightness: 0.90), Color.red])
                
            } else {
                EmptyPieChartView(values: [1, 0], names: ["Total Income", "Other Income"], formatter: {value in String(format: "$%.2f", value)}, colors: [Color.gray, Color.gray])
            }

        }
        
    }
    func LeftToBudget()-> some View {
        HStack{
            if (viewModel.total() - viewModel.totalExpense() >= 0) {
                Text(viewModel.total() - viewModel.totalExpense(), format: .currency(code: "USD"))
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color(hue: 0.303, saturation: 0.83, brightness: 0.68))
            } else {
                Text(viewModel.total() - viewModel.totalExpense(), format: .currency(code: "USD"))
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
        
    }
    
}

struct BlurredHeaderView: View {
    var body: some View{
        ZStack{
            ZStack{
                HStack{
                    Circle()
                        .fill(Color.green)
                        .scaleEffect(1.5)
                        .offset(x:-120)
                        .offset(y:40)
                        .blur(radius: 120)
                }
                HStack{
                    Circle()
                        .fill(Color.red)
                        .scaleEffect(1.5)
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
                Text("Income: \(subTitle * viewModel.total(), format: .currency(code: "USD"))")
                    .font(.system(size: 17, weight: .regular))
                    .accessibility(addTraits: .isHeader)
                    .foregroundColor(Color.green)
                Text("Expenses: \(subTitle * viewModel.totalExpense(), format: .currency(code: "USD"))")
                    .font(.system(size: 17, weight: .regular))
                    .accessibility(addTraits: .isHeader)
                    .foregroundColor(Color.red)
                Text("Saved: \(subTitle * (viewModel.total() - viewModel.totalExpense()), format: .currency(code: "USD"))")
                    .font(.system(size: 17, weight: .regular))
                    .accessibility(addTraits: .isHeader)
                    .foregroundColor(Color.blue)
            }
        }
        
        .padding(.top)
    }
    
}


