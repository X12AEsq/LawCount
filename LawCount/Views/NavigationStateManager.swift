//
//  NavigationStateManager.swift
//  LawCount
//
//  Created by Morris Albers on 8/23/24.
//

import Foundation
import SwiftUI

class NavigationStateManager: ObservableObject {

    @Published var selectionPath = NavigationPath()
    
    func popToRoot() {
        selectionPath = NavigationPath()
    }
    func goToSettings() {
        print("x")
    }
}
