//
//  ListAccountsView.swift
//  LawCount
//
//  Created by Morris Albers on 8/25/24.
//

import SwiftUI

struct ListAccountsView: View {
    @EnvironmentObject var cvmInstance:CVM
    
    @State var accountList:String = ""
    @State var creditTotal:String = ""
    @State var debitTotal:String = ""
    
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
                Button("Save to disk") {
                    let data = Data(accountList.utf8)
                    let url = URL.documentsDirectory.appending(path: "AccountList.txt")

                    do {
                        try data.write(to: url, options: [.atomic, .completeFileProtection])
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                 ScrollView {
                    VStack (alignment: .leading) {
                        ForEach(cvmInstance.cvmNewGroup, id: \.self) { NTG in
                            OneGroupView(NTG: NTG)
                        }
                        HStack {
                            Text("Totals")
                            Text("Credits: ")
                            Text(creditTotal)
                            Text("Debits: ")
                            Text(debitTotal)
                            Spacer()
                        }
                    }
                }
            }
            .onAppear(perform: {
                let acctList = buildAccountsList()
                accountList = acctList.accounts
                creditTotal = acctList.creditAmount
                debitTotal = acctList.debitAmount
                print("xxx")
            })
        }
    }
        
            func buildAccountsList() -> (accounts:String, creditAmount:String, debitAmount:String) {
        var tl:String = ""
        var totalCredit:Money = Money()
        var totalDebit:Money = Money()
        for NTG in cvmInstance.cvmNewGroup {
            tl += NTG.printLine
            tl += "\n"
            let accts:[NewAccountRecord] = cvmInstance.cvmNewAccount.filter( {$0.NARAAccountGroup == NTG.NAGroupNr } )
            for NAR in accts {
                tl += "  " + NAR.printLine + "\n"
                totalDebit = totalDebit + NAR.NARADebit
                totalCredit = totalCredit + NAR.NARACredit
            }
        }
        tl += "\n" + "    Credits: " + totalCredit.rawMoney11 + "; " + "Debits: " + totalDebit.rawMoney11  + "\n"
        return (tl, totalCredit.rawMoney11, totalDebit.rawMoney11)
    }
}


//#Preview {
//    ListAccountsView()
//}
