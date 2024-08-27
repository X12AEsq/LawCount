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
        return lhs.NTSSeqNr == rhs.NTSSeqNr
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(NTSSeqNr)
    }

    var NTSSeqNr:Int = 0
    var NTSProcessed:Bool = false
    var NTSDate:ExtDate = ExtDate()
    var NTSType:String = ""
    var NTSNum:String = ""
    var NTSName:String = ""
    
    init(NTSSeqNr: Int, NTSProcessed: Bool, NTSDate: ExtDate, NTSType: String, NTSNum: String, NTSName: String) {
        self.NTSSeqNr = NTSSeqNr
        self.NTSProcessed = NTSProcessed
        self.NTSDate = NTSDate
        self.NTSType = NTSType
        self.NTSNum = NTSNum
        self.NTSName = NTSName
    }
    
    init() {
        self.NTSSeqNr = 0
        self.NTSProcessed = false
        self.NTSDate = ExtDate()
        self.NTSType = ""
        self.NTSNum = ""
        self.NTSName = ""
    }

    @Transient var shortPrintLine:String {
        var pl:String = FormattingService.rjf(base: String(NTSSeqNr), len: 5, zeroFill: true)
        pl += " "
        pl += FormattingService.ljf(base: NTSDate.exdFormatted, len: 11)
        pl += " "
        pl += FormattingService.ljf(base: NTSType, len: 20)
        pl += " "
        pl += FormattingService.ljf(base: NTSNum, len: 15)
        pl += " "
        pl += FormattingService.ljf(base: NTSName, len: 25)
        return pl
    }
}
