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
                        ForEach(cvmInstance.cvmNewGroup, id: \.self) { NTG in
                            OneGroupView(NTG: NTG)
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
        for NTG in cvmInstance.cvmNewGroup {
            tl += NTG.printLine
            tl += "\n"
            let accts:[NewAccountRecord] = cvmInstance.cvmNewAccount.filter( {$0.NARAAccountGroup == NTG.NAGroupNr } )
            for NAR in accts {
                tl += "  " + NAR.printLine + "\n"
            }
        }
        return tl
    }
}


//#Preview {
//    ListAccountsView()
//}
