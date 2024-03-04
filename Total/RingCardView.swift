//
//  RingCardView.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 3/10/23.
//

import SwiftUI
import SwiftData

// MARK: Progress Ring Model and Sample Data
struct Ring: Identifiable{
    var id = UUID().uuidString
    var progress: CGFloat = 0
    var value: String
    var keyIcon: String
    var keyColor: Color
    var totalValue: Double
}

struct RingCardView: View {
    
    @ObservedObject var viewModel: IncomeAndExpenseViewModel
    
    @Query var incomes: [Income] = []
    
    var body: some View {
        
        let rings2: [Ring] = [
            
            Ring(progress: (CGFloat(NSDecimalNumber(decimal: self.incomeTotal()).intValue)/CGFloat(NSDecimalNumber(decimal: self.incomeTotal()).intValue)) * 100, value: "Income", keyIcon: "figure.walk", keyColor: Color.green, totalValue: Double(viewModel.total())),
            Ring(progress: (CGFloat(viewModel.totalExpense())/CGFloat(viewModel.total())) * 100, value: "Expense", keyIcon: "flame.fill", keyColor: Color("Red") , totalValue: Double(viewModel.totalExpense()))
        ]
        
        VStack(spacing: 6){
            Text("Money Tracker")
                .fontWeight(.semibold)
                .font(.title2)
                .frame(maxWidth: .infinity,alignment: .leading)
            
            HStack(spacing: 15){
                
                // Progress Ring
                ZStack{
                    ForEach(rings2.indices,id: \.self){index in
                        AnimatedRingView(ring: rings2[index], index: index, ringsArray: rings2)
                    }
                }
                .frame(width: 90, height: 90)
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(rings2){ring in
                        VStack{
                            HStack{
                                RoundedRectangle(cornerRadius: 5.0)
                                    .fill(ring.keyColor)
                                    .frame(width: 20, height: 20)
                                if (viewModel.total() != .zero || viewModel.totalExpense() != .zero){
                                    VStack(alignment: .leading){
                                        Text(convertDoubleToCurrency(amount: ring.totalValue))
                                            .fontWeight(.semibold)
                                        if (ring.progress.isNaN || ring.progress.isInfinite){
                                            Text("0%")
                                        } else {
                                            Text("\(Int(ring.progress))%")
                                                .foregroundColor(Color.gray)
                                        }
                                    }
                                } else {
                                    VStack(alignment: .leading){
                                        Text("$0.00")
                                        //Text("0%")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.leading,10)
            }
            .padding(.top,20)
        }
        .padding(.horizontal,20)
        .padding(.vertical,25)
        .background{
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(.ultraThinMaterial)
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


// Animating Rings
struct AnimatedRingView: View{
    var ring: Ring
    var index: Int
    var ringsArray: [Ring]
    @State var showRing: Bool = false
    
    var body: some View{
        ZStack{
            Circle()
                .stroke(.gray.opacity(0.3),lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: showRing ? ringsArray[index].progress / 100 : 0)
                .stroke(ringsArray[index].keyColor,style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .rotationEffect(.init(degrees: -90))
        }
        .padding(CGFloat(index) * 16)
        .onAppear {
            // Show After Intial Animation Finished
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.interactiveSpring(response: 1, dampingFraction: 1, blendDuration: 1).delay(Double(index) * 0.1)){
                    showRing = true
                }
            }
        }
    }
}
