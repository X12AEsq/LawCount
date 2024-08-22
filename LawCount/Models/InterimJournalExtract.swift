//
//  InterimJournalExtract.swift
//  QkBooks
//
//  Created by Morris Albers on 10/17/23.
//

import Foundation

// *Date*Transaction Type*Num*Name*Memo/Description*Account*Debit*Credit

struct IJXtract: Codable {
    var ijxSeqNr:Int = 0
    var ijxDate:ExtDate = ExtDate()
    var ijxType:String = ""
    var ijxNum:String = ""
    var ijxName:String = ""
    var ijxMemo:String = ""
    var ijxAccountNr:Int = 0
    var ijxAccountName = ""
    var ijxDebit:Money = Money()
    var ijxCredit:Money = Money()
    
    init(ijxSeqNr: Int, ijxDate: ExtDate, ijxType: String, ijxNum: String, ijxName: String, ijxMemo: String, ijxAccountNr: Int, ijxAccountName: String = "", ijxDebit: Money, ijxCredit: Money) {
        self.ijxSeqNr = ijxSeqNr
        self.ijxDate = ijxDate
        self.ijxType = ijxType
        self.ijxNum = ijxNum
        self.ijxName = ijxName
        self.ijxMemo = ijxMemo
        self.ijxAccountNr = ijxAccountNr
        self.ijxAccountName = ijxAccountName
        self.ijxDebit = ijxDebit
        self.ijxCredit = ijxCredit
    }
    
    init() {
        self.ijxSeqNr = 0
        self.ijxDate = ExtDate()
        self.ijxType = ""
        self.ijxNum = ""
        self.ijxName = ""
        self.ijxMemo = ""
        self.ijxAccountNr = 0
        self.ijxAccountName = ""
        self.ijxDebit = Money()
        self.ijxCredit = Money()
    }

    
    
    var printLine:String {
        let xC:String = "\(String(format: "%08d", ijxSeqNr))"
        var printLine = xC + " "
        printLine += ijxDate.exdFormatted + " "
        
        var ss:String = ijxType
        while ss.count < 6 { ss = ss + " " }
        while ss.count > 6 { ss.removeLast() }
        printLine = printLine + ss + " "
        
        ss = ijxNum
        while ss.count < 6 { ss = ss + " " }
        while ss.count > 6 { ss.removeLast() }
        printLine = printLine + ss + " "
        
        ss = ijxName
        while ss.count < 25 { ss = ss + " " }
        while ss.count > 25 { ss.removeLast() }
        printLine = printLine + ss + " "
        
        ss = ijxMemo
        while ss.count < 6 { ss = ss + " " }
        while ss.count > 6 { ss.removeLast() }
        printLine = printLine + ss + " "

//        printLine += ijxAccountNr.canFormat1 + " "
        
        
        ss = ijxAccountName
        while ss.count < 25 { ss = ss + " " }
        while ss.count > 25 { ss.removeLast() }
        printLine = printLine + ss + " "

        printLine += ijxDebit.rawMoney + " "
        
        printLine += ijxCredit.rawMoney
        return printLine

    }
}
