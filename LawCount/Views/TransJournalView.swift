//
//  TransJournalView.swift
//  LawCount
//
//  Created by Morris Albers on 9/2/24.
//

import SwiftUI

struct TransJournalView: View {
    @EnvironmentObject var cvmInstance:CVM
    @State var transactionList:String = ""
    @State var workAccount:[NewAccountRecord] = []
    @State var workTRX:FullTransaction = FullTransaction()
    @State var journalReport:String = ""

    var body: some View {
        HStack(alignment:.top) {
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text(cvmInstance.moduleTitle(mod: "List Accounts"))
                        .font(.system(size: 20))
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
//                Button("Save to disk") {
//                    let data = Data(accountList.utf8)
//                    let url = URL.documentsDirectory.appending(path: "AccountList.txt")
//
//                    do {
//                        try data.write(to: url, options: [.atomic, .completeFileProtection])
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                }
                ScrollView {
                    VStack (alignment: .leading) {
//                        ForEach(cvmInstance.cvmNewGroup, id: \.self) { NTG in
//                            OneGroupView(NTG: NTG)
//                        }
                        HStack {
                            Text("Totals")
//                            Text("Credits: ")
//                            Text(creditTotal)
//                            Text("Debits: ")
//                            Text(debitTotal)
                            Spacer()
                        }
                    }
                }
            }
            .onAppear(perform: {
                prepareWorkArea()
                print("xxx")
            })
        }
    }
    func prepareWorkArea() {
        journalReport = ""
        workAccount = [NewAccountRecord]()
        for acct in cvmInstance.cvmNewAccount {
//            let workAcct: NewAccountRecord = NewAccountRecord(NARAAccountNr: acct.NARAAccountNr, NARAAccountName: acct.NARAAccountName, NARAAccountGroup: acct.NARAAccountGroup, NARADebit: Money(), NARACredit: Money())
            workAccount.append(acct)
        }
        for trx in cvmInstance.cvmNewTrans.filter( { $0.NATProcessed } ) {
            workTRX.ftxTrans = trx
            workTRX.ftxSegs = cvmInstance.cvmNewSegments.filter({$0.NTSParentTransaction == trx.NATSeqNr}).sorted(by: { $0.NTSSeqNr < $1.NTSSeqNr } )
            var pl:String = FormattingService.rjf(base: String(workTRX.ftxTrans.NATSeqNr), len: 5, zeroFill: false)
            pl = pl + " "
            pl = pl + workTRX.ftxTrans.NATDate.exdFormatted
            pl = pl + " "
            pl += " "
            pl += FormattingService.ljf(base: workTRX.ftxTrans.NATNum, len: 15)
            pl += " "
            pl += FormattingService.ljf(base: workTRX.ftxTrans.NATName, len: 25)
            pl += "\n"
            journalReport += pl
        }
   }
}
//
//#Preview {
//    TransJournalView()
//}
