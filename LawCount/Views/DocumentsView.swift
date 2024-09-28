//
//  DocumentsView.swift
//  LawCount
//
//  Created by Morris Albers on 8/22/24.
//

import SwiftUI

struct DocumentsView: View {
    @EnvironmentObject var cvmInstance:CVM
    @EnvironmentObject var router: Router<Path>
    var body: some View {
        HStack(alignment:.top) {
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text(cvmInstance.moduleTitle(mod: "Documents Menu"))
                        .font(.system(size: 20))
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
                HStack {
                    NavigationLink("List Transactions", value: "ListTransactions")
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
                HStack {
                    NavigationLink("List Accounts", value: "ListAccounts")
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
                HStack {
                    NavigationLink("Journal", value: "TransactionJournal")
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
                Spacer()
            }
        }.onAppear(perform: {
            print("Documents View")
        })
    }
}

struct DocDetailView: View {
    @EnvironmentObject var nav: NavigationStateManager
    var body: some View {
        Text("This is the documents view.")
            .onAppear(perform: {
                print(nav.selectionPath)
            })
    }
}

//#Preview {
//    DocumentsView()
//}
