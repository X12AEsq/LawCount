//
//  ListAccountsView.swift
//  LawCount
//
//  Created by Morris Albers on 8/25/24.
//

import SwiftUI

struct ListAccountsView: View {
    @EnvironmentObject var cvmInstance:CVM
    
    @State var accountList:String = ""
    
    var body: some View {
        HStack(alignment:.top) {
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text(cvmInstance.moduleTitle(mod: "List Accounts"))
                        .font(.system(size: 20))
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
                Button("Save to disk") {
                    let data = Data(accountList.utf8)
                    let url = URL.documentsDirectory.appending(path: "AccountList.txt")

                    do {
                        try data.write(to: url, options: [.atomic, .completeFileProtection])
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                 ScrollView {
                    VStack (alignment: .leading) {
                        ForEach(cvmInstance.cvmCOA.ICAGroups, id: \.self) { ICAG in
                            OneGroupView(ICAG: ICAG)
                        }
                    }
                }
            }
            .onAppear(perform: {
                accountList = buildAccountsList()
            })
        }
    }
        
    func buildAccountsList() -> String {
        var tl:String = ""
        for ICAG in cvmInstance.cvmCOA.ICAGroups {
            tl += ICAG.printLine
            tl += "\n"
            for ICAA in ICAG.ICAGAccounts {
                tl += "  " + ICAA.printLine + "\n"
            }
        }
        return tl
    }
}


//#Preview {
//    ListAccountsView()
//}
