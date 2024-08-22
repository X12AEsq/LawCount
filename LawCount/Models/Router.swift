//
//  Router.swift
//  aPractice
//
//  Created by Morris Albers on 4/29/24.
//

import Foundation
final class Router<T: Hashable>: ObservableObject {
    @Published var paths: [T] = []
    func push(_ path: T) {
        paths.append(path)
    }
    func pop() {
        paths.removeLast(1)
    }
}

enum Path {
    case HoldingPattern
    case Startup
}
