//
//  CustomButton1.swift
//  aPractice
//
//  Created by Morris Albers on 5/27/24.
//

import Foundation
import SwiftUI

struct CustomButton1: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .background(.green.opacity(0.3), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(.black, lineWidth: 2))
    }
}
