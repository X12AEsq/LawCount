//
//  CustomButton2.swift
//  aPractice
//
//  Created by Morris Albers on 7/16/24.
//

import Foundation
import SwiftUI

struct CustomButton2: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 30))
            .foregroundColor(.black)
            .background(.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(.black, lineWidth: 2))
    }
}
