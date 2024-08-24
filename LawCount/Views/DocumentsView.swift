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
    var moduleTitle:String = "Documents Menu"
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
                HStack {
                    NavigationLink("List Transactions", value: "ListTransactions")
                    Spacer()
                }
//                .navigationTitle(parentTitle)
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
