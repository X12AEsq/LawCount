//
//  ListTransactionsView.swift
//  LawCount
//
//  Created by Morris Albers on 8/22/24.
//

import SwiftUI

struct ListTransactionsView: View {
    @EnvironmentObject var cvmInstance:CVM
    @EnvironmentObject var router: Router<Path>
    
    @State var transactionList:String = ""
    
    var moduleTitle:String = "List Transactions"
    
    var body: some View {
        HStack(alignment:.top) {
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text(cvmInstance.selectedPractice())
                        .font(.system(size: 30))
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
                Spacer()
                ScrollView {
                    VStack (alignment: .leading) {
                        ForEach(cvmInstance.cvmTransactions, id: \.self) { ctr in
                            HStack {
                                Text(ctr.shortPrintLine)
                                    .font(.system(.body, design: .monospaced))
                            }
                            .padding(.leading, 20)
                        }
                    }
                }
            }
            .onAppear(perform: {
                transactionList = buildTransactionList()
            })
        }
    }
    
    func buildTransactionList() -> String {
        var tl:String = ""
        for ctr in cvmInstance.cvmTransactions {
            tl += ctr.shortPrintLine
            tl += "\n"
        }
        return tl
    }
}

//#Preview {
//    ListTransactionsView()
//}
