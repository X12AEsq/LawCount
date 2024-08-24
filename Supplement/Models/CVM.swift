//
//  CVM.swift
//  LawCount
//
//  Created by Morris Albers on 8/21/24.
//

import Foundation
import SwiftUI
import SwiftData

//@Observable
class CVM: ObservableObject {
    var cvmSelection:Int = 0
    var cvmTransactions:[IJTrans] = []
    var cvmCOA:ICAChartOfAccounts = ICAChartOfAccounts()
    
    init(cvmTransactions: [IJTrans], cvmCOA: ICAChartOfAccounts) {
        self.cvmTransactions = cvmTransactions
        self.cvmCOA = cvmCOA
    }
    
    init() {
        self.cvmTransactions = []
        self.cvmCOA = ICAChartOfAccounts()
    }

//    var lastAccountNumber:ConvAcctNumber = ConvAcctNumber()
//    var lastAccountArray:[String] = []
}

