//
//  Money.swift
//  QrBooks
//
//  Created by Morris Albers on 9/26/23.
//

import Foundation
struct Money:Codable {
    static func == (lhs: Money, rhs: Money) -> Bool {
        lhs.moneyAmount == rhs.moneyAmount
    }

    static func != (lhs: Money, rhs: Money) -> Bool {
        lhs.moneyAmount != rhs.moneyAmount
    }

    static func + (lhs: Money, rhs: Money) -> Money {
        let work:Int = lhs.moneyAmount + rhs.moneyAmount
        let sign:Int = work > 0 ? 1 : -1
        return Money(moneyDollars: work/100, moneyCents: work%100, moneySign: sign)
    }
    
    static func - (lhs: Money, rhs: Money) -> Money {
        let work:Int = lhs.moneyAmount - rhs.moneyAmount
        let sign:Int = work > 0 ? 1 : -1
        return Money(moneyDollars: work/100, moneyCents: work%100, moneySign: sign)
    }

    var moneyAmount:Int
    
    var isZero:Bool {
        return self.moneyAmount == 0
    }
    
    init(moneyDollars: Int, moneyCents: Int, moneySign: Int) {
        self.moneyAmount = moneyDollars * 100 + moneyCents
        if moneySign < 0 {
            if self.moneyAmount > 0 {
                self.moneyAmount = self.moneyAmount * -1 }
        }
     }
    
    init(moneyAmount: Int) {
        self.moneyAmount = moneyAmount
    }
    
    var rawMoney:String {
        let xC:String = "\(String(format: "%02d", abs(self.moneyAmount % 100)))"
        let xD:String = "\(String(format: "%8d", self.moneyAmount / 100))"
        return xD + "." + xC
    }
    
    var rawMoney11:String {
        let work:String = self.rawMoney.trimmingCharacters(in: .whitespacesAndNewlines)
        let workArray = Array(work)
        var filteredArray:[Character] = []
        var i = workArray.count - 1
        var j = 0;
        var foundDecimalLoc:Int = -1
        while j < i {
            if workArray[j] == "." {
                foundDecimalLoc = j
            }
            j += 1
        }
        
        if foundDecimalLoc >= 0 {
            j = i
            while j >= foundDecimalLoc {
                let found:Character = workArray[j]
                filteredArray.append(found)
                j -= 1
            }
        } else {
            j = workArray.count
        }
        
//        j -= 1
        
        while j >= 0 {
            filteredArray.append(workArray[j])
            j -= 1
            if j >= 0 {
                filteredArray.append(workArray[j])
                j -= 1
                if j >= 0 {
                    filteredArray.append(workArray[j])
                    j -= 1
                    if j >= 0 {
                        filteredArray.append(",")
                    }
                }
            }
        }
        
        i = filteredArray.count - 1
        var workOut:String = ""
        
        while i >= 0 {
            workOut = workOut + String(filteredArray[i])
            i -= 1
        }
        
        while workOut.count < 11 { workOut = " " + workOut }
        return workOut
    }
    
    init() {
        self.moneyAmount = 0
    }
    
    init(moneyDollars: String, moneyCents: String) {
        let workDollars = Int(moneyDollars.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let workCents = Int(moneyCents.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        self.moneyAmount = workDollars * 100 + workCents
        if moneyDollars.contains("-") || moneyCents.contains("-") {
            if self.moneyAmount > 0 {
                self.moneyAmount = self.moneyAmount * -1
            }
        }
    }
    
    init(stringAmount:String) {
        var workingAmount:String = stringAmount
        while workingAmount.contains(",") {
            if let i = workingAmount.firstIndex(of: ",") {
                workingAmount.remove(at: i)
            }
        }
        while workingAmount.contains("\"") {
            if let i = workingAmount.firstIndex(of: "\"") {
                workingAmount.remove(at: i)
            }
        }
        let pieces:[String] = workingAmount.components(separatedBy: ".")
        var dollars:Int = 0
        var cents:Int = 0
        var sign:Int = 0
        if pieces.count > 0 {
            dollars = Int(pieces[0].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            if pieces.count > 1 {
                cents = Int(pieces[1].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            } else {
                cents = 0
            }
            if pieces[0].contains("-") {
                dollars = abs(dollars)
                sign = -1
            } else {
                sign = 1
            }
        } else {
            dollars = 0
            cents = 0
        }
        self.moneyAmount = dollars * 100 + cents
        if sign < 0 {
            if self.moneyAmount > 0 {
                self.moneyAmount = self.moneyAmount * -1
            }
        }
    }
}
