//
//  NewTransactionSegment.swift
//  LawCount
//
//  Created by Morris Albers on 8/27/24.
//

import Foundation
import SwiftData

struct NewTransactionSegment: Codable, Hashable {
    static func == (lhs: NewTransactionSegment, rhs: NewTransactionSegment) -> Bool {
        return lhs.NTSAccountNr == rhs.NTSAccountNr &&
        lhs.NTSAccountName == rhs.NTSAccountName &&
        lhs.NTSParentTransaction == rhs.NTSParentTransaction
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(NTSAccountNr)
    }
    var NTSParentTransaction:Int = 0
    var NTSSeqNr:Int = 0
    var NTSAccountNr:Int = 0
    var NTSAccountName = ""
    var NTSDebit:Money = Money()
    var NTSCredit:Money = Money()
    
    init(NTSParentTransaction: Int, NTSSeqNr: Int, NTSAccountNr: Int, NTSAccountName: String = "", NTSDebit: Money, NTSCredit: Money) {
        self.NTSParentTransaction = NTSParentTransaction
        self.NTSSeqNr = NTSSeqNr
        self.NTSAccountNr = NTSAccountNr
        self.NTSAccountName = NTSAccountName
        self.NTSDebit = NTSDebit
        self.NTSCredit = NTSCredit
    }
    
    init() {
        self.NTSParentTransaction = 0
        self.NTSSeqNr = 0
        self.NTSAccountNr = 0
        self.NTSAccountName = ""
        self.NTSDebit = Money()
        self.NTSCredit = Money()
    }
}

