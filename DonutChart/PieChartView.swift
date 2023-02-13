//
//  PieChartView.swift
//  MoneyTracker (iOS)
//
//  Created by Muhannad Qaisi on 2/9/23.
//

import SwiftUI

import Foundation


struct PieSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
}

public struct PieChartView: View {
    public let values: [Double]
    public let names: [String]
    public let formatter: (Double) -> String
    
    public var colors: [Color]
    public var backgroundColor: Color
    
    public var widthFraction: CGFloat
    public var innerRadiusFraction: CGFloat
    
    @State private var activeIndex: Int = -1
    @Environment(\.colorScheme) var colorScheme
    @State private var angle: Double = 0
    var slices: [PieSliceData] {
        let sum = values.reduce(0, +)
        var endDeg: Double = 0
        var tempSlices: [PieSliceData] = []
        
        for (i, value) in values.enumerated() {
            let degrees: Double = value * 360 / sum
            tempSlices.append(PieSliceData(startAngle: Angle(degrees: endDeg), endAngle: Angle(degrees: endDeg + degrees), color: self.colors[i]))
            endDeg += degrees
        }
        return tempSlices
    }
    
    public init(values:[Double], names: [String], formatter: @escaping (Double) -> String, colors: [Color] , backgroundColor: Color = Color(red: 21 / 255, green: 24 / 255, blue: 30 / 255, opacity: 1.0), widthFraction: CGFloat = 0.75, innerRadiusFraction: CGFloat = 0.70){

        self.values = values
        self.names = names
        self.formatter = formatter
        
        self.colors = colors
        self.backgroundColor = backgroundColor
        self.widthFraction = widthFraction
        self.innerRadiusFraction = innerRadiusFraction
    }
    
    public var body: some View {
            VStack{
                ZStack{
                    ForEach(0..<self.values.count, id: \.self){ i in
                        PieSliceView(pieSliceData: self.slices[i])
                            .scaleEffect(self.activeIndex == i ? 1.03 : 1)
                            .animation(.spring(), value: angle)
                    }
                    .frame(width: widthFraction * viewBounds().width, height: widthFraction * viewBounds().width)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let radius = 0.5 * widthFraction * viewBounds().width
                                let diff = CGPoint(x: value.location.x - radius, y: radius - value.location.y)
                                var radians = Double(atan2(diff.x, diff.y))
                                if (radians < 0) {
                                    radians = 2 * Double.pi + radians
                                }
                                
                                for (i, slice) in slices.enumerated() {
                                    if (radians < slice.endAngle.radians) {
                                        self.activeIndex = i
                                        break
                                    }
                                }
                            }
                            .onEnded { value in
                                self.activeIndex = -1
                            }
                    )
                    Circle()
                        .blendMode(.destinationOut) // clear
                        .frame(width: widthFraction * viewBounds().width * innerRadiusFraction, height: widthFraction * viewBounds().width * innerRadiusFraction)
                    
//                    VStack {
//                        if (self.activeIndex == -1){
//                            Text(convertDoubleToCurrency(amount: values.reduce(0, +)))
//                        } else {
//                            Text(convertDoubleToCurrency(amount: values[self.activeIndex]))
//
//                        }
//                        
//                    }
                    
                }
                .compositingGroup()
                Divider()
                PieChartRows(colors: self.colors, names: self.names, values: self.values, percents: self.values.compactMap { String(format: "%.0f%%", $0 * 100 / self.values.reduce(0, +)) })
            }

    }
}

public struct EmptyPieChartView: View {
    public let values: [Double]
    public let names: [String]
    public let formatter: (Double) -> String
    
    public var colors: [Color]
    public var backgroundColor: Color
    
    public var widthFraction: CGFloat
    public var innerRadiusFraction: CGFloat
    
    @State private var activeIndex: Int = -1
    @Environment(\.colorScheme) var colorScheme
    @State private var angle: Double = 0
    var slices: [PieSliceData] {
        let sum = values.reduce(0, +)
        var endDeg: Double = 0
        var tempSlices: [PieSliceData] = []
        
        for (i, value) in values.enumerated() {
            let degrees: Double = value * 360 / sum
            tempSlices.append(PieSliceData(startAngle: Angle(degrees: endDeg), endAngle: Angle(degrees: endDeg + degrees), color: self.colors[i]))
            endDeg += degrees
        }
        return tempSlices
    }
    
    public init(values:[Double], names: [String], formatter: @escaping (Double) -> String, colors: [Color] , backgroundColor: Color = Color(red: 21 / 255, green: 24 / 255, blue: 30 / 255, opacity: 1.0), widthFraction: CGFloat = 0.75, innerRadiusFraction: CGFloat = 0.70){

        self.values = values
        self.names = names
        self.formatter = formatter
        
        self.colors = colors
        self.backgroundColor = backgroundColor
        self.widthFraction = widthFraction
        self.innerRadiusFraction = innerRadiusFraction
    }
    
    public var body: some View {
            VStack{
                ZStack{
                    ForEach(0..<self.values.count, id: \.self){ i in
                        PieSliceView(pieSliceData: self.slices[i])
                            .scaleEffect(self.activeIndex == i ? 1.03 : 1)
                            .animation(.spring(), value: angle)
                    }
                    .frame(width: widthFraction * viewBounds().width, height: widthFraction * viewBounds().width)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let radius = 0.5 * widthFraction * viewBounds().width
                                let diff = CGPoint(x: value.location.x - radius, y: radius - value.location.y)
                                var radians = Double(atan2(diff.x, diff.y))
                                if (radians < 0) {
                                    radians = 2 * Double.pi + radians
                                }
                                
                                for (i, slice) in slices.enumerated() {
                                    if (radians < slice.endAngle.radians) {
                                        self.activeIndex = i
                                        break
                                    }
                                }
                            }
                            .onEnded { value in
                                self.activeIndex = -1
                            }
                    )
                    Circle()
                        .blendMode(.destinationOut) //clear
                        .frame(width: widthFraction * viewBounds().width * innerRadiusFraction, height: widthFraction * viewBounds().width * innerRadiusFraction)
                    
                    VStack {
                        Text("Total")
                        Text("$0.00")
                        
                    }
                    
                }
                .compositingGroup()
                Divider()
                PieChartRows(colors: self.colors, names: self.names, values: [0,0], percents: self.values.compactMap { String(format: "%.0f%%", $0 * 100 / self.values.reduce(0, +)) })
            }

    }
}


func convertDoubleToCurrency(amount: Double) -> String{
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.locale = Locale.current
    return numberFormatter.string(from: NSNumber(value: amount))!
}


extension View {
    func viewBounds() -> CGRect {
      return UIScreen.main.bounds
    }
}

struct PieSliceView: View {
    var pieSliceData: PieSliceData
    
    var midRadians: Double {
        return Double.pi / 2.0 - (pieSliceData.startAngle + pieSliceData.endAngle).radians / 2.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    let width: CGFloat = min(geometry.size.width, geometry.size.height)
                    let height = width
                    path.move(
                        to: CGPoint(
                            x: width * 0.5,
                            y: height * 0.5
                        )
                    )
                    
                    path.addArc(center: CGPoint(x: width * 0.5, y: height * 0.5), radius: width * 0.5, startAngle: Angle(degrees: -90.0) + pieSliceData.startAngle, endAngle: Angle(degrees: -90.0) + pieSliceData.endAngle, clockwise: false)
                    
                }
                .fill(pieSliceData.color)
                
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct PieChartRows: View {
    var colors: [Color]
    var names: [String]
    var values: [Double]
    var percents: [String]
    
    var body: some View {
        VStack{
            ForEach(0..<self.values.count, id: \.self){ i in
                HStack {
                    RoundedRectangle(cornerRadius: 5.0)
                        .fill(self.colors[i])
                        .frame(width: 20, height: 20)
                    Text(self.names[i])
                        .foregroundColor(Color.gray)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(convertDoubleToCurrency(amount: values[i]))
                        if (values.count != 0){
                            if (values[0] != 0){
                                Text(self.percents[i])
                                    .foregroundColor(Color.gray)
                            } else {
                                Text("0%")
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

