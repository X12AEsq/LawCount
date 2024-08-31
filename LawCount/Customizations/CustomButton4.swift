//
//  CustomButton4.swift
//  LawCount
//
//  Created by Morris Albers on 8/28/24.
//

import Foundation
import SwiftUI

struct CustomButton4: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let myFont = Font
                .system(size: 12)
                .monospaced()
        configuration.label
            .font(myFont)
            .monospaced()
            .foregroundColor(.black)
            .background(.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(.black, lineWidth: 2))
    }
}
