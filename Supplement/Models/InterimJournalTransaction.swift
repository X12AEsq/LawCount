//
//  InterimJournalTransaction.swift
//  LawCount
//
//  Created by Morris Albers on 8/21/24.
//

import Foundation
struct IJTrans: Codable {
    struct IJTSegment: Codable {
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

}
