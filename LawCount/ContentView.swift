//
//  ContentView.swift
//  LawCount
//
//  Created by Morris Albers on 8/21/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var cvmInstance:CVM
    @ObservedObject var router = Router<Path>()
    @StateObject var nav = NavigationStateManager()
    
    @State var transactionCount:Int = 0
    @State var accountCount:Int = 0
//    @State private var showingDocuments = false
//    @State private var showingListTransactions = false
    
    var moduleTitle:String = "Main Menu"

    var body: some View {
        NavigationStack(path: $nav.selectionPath) {
            VStackLayout(alignment: .leading) {
                HStack {
                    Text(cvmInstance.selectedPractice())
                    Spacer()
                }
                .font(.system(size: 30))
                .padding(.leading, 20)
                .padding(.bottom, 20)

                HStack {
                    NavigationLink("Documents", value: "DocumentMenu")
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 5)
                Spacer()
                HStack {
                    Button(action: {
                        cvmInstance.readJSON()
                        transactionCount = cvmInstance.cvmTransactionCount
                        accountCount = cvmInstance.cvmAccountCount
                    }) {
                        Text(" Reload from JSON ")
                            .padding(.leading, 10.0)
                            .padding(.trailing, 10.0)
                    }
                    .buttonStyle(CustomButton1())
                    Button(action: {
                        cvmInstance.convertTransactions()
                        transactionCount = cvmInstance.cvmTransactionCount
                    }) {
                        Text(" Reload from Old Journal ")
                            .padding(.leading, 10.0)
                            .padding(.trailing, 10.0)
                    }
                    .buttonStyle(CustomButton1())
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 5)
                HStack {
                    Text("Accounts: ")
                    Text(String(accountCount))
                    Text("Transactions: ")
                    Text(String(transactionCount))
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 5)

            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "DocumentMenu":
                    DocumentsView()
                case "ListTransactions":
                    ListTransactionsView()
                default:
                    DetailView()
                }
            }
            .onAppear(perform: {
                transactionCount = cvmInstance.cvmTransactionCount
                accountCount = cvmInstance.cvmAccountCount
            })
//            .navigationTitle("Root view")
            Spacer()
        }
        .environmentObject(nav)
    }
}

struct DetailView: View {
    @EnvironmentObject var nav: NavigationStateManager
    var body: some View {
        Text("This is the detail view.")
            .onAppear(perform: {
                print(nav.selectionPath)
            })
    }
}
