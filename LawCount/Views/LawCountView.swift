//
//  SwiftUIView.swift
//  LawCount
//
//  Created by Morris Albers on 8/22/24.
//

import SwiftUI
import SwiftData

struct LawCountView: View {
    @EnvironmentObject var cvmInstance:CVM
    @ObservedObject var router = Router<Path>()
    @State var transCount:Int = 0
    @State var acctCount:Int = 0
    var body: some View {

        HStack(alignment:.top) {
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text(cvmInstance.moduleTitle(mod: "Law Accounting"))
                        .font(.system(size: 20))
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
                HStack {
                    Button {
                        print("above push")
                        router.push(.DocumentMenu)
                        print("below push")
                    } label: {
                        Text(" Documents ")
                        //                            .font(.system(size: 30))
                    }
                    .buttonStyle(CustomButton2())
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
                HStack {
                    Button {
                        router.push(.Client)
                    } label: {
                        Text(" Accounts: \(acctCount) ")
                        //                            .font(.system(size: 30))
                    }
                    .buttonStyle(CustomButton2())
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
                HStack {
                    Button {
                        router.push(.Cause)
                    } label: {
                        Text(" Transactions: \(transCount) ")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(CustomButton2())
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
                HStack {
                    Button {
                        cvmInstance.readJSON()
                        acctCount = cvmInstance.accountCount()
                        transCount = cvmInstance.cvmTransactions.count
                    } label: {
                        Text(" Read from backup ")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(CustomButton1())
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear() {
            acctCount = cvmInstance.accountCount()
            transCount = cvmInstance.cvmTransactions.count
        }
    }
}

//#Preview {
//    SwiftUIView()
//}
