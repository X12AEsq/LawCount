//
//  OneGroupView.swift
//  LawCount
//
//  Created by Morris Albers on 8/25/24.
//

import SwiftUI

struct OneGroupView: View {
    @EnvironmentObject var cvmInstance:CVM

    var ICAG:ICAGroup
    @State var ICAGAccounts:[ICAAccount] = [ICAAccount]()
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(ICAG.printLine)
                    .font(.system(.body, design: .monospaced))
                Spacer()
            }
            ForEach(ICAG.ICAGAccounts, id: \.self) { ICAA in
                HStack {
                    Text(ICAA.printLine)
                        .font(.system(.body, design: .monospaced))
                    Spacer()
                }
            }
        }
//        .onAppear(perform: {
//            ICAGAccounts = ICAG.ICAGAccounts
//        })
    }
}

//#Preview {
//    OneGroupView()
//}
