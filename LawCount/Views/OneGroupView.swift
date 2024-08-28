//
//  OneGroupView.swift
//  LawCount
//
//  Created by Morris Albers on 8/25/24.
//

import SwiftUI

struct OneGroupView: View {
    @EnvironmentObject var cvmInstance:CVM

    var NTG:NewAccountGroup
    @State var NARAccounts:[NewAccountRecord] = [NewAccountRecord]()
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(NTG.printLine)
                    .font(.system(.body, design: .monospaced))
                Spacer()
            }
            ForEach(NARAccounts, id: \.self) { NAR in
                HStack {
                    Text(NAR.printLine)
                        .font(.system(.body, design: .monospaced))
                    Spacer()
                }
            }
        }
        .onAppear(perform: {
            NARAccounts = cvmInstance.cvmNewAccount.filter( {$0.NARAAccountGroup == NTG.NAGroupNr } )
        })
    }
}

//#Preview {
//    OneGroupView()
//}
