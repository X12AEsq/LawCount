//
//  SwiftUIView.swift
//  LawCount
//
//  Created by Morris Albers on 8/22/24.
//

import SwiftUI

struct LawCountView: View {
    @EnvironmentObject var cvm:CVM
    @ObservedObject var router = Router<Path>()
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .onAppear(perform: {
                    print("xxx")
                })
            Button("Write") {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted

                do {
                    let url = URL.documentsDirectory.appending(path: "COA.json")
                    let data = try encoder.encode(cvm.cvmCOA)
                    try data.write(to: url, options: [.atomic, .completeFileProtection])
                } catch {
                    print(error.localizedDescription)
                }
                
                do {
                    let url = URL.documentsDirectory.appending(path: "Transactions.json")
                    let data = try encoder.encode(cvm.cvmTransactions)
                    try data.write(to: url, options: [.atomic, .completeFileProtection])
                } catch {
                    print(error.localizedDescription)
                }                
            }
            Button("Read") {
                let decoder = JSONDecoder()
                
                do {
                    let url = URL.documentsDirectory.appending(path: "COA.json")
                    let input = try Data(contentsOf: url)
                    cvm.cvmCOA = try decoder.decode(ICAChartOfAccounts.self, from: input)
                    print("xxx")
                    //                    var coadata = try decoder.decode(cvm.cvmCOA)
                } catch {
                    print(error.localizedDescription)
                }
                
                do {
                    let url = URL.documentsDirectory.appending(path: "Transactions.json")
                    let input = try Data(contentsOf: url)
                    cvm.cvmTransactions = try decoder.decode([IJTrans].self, from: input)
                    print("xxx")
                    //                    var coadata = try decoder.decode(cvm.cvmCOA)
                } catch {
                    print(error.localizedDescription)
                }
            }
                
                
//                let data = Data("Test Message".utf8)
//                let url = URL.documentsDirectory.appending(path: "message.txt")
//
//                do {
//                    try data.write(to: url, options: [.atomic, .completeFileProtection])
//                    let input = try String(contentsOf: url)
//                    print(input)
//                } catch {
//                    print(error.localizedDescription)
//                }

        }
    }
}

//#Preview {
//    SwiftUIView()
//}
