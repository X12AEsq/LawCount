//
//  AccountNumber.swift
//  LawCount
//
//  Created by Morris Albers on 8/21/24.
//

import Foundation

struct AccountNumber: Codable {
    var ANMajor: Int
    var ANMinor: Int
    var ANDetail: Int
    
    init(ANMajor: Int, ANMinor: Int, ANDetail: Int) {
        self.ANMajor = ANMajor
        self.ANMinor = ANMinor
        self.ANDetail = ANDetail
    }
    
    init() {
        self.ANMajor = 0
        self.ANMinor = 0
        self.ANDetail = 0
    }
}
