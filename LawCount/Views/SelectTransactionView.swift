//
//  SelectTransactionView.swift
//  LawCount
//
//  Created by Morris Albers on 8/24/24.
//

import SwiftUI

struct SelectTransactionView: View {
    @EnvironmentObject var cvmInstance:CVM
//    @EnvironmentObject var router: Router<Path>
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(cvmInstance.moduleTitle(mod: "Select Transaction"))
                    .font(.system(size: 20))
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)
            NavigationLink("Add a Transaction", value: IJTrans())
            List(cvmInstance.cvmTransactions, id: \.IJTSeqNr) { ctr in
                NavigationLink(ctr.shortPrintLine, value: ctr)
            }
            Spacer()
        }
    }
}

//#Preview {
//    SelectTransactionView()
//}
