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
    var cvmTransactionCount:Int = 0
    var cvmAccountCount:Int = 0
    
    var cvmNewTrans:[NewAccountTransaction] = []
    var cvmNewSegments:[NewTransactionSegment] = []
    var cvmNewGroup:[NewAccountGroup] = []
    var cvmNewAccount:[NewAccountRecord] = []
    
    init(cvmTransactions: [IJTrans], cvmCOA: ICAChartOfAccounts) {
        self.cvmTransactions = cvmTransactions
        self.cvmCOA = cvmCOA
        self.cvmTransactionCount = self.cvmTransactions.count
        self.cvmAccountCount = self.accountCount()
    }
    
    init() {
        self.cvmTransactions = []
        self.cvmCOA = ICAChartOfAccounts()
        self.cvmTransactionCount = self.cvmTransactions.count
        self.cvmAccountCount = self.accountCount()
    }
    
    func accountCount() -> Int {
        var count:Int = 0
        for ICAG in cvmCOA.ICAGroups {
            count += ICAG.ICAGAccounts.count
        }
        return count
    }
    
    func selectedPractice() -> String {
            return "Morris E. Albers II, Attorney and Counsellor at Law, PLLC"
    }
    
    func moduleTitle(mod:String) -> String {
        return selectedPractice() + " " + mod
    }
    
    func retrieveAccount(acctNr: Int) -> (status:Int, acct:NewAccountRecord, acctName:String, acctOffset:Int) {
        struct acctInfo {
            var acct:NewAccountRecord = NewAccountRecord()
            var subs:Int = 0
        }
        var tempAccounts:[acctInfo] = []
//        var tempAccounts:[NewAccountRecord] = [NewAccountRecord]()
        for i in 0 ... self.cvmNewAccount.count - 1 {
            if self.cvmNewAccount[i].NARAAccountNr == acctNr {
                tempAccounts.append(acctInfo(acct:self.cvmNewAccount[i], subs:i))
            }
        }
        switch tempAccounts.count {
        case 0:
            return(-2, NewAccountRecord(), "None found", -1)
        case 1:
            return(0, tempAccounts[0].acct, tempAccounts[0].acct.NARAAccountName, tempAccounts[0].subs)
        default:
            return(-3, NewAccountRecord(), "Multiples found", -1)
        }
    }
    
    func updateFullTrans(inTrans:FullTransaction) {
/*
 update the transaction main with whatever, likely including the "processed" status
 update each segment with individual changes
 update each account with the associated segment
 */
        struct pending {
            var absSegment:Int = 0
            var oldSegment:Int = 0
            var oldAcct:Int = 0
        }
        var components:[pending] = []
        let transStatus = self.retrieveTransaction(tranNr: inTrans.ftxTrans.NATSeqNr)
        if transStatus.status != 0 { return }
        for i in 0 ... inTrans.ftxSegs.count - 1 {
            let segStatus = self.retrieveSegment(transNr: inTrans.ftxTrans.NATSeqNr, segNr: inTrans.ftxSegs[i].NTSSeqNr)
            if segStatus.status != 0 { return }
//     (status:Int, acct:NewAccountRecord, acctName:String, acctOffset:Int) {
//     (status:Int, trans:NewTransactionSegment, message:String, segOffset:Int) {
            let acctStatus = self.retrieveAccount(acctNr: inTrans.ftxSegs[i].NTSAccountNr)
            if acctStatus.status != 0 { return }
            components.append(pending(absSegment:segStatus.segOffset, oldSegment: i, oldAcct: acctStatus.acctOffset))
        }
/*
 transStatus.transOffset has the subscript for the parent transaction
 each pending in components has the subscript for the relevant segment, and the associated account
 */
        for i in 0 ... components.count - 1 {
            cvmNewAccount[components[i].oldAcct].NARACredit =
                cvmNewAccount[components[i].oldAcct].NARACredit +
                inTrans.ftxSegs[components[i].oldSegment].NTSCredit
            cvmNewAccount[components[i].oldAcct].NARADebit =
                cvmNewAccount[components[i].oldAcct].NARADebit +
                inTrans.ftxSegs[components[i].oldSegment].NTSDebit
            cvmNewSegments[components[i].absSegment].NTSAccountNr =
                inTrans.ftxSegs[components[i].oldSegment].NTSAccountNr
            cvmNewSegments[components[i].absSegment].NTSAccountName =
                inTrans.ftxSegs[components[i].oldSegment].NTSAccountName
        }
        cvmNewTrans[transStatus.transOffset].NATProcessed = true
        return
    }
    
    
    func retrieveTransaction(tranNr: Int) -> (status:Int, trans:NewAccountTransaction, message:String, transOffset:Int) {
        struct tranInfo {
            var tran:NewAccountTransaction = NewAccountTransaction()
            var subs:Int = 0
        }
        var tempTrans:[tranInfo] = []
        for i in 0 ... self.cvmNewTrans.count - 1 {
            if self.cvmNewTrans[i].NATSeqNr == tranNr {
                tempTrans.append(tranInfo(tran: self.cvmNewTrans[i], subs: i))
            }
        }
        switch tempTrans.count {
        case 0:
            return(-2, NewAccountTransaction(), "None Found", -1)
        case 1:
            return(0, tempTrans[0].tran, "", tempTrans[0].subs)
        default:
            return(-3, NewAccountTransaction(), "Multiples Found", -1)
        }
    }
    
    func retrieveSegment(transNr:Int, segNr:Int) -> (status:Int, trans:NewTransactionSegment, message:String, segOffset:Int) {
        struct segmentInfo {
            var segment:NewTransactionSegment = NewTransactionSegment()
            var subscr:Int = 0
        }
        var tempSegments:[segmentInfo] = []
        for i in 0 ... self.cvmNewSegments.count - 1 {
            if self.cvmNewSegments[i].NTSParentTransaction == transNr
                && self.cvmNewSegments[i].NTSSeqNr == segNr {
                tempSegments.append(segmentInfo(segment: cvmNewSegments[i], subscr: i))
            }
        }
        switch tempSegments.count {
        case 0:
            return(-2, NewTransactionSegment(), "None Found", -1)
        case 1:
            return(0, tempSegments[0].segment, "", tempSegments[0].subscr)
        default:
            return(-2, NewTransactionSegment(), "Multiples Found", -1)
        }
    }
    
    func readJSON() {
        let decoder = JSONDecoder()
        
        do {
            let url = URL.documentsDirectory.appending(path: "COA.json")
            let input = try Data(contentsOf: url)
            self.cvmCOA = try decoder.decode(ICAChartOfAccounts.self, from: input)
            print("xxx")
            //                    var coadata = try decoder.decode(cvm.cvmCOA)
        } catch {
            print(error.localizedDescription)
        }
        self.cvmAccountCount = self.accountCount()
        
        do {
            let url = URL.documentsDirectory.appending(path: "Transactions.json")
            let input = try Data(contentsOf: url)
            self.cvmTransactions = try decoder.decode([IJTrans].self, from: input)
            print("xxx")
            //                    var coadata = try decoder.decode(cvm.cvmCOA)
        } catch {
            print(error.localizedDescription)
        }
        self.cvmTransactionCount = self.cvmTransactions.count
    }
    
    func writeJSON() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let url = URL.documentsDirectory.appending(path: "COA.json")
            let data = try encoder.encode(self.cvmCOA)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            let url = URL.documentsDirectory.appending(path: "Transactions.json")
            let data = try encoder.encode(self.cvmTransactions)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func writeNewJSON() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let url = URL.documentsDirectory.appending(path: "NewGroups.json")
            let data = try encoder.encode(self.cvmNewGroup)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print(error.localizedDescription)
        }

        do {
            let url = URL.documentsDirectory.appending(path: "NewAccounts.json")
            let data = try encoder.encode(self.cvmNewAccount)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print(error.localizedDescription)
        }

        do {
            let url = URL.documentsDirectory.appending(path: "NewTrans.json")
            let data = try encoder.encode(self.cvmNewTrans)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print(error.localizedDescription)
        }

        do {
            let url = URL.documentsDirectory.appending(path: "NewSegments.json")
            let data = try encoder.encode(self.cvmNewSegments)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func readNewJSON() {
        let decoder = JSONDecoder()
        
        do {
            let url = URL.documentsDirectory.appending(path: "NewGroups.json")
            let input = try Data(contentsOf: url)
            self.cvmNewGroup = try decoder.decode([NewAccountGroup].self, from: input)
            self.cvmNewGroup = self.cvmNewGroup.sorted(by: { $0.NAGroupNr < $1.NAGroupNr } )
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            let url = URL.documentsDirectory.appending(path: "NewAccounts.json")
            let input = try Data(contentsOf: url)
            self.cvmNewAccount = try decoder.decode([NewAccountRecord].self, from: input)
            self.cvmNewAccount = self.cvmNewAccount.sorted(by: { $0.NARAAccountNr < $1.NARAAccountNr } )
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            let url = URL.documentsDirectory.appending(path: "NewTrans.json")
            let input = try Data(contentsOf: url)
            self.cvmNewTrans = try decoder.decode([NewAccountTransaction].self, from: input)
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            let url = URL.documentsDirectory.appending(path: "NewSegments.json")
            let input = try Data(contentsOf: url)
            self.cvmNewSegments = try decoder.decode([NewTransactionSegment].self, from: input)
        } catch {
            print(error.localizedDescription)
        }
    }

    func convertTransactions() {
        let inputJournal = loadInput()
        if inputJournal.status == 0 {
            print("success")
            let processedJournal = processJournal(rawJournal: inputJournal.journal)
            print(processedJournal.count)
            self.cvmTransactions = buildJournal(xtrs: processedJournal)
            print("done")
        }
    }
    
    func convertAccounts() {
        self.cvmCOA = buildChartofAccounts()
        self.cvmAccountCount = self.accountCount()
    }
    
    func processJournal(rawJournal:[String]) -> [IJXtract] {
        var transSeq:Int = 0
        var workJournal:[IJXtract] = []
        var ijxwork:IJXtract = IJXtract()

        for aString in rawJournal {
            let xString = aString.trimmingCharacters(in: .whitespacesAndNewlines)
            let xArray:[String] = xString.components(separatedBy: "*")
            let xDate = 1 < xArray.count ? ExtDate(fmtDate: xArray[1]) : ExtDate()
            let xType = 2 < xArray.count ? xArray[2] : ""
            let xNum = 3 < xArray.count ? xArray[3] : ""
            let xName = 4 < xArray.count ? xArray[4] : ""
            let xMemo = 5 < xArray.count ? xArray[5] : ""
            let xAccount = 6 < xArray.count ? xArray[6] : ""
            let xDebit = 7 < xArray.count ? Money(stringAmount: xArray[7]) : Money()
            let xCredit = 8 < xArray.count ? Money(stringAmount: xArray[8]) : Money()
            
            if xDebit != Money() && xCredit != Money() { continue }
            if xDebit == Money() && xCredit == Money() { continue }
            
            if xDate != ExtDate() {
                transSeq += 1
                ijxwork.ijxSeqNr = transSeq
                ijxwork.ijxDate = xDate
                ijxwork.ijxType = xType
                ijxwork.ijxNum = xNum
                ijxwork.ijxName = xName
                ijxwork.ijxMemo = xMemo
                ijxwork.ijxAccountName = xAccount
                ijxwork.ijxDebit = xDebit
                ijxwork.ijxCredit = xCredit
                workJournal.append(ijxwork)
                ijxwork = IJXtract()
            } else {
                ijxwork = IJXtract()
                ijxwork.ijxSeqNr = transSeq
                ijxwork.ijxAccountName = xAccount
                ijxwork.ijxDebit = xDebit
                ijxwork.ijxCredit = xCredit
                workJournal.append(ijxwork)
                ijxwork = IJXtract()
            }
        }
        return workJournal
    }

    func loadInput() -> (status:Int, journal: [String]) {
        if let filepath = Bundle.main.path(forResource: "Journal", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let rawJournal:[String] = contents.components(separatedBy: "\n")
//                print(contents)
                return (0, rawJournal)
            } catch {
                // contents could not be loaded
                return (-1, [])
            }
        } else {
            // example.txt not found!
            return (-2, [])
        }
    }

    func buildJournal(xtrs: [IJXtract]) -> [IJTrans] {
        var workXtracts: [IJXtract] = xtrs
        var workTrans: [IJTrans] = []
        
        cvmNewTrans = []
        cvmNewSegments = []
        
        while workXtracts.count > 0 {
            let currTrans:Int = workXtracts[0].ijxSeqNr
            var thisTrans:IJTrans = IJTrans()
            thisTrans.IJTSeqNr = currTrans
            thisTrans.IJTDate = workXtracts[0].ijxDate
            thisTrans.IJTType = workXtracts[0].ijxType
            thisTrans.IJTNum = workXtracts[0].ijxNum
            thisTrans.IJTName = workXtracts[0].ijxName
            let workSources = workXtracts.filter( { $0.ijxSeqNr == currTrans } )
            
            let newTransaction = NewAccountTransaction(NATSeqNr: workXtracts[0].ijxSeqNr, NATProcessed: false, NATDate: workXtracts[0].ijxDate, NATType: workXtracts[0].ijxType, NATNum: workXtracts[0].ijxNum, NATName: workXtracts[0].ijxName)
            cvmNewTrans.append(newTransaction)
            
            workXtracts = workXtracts.filter( { $0.ijxSeqNr != currTrans } ) // cut out extract set
            var segSeq:Int = 0
            
            for ws in workSources {
                let wx:IJTrans.IJTSegment = IJTrans.IJTSegment(IJTSAccountNr: ws.ijxAccountNr, IJTSAccountName: ws.ijxAccountName, IJTSDebit: ws.ijxDebit, IJTSCredit: ws.ijxCredit)
                thisTrans.IJTSegments.append(wx)
                
                segSeq += 1
                let NewSegment:NewTransactionSegment = NewTransactionSegment(NTSParentTransaction: newTransaction.NATSeqNr, NTSSeqNr: segSeq, NTSAccountNr: ws.ijxAccountNr, NTSAccountName: ws.ijxAccountName, NTSDebit: ws.ijxDebit, NTSCredit: ws.ijxCredit)
                cvmNewSegments.append(NewSegment)
            }
            workTrans.append(thisTrans)
            print(workXtracts.count)
        }
        buildNewChartofAccounts()
        writeNewJSON()
        return workTrans
    }
    
    func buildChartofAccounts() -> ICAChartOfAccounts {
        var coa:ICAChartOfAccounts = ICAChartOfAccounts()
        var coaGroup:ICAGroup = ICAGroup()
        var coaAccount:ICAAccount = ICAAccount()
        coaGroup.ICAGGroupNr = 1000
        coaGroup.ICAGGroupName = "Assets"
//        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 1100
        coaAccount.ICAAAccountName = "Cash in Bank"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 1109
        coaAccount.ICAAAccountName = "Petty Cash"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 1120
        coaAccount.ICAAAccountName = "Client Advances-Unbilled"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 1130
        coaAccount.ICAAAccountName = "Client Advances-Billed"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 1140
        coaAccount.ICAAAccountName = "Other Receivables Deposits etc."
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 1150
        coaAccount.ICAAAccountName = "Furniture Fixtures & Equipment"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 1160
        coaAccount.ICAAAccountName = "Leasehold Improvements"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 1170
        coaAccount.ICAAAccountName = "Real Property"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 1180
        coaAccount.ICAAAccountName = "Reserve: Depreciation & Amortization"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 1190
        coaAccount.ICAAAccountName = "Other Assets"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 1198
        coaAccount.ICAAAccountName = "Client Billings"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 1199
        coaAccount.ICAAAccountName = "Lawyer Billings"
        coaGroup.ICAGAccounts.append(coaAccount)
        coa.ICAGroups.append(coaGroup)
        coaGroup = ICAGroup()
        coaGroup.ICAGGroupNr = 2000
        coaGroup.ICAGGroupName = "Liabilities"
        coaAccount.ICAAAccountNr = 2200
        coaAccount.ICAAAccountName = "Accounts Payable"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 2210
        coaAccount.ICAAAccountName = "Federal Income Tax Withheld"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 2211
        coaAccount.ICAAAccountName = "State Income Tax Withheld"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 2212
        coaAccount.ICAAAccountName = "Employee FICA Tax Withheld"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 2220
        coaAccount.ICAAAccountName = "Employee Medical/RetirementWithheld"
        coaGroup.ICAGAccounts.append(coaAccount)
        coa.ICAGroups.append(coaGroup)
        coaGroup = ICAGroup()
        coaGroup.ICAGGroupNr = 3000
        coaGroup.ICAGGroupName = "Segregated Liabilities"
//        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 3298
        coaAccount.ICAAAccountName = "Client Trust Funds"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 3299
        coaAccount.ICAAAccountName = "Liability: Client Trust Funds"
        coaGroup.ICAGAccounts.append(coaAccount)
        coa.ICAGroups.append(coaGroup)
        coaGroup = ICAGroup()
        coaGroup.ICAGGroupNr = 4000
        coaGroup.ICAGGroupName = "Owners Equity"
//        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 4300
        coaAccount.ICAAAccountName = "Equity Account: Morris"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 4301
        coaAccount.ICAAAccountName = "Drawing Account: Morris"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 4310
        coaAccount.ICAAAccountName = "Equity Account: Linda"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 4311
        coaAccount.ICAAAccountName = "Drawing Account: Linda"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 4320
        coaAccount.ICAAAccountName = "Equity Account: Family"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 4321
        coaAccount.ICAAAccountName = "Drawing Account: Family"
        coaGroup.ICAGAccounts.append(coaAccount)
        coa.ICAGroups.append(coaGroup)
        coaGroup = ICAGroup()
        coaGroup.ICAGGroupNr = 5000
        coaGroup.ICAGGroupName = "Profit/Loss Accounts"
//        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 5400
        coaAccount.ICAAAccountName = "Fees: Income from Clients"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 5460
        coaAccount.ICAAAccountName = "Other Income/Receipts"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 5480
        coaAccount.ICAAAccountName = "Costs: Income-Producing Property"
        coaGroup.ICAGAccounts.append(coaAccount)
        coa.ICAGroups.append(coaGroup)
        coaGroup = ICAGroup()
        coaGroup.ICAGGroupNr = 6000
        coaGroup.ICAGGroupName = "Compensation Costs"
//        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6500
        coaAccount.ICAAAccountName = "Secretarial"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6501
        coaAccount.ICAAAccountName = "Word Processing"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6502
        coaAccount.ICAAAccountName = "Paralegals/Clerks"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6503
        coaAccount.ICAAAccountName = "Lawyers"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6504
        coaAccount.ICAAAccountName = "Other Non-Owner Employees"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6510
        coaAccount.ICAAAccountName = "FICA & Unemployment Taxes"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6514
        coaAccount.ICAAAccountName = "Employee Retirement Benefits"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6518
        coaAccount.ICAAAccountName = "Employee Training & Education"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6519
        coaAccount.ICAAAccountName = "Other Employee Costs Occupancy"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6520
        coaAccount.ICAAAccountName = "Office Rent"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6521
        coaAccount.ICAAAccountName = "Parking"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6523
        coaAccount.ICAAAccountName = "Real Estate Taxes & Insurance"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6525
        coaAccount.ICAAAccountName = "Utilities Other Than Telephone"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 6527
        coaAccount.ICAAAccountName = "Cleaning/Housekeeping — Office"
        coa.ICAGroups.append(coaGroup)
        coaGroup = ICAGroup()
        coaGroup.ICAGGroupNr = 7000
        coaGroup.ICAGGroupName = "Office Operations"
//        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 7540
        coaAccount.ICAAAccountName = "Supplies Stationery & Printing"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 7541
        coaAccount.ICAAAccountName = "Postage & Delivery"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 7542
        coaAccount.ICAAAccountName = "Library & Subscriptions"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 7543
        coaAccount.ICAAAccountName = "Telephone/Communications"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 7545
        coaAccount.ICAAAccountName = "Photocopy Expense"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 7546
        coaAccount.ICAAAccountName = "Computer Equipment"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 7548
        coaAccount.ICAAAccountName = "Equipment Rental"
        coa.ICAGroups.append(coaGroup)
        coaGroup = ICAGroup()
        coaGroup.ICAGGroupNr = 8000
        coaGroup.ICAGGroupName = "Professional/Promotion"
//        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 8570
        coaAccount.ICAAAccountName = "Travel & Related Expense"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 8571
        coaAccount.ICAAAccountName = "Professional Dues & CLE"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 8572
        coaAccount.ICAAAccountName = "Recruiting: Professional Staff"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 8573
        coaAccount.ICAAAccountName = "Entertainment"
        coa.ICAGroups.append(coaGroup)
        coaGroup.ICAGGroupNr = 9000
        coaGroup.ICAGGroupName = "Other Costs/Expenses"
//        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 9580
        coaAccount.ICAAAccountName = "Insurance: Professional/Other"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 9581
        coaAccount.ICAAAccountName = "Other Taxes and Similar Costs"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 9582
        coaAccount.ICAAAccountName = "Client Advances Written Off"
        coa.ICAGroups.append(coaGroup)
        coaGroup = ICAGroup()
        return coa
    }
    
    func buildNewChartofAccounts() {
        cvmNewGroup = []
        cvmNewAccount = []
        
        var NAGroup:NewAccountGroup = NewAccountGroup()
        var NARAccount:NewAccountRecord = NewAccountRecord()

        NAGroup = NewAccountGroup(NAGroupNr: 1000, NAGroupName: "Assets")
        cvmNewGroup.append(NAGroup)
        
        NARAccount = NewAccountRecord(NARAAccountNr: 1100, NARAAccountName: "Cash in Bank", NARAAccountGroup: NAGroup.NAGroupNr, NARADebit: Money(), NARACredit: Money())
        cvmNewAccount.append(NARAccount)
        
        NARAccount.NARAAccountNr = 1109
        NARAccount.NARAAccountName = "Petty Cash"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 1120
        NARAccount.NARAAccountName = "Client Advances-Unbilled"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 1130
        NARAccount.NARAAccountName = "Client Advances-Billed"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 1140
        NARAccount.NARAAccountName = "Other Receivables Deposits etc."
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 1150
        NARAccount.NARAAccountName = "Furniture Fixtures & Equipment"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 1160
        NARAccount.NARAAccountName = "Leasehold Improvements"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 1170
        NARAccount.NARAAccountName = "Real Property"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 1180
        NARAccount.NARAAccountName = "Reserve: Depreciation & Amortization"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 1190
        NARAccount.NARAAccountName = "Other Assets"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 1198
        NARAccount.NARAAccountName = "Client Billings"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 1199
        NARAccount.NARAAccountName = "Lawyer Billings"
        cvmNewAccount.append(NARAccount)
        
        NAGroup = NewAccountGroup(NAGroupNr: 2000, NAGroupName: "Liabilities")
        cvmNewGroup.append(NAGroup)
        NARAccount.NARAAccountGroup = NAGroup.NAGroupNr
        
        NARAccount.NARAAccountNr = 2200
        NARAccount.NARAAccountName = "Accounts Payable"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 2210
        NARAccount.NARAAccountName = "Federal Income Tax Withheld"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 2211
        NARAccount.NARAAccountName = "State Income Tax Withheld"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 2212
        NARAccount.NARAAccountName = "Employee FICA Tax Withheld"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 2220
        NARAccount.NARAAccountName = "Employee Medical/RetirementWithheld"
        cvmNewAccount.append(NARAccount)

        NAGroup = NewAccountGroup(NAGroupNr: 3000, NAGroupName: "Segregated Liabilities")
        cvmNewGroup.append(NAGroup)
        NARAccount.NARAAccountGroup = NAGroup.NAGroupNr

        NARAccount.NARAAccountNr = 3298
        NARAccount.NARAAccountName = "Client Trust Funds"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 3299
        NARAccount.NARAAccountName = "Liability: Client Trust Funds"
        cvmNewAccount.append(NARAccount)

        NAGroup = NewAccountGroup(NAGroupNr: 4000, NAGroupName: "Owners Equity")
        cvmNewGroup.append(NAGroup)
        NARAccount.NARAAccountGroup = NAGroup.NAGroupNr

        NARAccount.NARAAccountNr = 4300
        NARAccount.NARAAccountName = "Equity Account: Morris"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 4301
        NARAccount.NARAAccountName = "Drawing Account: Morris"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 4310
        NARAccount.NARAAccountName = "Equity Account: Linda"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 4311
        NARAccount.NARAAccountName = "Drawing Account: Linda"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 4320
        NARAccount.NARAAccountName = "Equity Account: Family"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 4321
        NARAccount.NARAAccountName = "Drawing Account: Family"
        cvmNewAccount.append(NARAccount)

        NAGroup = NewAccountGroup(NAGroupNr: 5000, NAGroupName: "Profit/Loss Accounts")
        cvmNewGroup.append(NAGroup)
        NARAccount.NARAAccountGroup = NAGroup.NAGroupNr

        NARAccount.NARAAccountNr = 5400
        NARAccount.NARAAccountName = "Fees: Income from Clients"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 5460
        NARAccount.NARAAccountName = "Other Income/Receipts"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 5480
        NARAccount.NARAAccountName = "Costs: Income-Producing Property"
        cvmNewAccount.append(NARAccount)

        NAGroup = NewAccountGroup(NAGroupNr: 6000, NAGroupName: "Compensation Costs")
        cvmNewGroup.append(NAGroup)
        NARAccount.NARAAccountGroup = NAGroup.NAGroupNr

        NARAccount.NARAAccountNr = 6500
        NARAccount.NARAAccountName = "Secretarial"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6501
        NARAccount.NARAAccountName = "Word Processing"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6502
        NARAccount.NARAAccountName = "Paralegals/Clerks"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6503
        NARAccount.NARAAccountName = "Lawyers"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6504
        NARAccount.NARAAccountName = "Other Non-Owner Employees"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6510
        NARAccount.NARAAccountName = "FICA & Unemployment Taxes"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6514
        NARAccount.NARAAccountName = "Employee Retirement Benefits"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6518
        NARAccount.NARAAccountName = "Employee Training & Education"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6519
        NARAccount.NARAAccountName = "Other Employee Costs Occupancy"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6520
        NARAccount.NARAAccountName = "Office Rent"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6521
        NARAccount.NARAAccountName = "Parking"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6523
        NARAccount.NARAAccountName = "Real Estate Taxes & Insurance"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6525
        NARAccount.NARAAccountName = "Utilities Other Than Telephone"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 6527
        NARAccount.NARAAccountName = "Cleaning/Housekeeping — Office"

        NAGroup = NewAccountGroup(NAGroupNr: 7000, NAGroupName: "Office Operations")
        cvmNewGroup.append(NAGroup)
        NARAccount.NARAAccountGroup = NAGroup.NAGroupNr

        NARAccount.NARAAccountNr = 7540
        NARAccount.NARAAccountName = "Supplies Stationery & Printing"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 7541
        NARAccount.NARAAccountName = "Postage & Delivery"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 7542
        NARAccount.NARAAccountName = "Library & Subscriptions"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 7543
        NARAccount.NARAAccountName = "Telephone/Communications"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 7545
        NARAccount.NARAAccountName = "Photocopy Expense"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 7546
        NARAccount.NARAAccountName = "Computer Equipment"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 7548
        NARAccount.NARAAccountName = "Equipment Rental"

        NAGroup = NewAccountGroup(NAGroupNr: 8000, NAGroupName: "Professional/Promotion")
        cvmNewGroup.append(NAGroup)
        NARAccount.NARAAccountGroup = NAGroup.NAGroupNr

        NARAccount.NARAAccountNr = 8570
        NARAccount.NARAAccountName = "Travel & Related Expense"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 8571
        NARAccount.NARAAccountName = "Professional Dues & CLE"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 8572
        NARAccount.NARAAccountName = "Recruiting: Professional Staff"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 8573
        NARAccount.NARAAccountName = "Entertainment"

        NAGroup = NewAccountGroup(NAGroupNr: 9000, NAGroupName: "Other Costs/Expenses")
        cvmNewGroup.append(NAGroup)
        NARAccount.NARAAccountGroup = NAGroup.NAGroupNr

        NARAccount.NARAAccountNr = 9580
        NARAccount.NARAAccountName = "Insurance: Professional/Other"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 9581
        NARAccount.NARAAccountName = "Other Taxes and Similar Costs"
        cvmNewAccount.append(NARAccount)
        NARAccount.NARAAccountNr = 9582
        NARAccount.NARAAccountName = "Client Advances Written Off"
        cvmNewAccount.append(NARAccount)
    }
}

