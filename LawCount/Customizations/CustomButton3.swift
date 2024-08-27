//
//  CustomButton3.swift
//  LawCount
//
//  Created by Morris Albers on 8/25/24.
//

import Foundation
import SwiftUI

struct CustomButton3: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .background(.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(.black, lineWidth: 2))
    }
}
