//
//  SelectTransactionView.swift
//  LawCount
//
//  Created by Morris Albers on 8/24/24.
//

import SwiftUI

struct SelectTransactionView: View {
    @EnvironmentObject var cvmInstance:CVM
    @EnvironmentObject var nav:NavigationStateManager
    
    @State var includeAll:Bool = true
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
            NavigationLink("Add a Transaction", value: NewAccountTransaction())
            List(candidateTransactions(all: includeAll), id: \.NATSeqNr) { ctr in
                NavigationLink(ctr.shortPrintLine, value: ctr)
            }
            Spacer()
        }
        .toolbar {
            if !includeAll {
                Button {
                    includeAll = true
                } label: {
                    Label("All Trx", systemImage: "eyedropper.full").labelStyle(.titleAndIcon)
                }
            } else {
                Button {
                    includeAll = false
                } label: {
                    Label("Only unprocessed", systemImage: "eyedropper.halffull").labelStyle(.titleAndIcon)
                }
            }
        }
        .onAppear(perform: {
            print("Select Transaction View")
        })
    }
    
    func candidateTransactions(all:Bool) -> [NewAccountTransaction] {
        if all { return cvmInstance.cvmNewTrans }
        return cvmInstance.cvmNewTrans.filter( { !$0.NATProcessed } )
    }
}

//#Preview {
//    SelectTransactionView()
//}
