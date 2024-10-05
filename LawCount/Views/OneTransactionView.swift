//
//  OneTransactionView.swift
//  LawCount
//
//  Created by Morris Albers on 8/24/24.
//

import SwiftUI

struct OneTransactionView: View {
    @EnvironmentObject var cvmInstance:CVM
    @EnvironmentObject var nav:NavigationStateManager
    var nat:NewAccountTransaction
    @State var origTRX:FullTransaction = FullTransaction()
    @State var modTRX:FullTransaction = FullTransaction()
    @State var whichSegment:Int = 0
    @State var modSeqNr:Int = 0
    @State var modAccountNr:Int = 0
    @State var modAccountString:String = "0"
    @State var modAccountName = ""
    @State var modDebit:Money = Money()
    @State var modDebitString:String = ""
    @State var modCredit:Money = Money()
    @State var modCreditString:String = ""
    @State var changeIndicator:Bool = false
    @State var totalCredit:Money = Money()
    @State var totalDebit:Money = Money()
    @State var statusMessage:String = ""

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Text(cvmInstance.moduleTitle(mod: "Handle Transaction"))
                        .font(.system(size: 20))
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 10)
                if statusMessage != "" {
                    Text(statusMessage)
                        .font(.system(size: 20))
                }
                Text("Original")
                    .padding(.leading, 20)
                HStack {
                    Text(String(origTRX.ftxTrans.NATSeqNr))
                    if origTRX.ftxTrans.NATProcessed {
                        Text("Processed")
                    } else {
                        Text("Not Processed")
                    }
                    Text(origTRX.ftxTrans.NATDate.exdFormatted)
                    Text(origTRX.ftxTrans.NATType)
                    Text(origTRX.ftxTrans.NATNum)
                    Text(origTRX.ftxTrans.NATName)
                    Spacer()
                }
                .padding(.leading, 20)
                ForEach(origTRX.ftxSegs, id: \.self) { seg in
                    HStack {
                        Text(String(seg.NTSSeqNr))
                        Text(String(seg.NTSAccountNr))
                        Text(seg.NTSAccountName)
                        Text(seg.NTSDebit.rawMoney11)
                        Text(seg.NTSCredit.rawMoney11)
                        Spacer()
                    }
                    .padding(.leading, 10)
                }
                .padding(.leading, 20)
            }
            .padding(.bottom, 20)
            if !origTRX.ftxTrans.NATProcessed {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Modified")
                        Text("Total Debits: \(totalDebit.rawMoney11)")
                        Text("Total Credits: \(totalCredit.rawMoney11)")
                        if changeIndicator {
                            Button(action: {
                                let edit = editTransaction()
                                if edit.status == 0 {
                                    modTRX.ftxTrans.NATProcessed = true
                                    cvmInstance.updateFullTrans(inTrans: modTRX)
                                    if nav.selectionPath.count > 0 {
                                        nav.selectionPath.removeLast()
                                    } else {
                                        nav.popToRoot()
                                    }
                                    print("XX")
                                } else {
                                    statusMessage = edit.descr
                                }
                            }) {
                                Text("Save transaction")
                            }
                            .buttonStyle(CustomButton4())
                        }
                    }
                    .padding(.leading, 20)
                    HStack {
                        Text(String(modTRX.ftxTrans.NATSeqNr))
                        if modTRX.ftxTrans.NATProcessed {
                            Text("Processed")
                        } else {
                            Text("Not Processed")
                        }
                        Text(modTRX.ftxTrans.NATDate.exdFormatted)
                        Text(modTRX.ftxTrans.NATType)
                        Text(modTRX.ftxTrans.NATNum)
                        Text(modTRX.ftxTrans.NATName)
                        Spacer()
                    }
                    .padding(.leading, 20)
                    ForEach(modTRX.ftxSegs, id: \.self) { seg in
                        HStack {
                            Button(action: {
                                whichSegment = seq2sub(seq: seg.NTSSeqNr)
                                modSeqNr = modTRX.ftxSegs[whichSegment].NTSSeqNr
                                modAccountNr = modTRX.ftxSegs[whichSegment].NTSAccountNr
                                modAccountString = String(modAccountNr)
                                modAccountName = modTRX.ftxSegs[whichSegment].NTSAccountName
                                modCredit = modTRX.ftxSegs[whichSegment].NTSCredit
                                modDebit = modTRX.ftxSegs[whichSegment].NTSDebit
                                modDebitString = String(modDebit.moneyAmount)
                                modCreditString = String(modCredit.moneyAmount)
                            }) {
                                Text(String(seg.NTSSeqNr))
                            }
                            .buttonStyle(CustomButton4())
                            Text(String(seg.NTSAccountNr))
                            Text(seg.NTSAccountName)
                            Text(seg.NTSDebit.rawMoney11)
                            Text(seg.NTSCredit.rawMoney11)
                            Spacer()
                        }
                        .padding(.leading, 20)
                    }
                    .padding(.leading, 20)
                }
                VStack(alignment: .leading) {
                    if whichSegment >= 0 {
                        Text("Segment Entry")
                        GeometryReader { geo in
                            HStack {
                                Text("Account Number:")
                                TextField("Number", text: $modAccountString, onEditingChanged: { (editingChanged) in
                                    if !editingChanged {
                                        print("TextField focus removed")
                                        let tempNr:Int = Int(modAccountString) ?? -1
                                        let tempResult = cvmInstance.retrieveAccount(acctNr: tempNr)
                                        if tempResult.status == 0 {
                                            modAccountNr = tempNr
                                            modAccountName = tempResult.acctName
                                        }
                                    }
                                })
                                .frame(width: geo.size.width * 0.075)
                                Text(modAccountName)
                                Text("Debit \(modDebit.rawMoney11):")
                                TextField("Digits", text: $modDebitString, onEditingChanged: { (editingChanged) in
                                    if !editingChanged {
                                        print(modDebitString)
                                        print("xx")
                                    }
                                })
                                .frame(width: geo.size.width * 0.1)
                                
                                Text("Credit \(modCredit.rawMoney11):")
                                TextField("Digits", text: $modCreditString, onEditingChanged: { (editingChanged) in
                                    if !editingChanged {
                                        print(modCreditString)
                                        print("xx")
                                    }
                                })
                                .frame(width: geo.size.width * 0.1)
                                Button(action: {
                                    modTRX.ftxSegs[whichSegment].NTSAccountNr = modAccountNr
                                    modTRX.ftxSegs[whichSegment].NTSAccountName = modAccountName
                                    modTRX.ftxSegs[whichSegment].NTSCredit = modCredit
                                    modTRX.ftxSegs[whichSegment].NTSDebit = modDebit
                                    whichSegment = -1
                                    changeIndicator = didChange()
                                }) {
                                    Text("Save Segment")
                                }
                                .buttonStyle(CustomButton4())
                                
                            }
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.top, 20)
            }
            Spacer()
        }.onAppear(perform: {
            origTRX.ftxTrans = nat
            origTRX.ftxSegs = cvmInstance.cvmNewSegments.filter({$0.NTSParentTransaction == nat.NATSeqNr}).sorted(by: { $0.NTSSeqNr < $1.NTSSeqNr } )
            modTRX = origTRX
            preEdit()
            whichSegment = -1
            statusMessage = ""
        })
    }
    
    func preEdit() {
        for i in 0 ... modTRX.ftxSegs.count - 1 {
            if modTRX.ftxSegs[i].NTSAccountName == "Reimbursement Owed:Owed to Morris Personally" {
                modTRX.ftxSegs[i].NTSAccountNr = 4300
                modTRX.ftxSegs[i].NTSAccountName = "Equity Account: Morris"
                changeIndicator = true
                continue
            }
            if modTRX.ftxSegs[i].NTSAccountName == "NBT Operating Account" {
                modTRX.ftxSegs[i].NTSAccountNr = 1100
                modTRX.ftxSegs[i].NTSAccountName = "Cash in Bank"
                changeIndicator = true
                continue
            }
            if modTRX.ftxSegs[i].NTSAccountName == "Reimbursement Owed:Owed to Family Brokerage Acct" {
                modTRX.ftxSegs[i].NTSAccountNr = 4320
                modTRX.ftxSegs[i].NTSAccountName = "Equity Account: Family"
                changeIndicator = true
                continue
            }
            if modTRX.ftxSegs[i].NTSAccountName == "Rent Expense" {
                modTRX.ftxSegs[i].NTSAccountNr = 6520
                modTRX.ftxSegs[i].NTSAccountName = "Office Rent"
                changeIndicator = true
                continue
            }
            if modTRX.ftxSegs[i].NTSAccountName == "Accounts Payable" {
                modTRX.ftxSegs[i].NTSAccountNr = 2200
                modTRX.ftxSegs[i].NTSAccountName = "Accounts Payable"
                changeIndicator = true
                continue
            }
            if modTRX.ftxSegs[i].NTSAccountName == "Insurance Expense" {
                modTRX.ftxSegs[i].NTSAccountNr = 9580
                modTRX.ftxSegs[i].NTSAccountName = "Insurance: Professional/Other"
                changeIndicator = true
                continue
            }
            if modTRX.ftxSegs[i].NTSAccountName == "Furniture and Equipment" {
                modTRX.ftxSegs[i].NTSAccountNr = 1150
                modTRX.ftxSegs[i].NTSAccountName = "Furniture Fixtures & Equipment"
                changeIndicator = true
                continue
            }
            if modTRX.ftxSegs[i].NTSAccountName == "Telephone Expense:Wireless" {
                modTRX.ftxSegs[i].NTSAccountNr = 7543
                modTRX.ftxSegs[i].NTSAccountName = "Telephone/Communications"
                changeIndicator = true
                continue
            }
            if modTRX.ftxSegs[i].NTSAccountName == "Dues and Subscriptions" {
                modTRX.ftxSegs[i].NTSAccountNr = 7542
                modTRX.ftxSegs[i].NTSAccountName = "Library & Subscriptions"
                changeIndicator = true
                continue
            }
            if modTRX.ftxSegs[i].NTSAccountName == "Postage and Delivery" {
                modTRX.ftxSegs[i].NTSAccountNr = 7541
                modTRX.ftxSegs[i].NTSAccountName = "Postage & Delivery"
                changeIndicator = true
                continue
            }
            if modTRX.ftxSegs[i].NTSAccountName == "Taxes:Taxes-Texas Professional" {
                modTRX.ftxSegs[i].NTSAccountNr = 9581
                modTRX.ftxSegs[i].NTSAccountName = "Other Taxes and Similar Costs"
                changeIndicator = true
                continue
            }
        }
    }
        
    func seq2sub(seq:Int) -> Int {
        var i:Int = 0
        while i < origTRX.ftxSegs.count {
            if origTRX.ftxSegs[i].NTSSeqNr == seq {
                return i
            }
            i += 1
        }
        return -1
    }
    
    func didChange() -> Bool {
        var i = 0
        var workDebit:Money = Money()
        var workCredit:Money = Money()
        
        while i < origTRX.ftxSegs.count {
            workDebit = origTRX.ftxSegs[i].NTSDebit + workDebit
            i += 1
        }
        i = 0

        while i < origTRX.ftxSegs.count {
            workCredit = origTRX.ftxSegs[i].NTSDebit + workCredit
            i += 1
        }
        i = 0
        
        totalDebit = workDebit
        totalCredit = workCredit

        if origTRX.ftxSegs.count != modTRX.ftxSegs.count { return true }
        origTRX.ftxSegs = origTRX.ftxSegs.sorted(by: { $0.NTSSeqNr < $1.NTSSeqNr } )
        modTRX.ftxSegs = modTRX.ftxSegs.sorted(by: { $0.NTSSeqNr < $1.NTSSeqNr } )
        while i < origTRX.ftxSegs.count {
            if origTRX.ftxSegs[i].NTSSeqNr != modTRX.ftxSegs[i].NTSSeqNr { return true }
            if origTRX.ftxSegs[i].NTSAccountNr != modTRX.ftxSegs[i].NTSAccountNr { return true }
            if origTRX.ftxSegs[i].NTSAccountName != modTRX.ftxSegs[i].NTSAccountName { return true }
            if origTRX.ftxSegs[i].NTSCredit != modTRX.ftxSegs[i].NTSCredit { return true }
            if origTRX.ftxSegs[i].NTSDebit != modTRX.ftxSegs[i].NTSDebit { return true }
            i += 1
        }
        return false
    }
    
    func editTransaction() -> (status:Int, descr:String) {
        if totalDebit != totalCredit { return (-1, "Transaction out of balance") }
        var i = 0
        while i < modTRX.ftxSegs.count {
            let acctStatus = cvmInstance.retrieveAccount(acctNr: modTRX.ftxSegs[i].NTSAccountNr)
            if acctStatus.status != 0 { return (-2, "\(modTRX.ftxSegs[i].NTSAccountName) has invalid account number") }
            i += 1
        }
        return (0, "")
    }
}

//#Preview {
//    OneTransactionView(, itr: IJTrans()
//}
