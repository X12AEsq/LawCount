//
//  ExtDate.swift
//  QrBooks
//
//  Created by Morris Albers on 9/26/23.
//

import Foundation
struct ExtDate:Codable {
    static func == (lhs: ExtDate, rhs: ExtDate) -> Bool {
        return lhs.dateValue == rhs.dateValue
    }

    static func != (lhs: ExtDate, rhs: ExtDate) -> Bool {
        return lhs.dateValue != rhs.dateValue
    }

    static func > (lhs: ExtDate, rhs: ExtDate) -> Bool {
        return lhs.dateValue > rhs.dateValue
    }

    static func < (lhs: ExtDate, rhs: ExtDate) -> Bool {
        return lhs.dateValue < rhs.dateValue
    }

    static func >= (lhs: ExtDate, rhs: ExtDate) -> Bool {
        return lhs.dateValue >= rhs.dateValue
    }

    static func <= (lhs: ExtDate, rhs: ExtDate) -> Bool {
        return lhs.dateValue <= rhs.dateValue
    }
    
    var dateValue:Int

    var exdYYYY:String {
        "\(String(format: "%04d", self.dateValue / 10000))"
    }
    
    var exdMM:String {
        let j:Int = self.dateValue % 10000
        let i:Int = j / 100
        return "\(String(format: "%02d", i))"
    }
    
    var exdDD:String {
        let j = self.dateValue % 100
        return "\(String(format: "%02d", j))"
    }
    
    init(exdYYYY: String, exdMM: String, exdDD: String) {
        let tempYYYY:Int = Int(exdYYYY) ?? 0
        let tempMM:Int = Int(exdMM) ?? 0
        let tempDD:Int = Int(exdDD) ?? 0
        self.dateValue = (tempYYYY * 10000) + (tempMM) * 100 + tempDD
    }
    
    init() {
        self.dateValue = 0
    }
    
    init(dummy:Bool) {
        self.dateValue = 0
        if dummy {
            self.dateValue = 99995511
        }
    }
    
    init(rawDate:String) {
        var s:String = rawDate
        while s.count < 8 { s = s + "0" }
        var i = s.index(s.startIndex, offsetBy: 0)
        let y0 = String(s[i])
        i = s.index(s.startIndex, offsetBy: 1)
        let y1 = String(s[i])
        i = s.index(s.startIndex, offsetBy: 2)
        let y2 = String(s[i])
        i = s.index(s.startIndex, offsetBy: 3)
        let y3 = String(s[i])
        i = s.index(s.startIndex, offsetBy: 4)
        let m0 = String(s[i])
        i = s.index(s.startIndex, offsetBy: 5)
        let m1 = String(s[i])
        i = s.index(s.startIndex, offsetBy: 6)
        let d0 = String(s[i])
        i = s.index(s.startIndex, offsetBy: 7)
        let d1 = String(s[i])
        
        let tempYYYY = y0 + y1 + y2 + y3
        let tempMM = m0 + m1
        let tempDD = d0 + d1
        
        let iYYYY:Int = Int(tempYYYY) ?? 0
        let iMM:Int = Int(tempMM) ?? 0
        let iDD:Int = Int(tempDD) ?? 0
        self.dateValue = (iYYYY * 10000) + (iMM) * 100 + iDD

    }
    
    init(fmtDate:String) {
        let pieces:[String] = fmtDate.components(separatedBy: "/")
        if pieces.count > 2 {
            let tempYYYY = pieces[2]
            let tempMM = pieces[0]
            let tempDD = pieces[1]
            let iYYYY:Int = Int(tempYYYY) ?? 0
            let iMM:Int = Int(tempMM) ?? 0
            let iDD:Int = Int(tempDD) ?? 0
            self.dateValue = (iYYYY * 10000) + (iMM) * 100 + iDD
        } else {
            self.dateValue = 0
        }
    }
    
    init(appleDate:Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let returnDate = formatter.string(from: appleDate)
        let pieces:[String] = returnDate.components(separatedBy: "/")
        if pieces.count > 2 {
            let tempYYYY = pieces[0]
            let tempMM = pieces[1]
            let tempDD = pieces[2]
            let iYYYY:Int = Int(tempYYYY) ?? 0
            let iMM:Int = Int(tempMM) ?? 0
            let iDD:Int = Int(tempDD) ?? 0
            self.dateValue = (iYYYY * 10000) + (iMM) * 100 + iDD
        } else {
            self.dateValue = 0
        }
    }
    
    var exdDateRaw:String {
        let work:String = "\(String(format: "%08d", self.dateValue))"
        return work
    }
    
    var exdFormatted:String {
        var work:String = "\(String(format: "%04d", self.dateValue / 10000))"
        work = work + "/"
        var j:Int = self.dateValue % 10000
        let i:Int = j / 100
        work = work + "\(String(format: "%02d", i))"
        work = work + "/"
        j = self.dateValue % 100
        work = work + "\(String(format: "%02d", j))"
        return work

    }
    
    var isClear:Bool {
        return self.dateValue == 0
    }

}
