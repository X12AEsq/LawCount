//
//  ContentView.swift
//  LawCount
//
//  Created by Morris Albers on 8/21/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(CVM.self) private var cvm
    var body: some View {
        LawCountView()
            .onAppear(perform: {
                let journalResult = loadInput()
                if journalResult.status == 0 {
                    let journalExtracts = processJournal(rawJournal: journalResult.journal)
                    cvm.cvmTransactions = buildJournal(xtrs: journalExtracts)
                }
                cvm.cvmCOA = buildChartofAccounts()
                print("xxx")
            })
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
    
    func buildJournal(xtrs: [IJXtract]) -> [IJTrans] {
        var workXtracts: [IJXtract] = xtrs
        var workTrans: [IJTrans] = []
        while workXtracts.count > 0 {
            let currTrans:Int = workXtracts[0].ijxSeqNr
            var thisTrans:IJTrans = IJTrans()
            thisTrans.IJTSeqNr = currTrans
            thisTrans.IJTDate = workXtracts[0].ijxDate
            thisTrans.IJTType = workXtracts[0].ijxType
            thisTrans.IJTNum = workXtracts[0].ijxNum
            thisTrans.IJTName = workXtracts[0].ijxName
            var workSources = workXtracts.filter( { $0.ijxSeqNr == currTrans } )
            workXtracts = workXtracts.filter( { $0.ijxSeqNr != currTrans } )
            for ws in workSources {
                let wx:IJTrans.IJTSegment = IJTrans.IJTSegment(IJTSAccountNr: ws.ijxAccountNr, IJTSAccountName: ws.ijxAccountName, IJTSDebit: ws.ijxDebit, IJTSCredit: ws.ijxCredit)
                thisTrans.IJTSegments.append(wx)
            }
            workTrans.append(thisTrans)
            print(workXtracts.count)
        }
        return workTrans
    }
    
    func buildChartofAccounts() -> ICAChartOfAccounts {
        var coa:ICAChartOfAccounts = ICAChartOfAccounts()
        var coaGroup:ICAGroup = ICAGroup()
        var coaAccount:ICAAccount = ICAAccount()
        coaGroup.ICAGGroupNr = 1000
        coaGroup.ICAGGroupName = "Assets"
        coaGroup.ICAGAccounts.append(coaAccount)
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
        coaGroup.ICAGAccounts.append(coaAccount)
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
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 4300
        coaAccount.ICAAAccountName = "Equity Account: Morris"
        coaGroup.ICAGAccounts.append(coaAccount)
        coaAccount.ICAAAccountNr = 4301
        coaAccount.ICAAAccountName = "Drawing Account: Morris"
        coaGroup.ICAGAccounts.append(coaAccount)
        coa.ICAGroups.append(coaGroup)
        coaGroup = ICAGroup()
        coaGroup.ICAGGroupNr = 5000
        coaGroup.ICAGGroupName = "Profit/Loss Accounts"
        coaGroup.ICAGAccounts.append(coaAccount)
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
        coaAccount.ICAAAccountName = "Compensation Costs"
        coaGroup.ICAGAccounts.append(coaAccount)
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
        coaGroup.ICAGAccounts.append(coaAccount)
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
        coaGroup.ICAGAccounts.append(coaAccount)
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
        coaGroup.ICAGAccounts.append(coaAccount)
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
/*
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
*/
    
    
/*
 Dictionaries
 
 var heights = [String: Int]()
 heights["Yao Ming"] = 229
 heights["Shaquille O'Neal"] = 216
 heights["LeBron James"] = 206
 
 var archEnemies = [String: String]()
 archEnemies["Batman"] = "The Joker"
 archEnemies["Superman"] = "Lex Luthor"
 
 var heights = [String: Int]()
 heights["Yao Ming"] = 229
 heights["Shaquille O'Neal"] = 216
 heights["LeBron James"] = 206
 
 archEnemies["Batman"] = "Penguin"
 */
}

