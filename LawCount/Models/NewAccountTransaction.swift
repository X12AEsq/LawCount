//
//  NewAccountTransaction.swift
//  LawCount
//
//  Created by Morris Albers on 8/27/24.
//

import Foundation
import SwiftData

struct NewAccountTransaction: Codable, Hashable {
    static func == (lhs: NewAccountTransaction, rhs: NewAccountTransaction) -> Bool {
        return lhs.NATSeqNr == rhs.NATSeqNr
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(NATSeqNr)
    }

    var NATSeqNr:Int = 0
    var NATProcessed:Bool = false
    var NATDate:ExtDate = ExtDate()
    var NATType:String = ""
    var NATNum:String = ""
    var NATName:String = ""
    
    init(NATSeqNr: Int, NATProcessed: Bool, NATDate: ExtDate, NATType: String, NATNum: String, NATName: String) {
        self.NATSeqNr = NATSeqNr
        self.NATProcessed = NATProcessed
        self.NATDate = NATDate
        self.NATType = NATType
        self.NATNum = NATNum
        self.NATName = NATName
    }
    
    init() {
        self.NATSeqNr = 0
        self.NATProcessed = false
        self.NATDate = ExtDate()
        self.NATType = ""
        self.NATNum = ""
        self.NATName = ""
    }

    @Transient var shortPrintLine:String {
        var pl:String = FormattingService.rjf(base: String(NATSeqNr), len: 5, zeroFill: true)
        pl += " "
        pl += FormattingService.ljf(base: NATDate.exdFormatted, len: 11)
        pl += " "
        pl += FormattingService.ljf(base: NATType, len: 20)
        pl += " "
        pl += FormattingService.ljf(base: NATNum, len: 15)
        pl += " "
        pl += FormattingService.ljf(base: NATName, len: 25)
        return pl
    }
}
