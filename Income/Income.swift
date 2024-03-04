//
//  Income.swift
//  MoneyTracker
//
//  Created by Muhannad Qaisi on 3/3/24.
//

import Foundation
import SwiftData

@Model final public class Income {
    
    var name: String = "Paycheck"
    
    var amount: Decimal = Decimal.zero
    
    public init() {
        
    }
}
