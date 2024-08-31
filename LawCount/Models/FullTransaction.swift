//
//  FullTransaction.swift
//  LawCount
//
//  Created by Morris Albers on 8/28/24.
//

import Foundation
import SwiftData

struct FullTransaction {
    var ftxTrans: NewAccountTransaction
    var ftxSegs: [NewTransactionSegment]
    
    init(ftxTrans: NewAccountTransaction, ftxSegs: [NewTransactionSegment]) {
        self.ftxTrans = ftxTrans
        self.ftxSegs = ftxSegs
    }
    
    init() {
        self.ftxTrans = NewAccountTransaction()
        self.ftxSegs = [NewTransactionSegment]()
    }
}
