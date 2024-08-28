//
//  ListTransactionsView.swift
//  LawCount
//
//  Created by Morris Albers on 8/22/24.
//

import SwiftUI

struct ListTransactionsView: View {
    @EnvironmentObject var cvmInstance:CVM
//    @EnvironmentObject var router: Router<Path>
    
    @State var transactionList:String = ""
    
    var body: some View {
        HStack(alignment:.top) {
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text(cvmInstance.moduleTitle(mod: "List Transactions"))
                        .font(.system(size: 20))
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
                Button("Save to disk") {
                    let data = Data(transactionList.utf8)
                    let url = URL.documentsDirectory.appending(path: "TransactionList.txt")

                    do {
                        try data.write(to: url, options: [.atomic, .completeFileProtection])
//                        let input = try String(contentsOf: url)
//                        print(input)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                ScrollView {
                    VStack (alignment: .leading) {
                        ForEach(cvmInstance.cvmNewTrans, id: \.self) { ctr in
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
        for ctr in cvmInstance.cvmNewTrans {
            tl += ctr.shortPrintLine
            tl += "\n"
        }
        return tl
    }
}

//#Preview {
//    ListTransactionsView()
//}
