//
//  DocumentsView.swift
//  LawCount
//
//  Created by Morris Albers on 8/22/24.
//

import SwiftUI

struct DocumentsView: View {
    @EnvironmentObject var cvm:CVM
    @Environment(\.dismiss) var dismiss
    var body: some View {
        HStack(alignment:.top) {
            Spacer()
            VStack(alignment: .leading) {
                Text(selectedPractice())
                    .font(.system(size: 30))
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Text(" Transactions: \(cvm.cvmTransactions.count) ")
                        //                            .font(.system(size: 30))
                    }
                    .buttonStyle(CustomButton2())
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
            }
        }.onAppear(perform: {
            print("Documents View")
        })
    }
    func selectedPractice() -> String {
        return "Testing"
    }
}

//#Preview {
//    DocumentsView()
//}
