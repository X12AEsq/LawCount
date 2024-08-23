//
//  DateService.swift
//  npmb
//
//  Created by Morris Albers on 3/9/23.
//

import Foundation
struct DateService {
    
    public static var monthNames:[String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    public static func monthName(numMonth:Int) -> String {
        if numMonth < 1 || numMonth > 12 {
            return "Undefined"
        }
        return self.monthNames[numMonth - 1]
    }
    
    public static func todayMonthName() -> String {
        let work = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        let month:Int = work.month ?? 0
        return monthName(numMonth: month)
    }
    
    public static func todayYear() -> String {
        let work = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        let year:Int = work.year ?? 0
        let yearString:String = FormattingService.rjf(base: String(year), len: 4, zeroFill: true)
        return yearString
    }

    public static func trimStringDate(date:String) -> [String] {
        if date == "" { return ["", "", ""] }
        let trimmedDate = date.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedDate == "" { return ["", "", ""] }

        let pieces = trimmedDate.components(separatedBy: "-")
        if pieces.count == 3 { return pieces }
        if pieces.count == 2 { return [""] + pieces }
        if pieces.count == 1 { return ["",""] + pieces }
        return(["9999","99","99"])
    }
    
    public static func dateString2Date(inDate:String) -> Date {
        return dateString2Date(inDate: inDate, inTime: "120000")
    }
    
    public static func dateString2Date(inDate:Date, inTime:String) -> Date {
        var date:Date
        let stringDate:String = dateDate2String(inDate:inDate, short:true)
        date = dateString2Date(inDate: stringDate, inTime: inTime)
        return date
    }

    public static func dateString2Date(inDate:String, inTime:String) -> Date {
        var date:Date
        let trimmedDate:[String] = trimStringDate(date: inDate)
        let trimmedTime:String = FormattingService.rjf(base:inTime, len:4, zeroFill:true)
        let intTime:Int = Int(trimmedTime) ?? 9999
    
        var dy:Int = 0
        var dm:Int = 0
        var dd:Int = 0
        
        switch trimmedDate.count {
        case 1:
            dy = Int(trimmedDate[0]) ?? 9999
            dm = 99
            dd = 99
        case 2:
            dy = Int(trimmedDate[0]) ?? 9999
            dm = Int(trimmedDate[1]) ?? 99
            dd = 99
        case 3:
            dy = Int(trimmedDate[0]) ?? 9999
            dm = Int(trimmedDate[1]) ?? 99
            dd = Int(trimmedDate[2]) ?? 99
        default:
             dy = 9999
             dm = 99
             dd = 99
        }
        var components = DateComponents()
//        let work = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
 
        components.calendar = Calendar.current
        components.year = dy
        components.month = dm
        components.day = dd
        
        components.hour = intTime / 100
        components.minute = intTime % 100
        components.second = 0

        if components.isValidDate {
            date = components.date ?? Date()
            return date
        }
        return Date()
    }
//    
//    public static func dateDate2String(inYear:String, inMonth:String, inDay:String) -> Date {
//        var components = DateComponents()
//        let work = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
//        var date = Date()
//
//        components.calendar = Calendar.current
//        components.year = inYear == "" ? work.year : Int(inYear)
//        components.month = inMonth == "" ? work.month : Int(inMonth)
//        components.day = inDay == "" ? work.day : Int(inDay)
//        components.hour = 0
//        components.minute = 0
//        components.second = 0
//        if components.isValidDate {
//            date = components.date ?? Date()
//        }
//        return date
//    }
//    
    public static func dateDate2String(inDate:Date, short:Bool) -> String {
        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
        formatter.dateFormat = short ? "yyyyMMdd" : "yyyy-MM-dd"
        let returnDate = formatter.string(from: inDate)
        return returnDate
    }
    
    public static func dateTime2String(inDate:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        let work = formatter.string(from: inDate)
        return work
    }
}
