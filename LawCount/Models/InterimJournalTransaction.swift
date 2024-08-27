//
//  InterimJournalTransaction.swift
//  LawCount
//
//  Created by Morris Albers on 8/21/24.
//

import Foundation
import SwiftData

struct IJTrans: Codable, Hashable {
    static func == (lhs: IJTrans, rhs: IJTrans) -> Bool {
        return lhs.IJTSeqNr == rhs.IJTSeqNr
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(IJTSeqNr)
    }
    
    struct IJTSegment: Codable, Hashable {
        static func == (lhs: IJTSegment, rhs: IJTSegment) -> Bool {
            return lhs.IJTSAccountNr == rhs.IJTSAccountNr &&
            lhs.IJTSAccountName == rhs.IJTSAccountName
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(IJTSAccountNr)
        }
        var IJTSAccountNr:Int = 0
        var IJTSAccountName = ""
        var IJTSDebit:Money = Money()
        var IJTSCredit:Money = Money()
        
        init(IJTSAccountNr: Int, IJTSAccountName: String = "", IJTSDebit: Money, IJTSCredit: Money) {
            self.IJTSAccountNr = IJTSAccountNr
            self.IJTSAccountName = IJTSAccountName
            self.IJTSDebit = IJTSDebit
            self.IJTSCredit = IJTSCredit
        }
        
        init() {
            self.IJTSAccountNr = 0
            self.IJTSAccountName = ""
            self.IJTSDebit = Money()
            self.IJTSCredit = Money()
        }
    }
    
    var IJTSeqNr:Int = 0
    var IJTDate:ExtDate = ExtDate()
    var IJTType:String = ""
    var IJTNum:String = ""
    var IJTName:String = ""
    var IJTSegments:[IJTSegment] = []
    
    @Transient var shortPrintLine:String {
        var pl:String = FormattingService.rjf(base: String(IJTSeqNr), len: 5, zeroFill: true)
        pl += " "
        pl += FormattingService.ljf(base: IJTDate.exdFormatted, len: 11)
        pl += " "
        pl += FormattingService.ljf(base: IJTType, len: 20)
        pl += " "
        pl += FormattingService.ljf(base: IJTNum, len: 15)
        pl += " "
        pl += FormattingService.ljf(base: IJTName, len: 25)
        return pl
    }
}
