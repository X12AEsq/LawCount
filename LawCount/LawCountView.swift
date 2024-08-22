//
//  SwiftUIView.swift
//  LawCount
//
//  Created by Morris Albers on 8/22/24.
//

import SwiftUI

struct LawCountView: View {
    @Environment(CVM.self) private var cvm
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear(perform: {
                print("xxx")
            })
    }
}

//#Preview {
//    SwiftUIView()
//}
