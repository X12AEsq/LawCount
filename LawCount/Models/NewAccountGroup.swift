//
//  NewAccountGroup.swift
//  LawCount
//
//  Created by Morris Albers on 8/27/24.
//

import Foundation
import SwiftData

struct NewAccountGroup: Codable, Hashable {
    static func == (lhs: NewAccountGroup, rhs: NewAccountGroup) -> Bool {
        return lhs.NAGroupNr == rhs.NAGroupNr
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(NAGroupNr)
    }

    var NAGroupNr:Int = 0
    var NAGroupName = ""
    
    init(NAGroupNr: Int, NAGroupName: String = "") {
        self.NAGroupNr = NAGroupNr
        self.NAGroupName = NAGroupName
    }

    init() {
        self.NAGroupNr = 0
        self.NAGroupName = ""
    }
    
    @Transient var printLine:String {
        var pl:String = FormattingService.rjf(base: String(NAGroupNr), len: 5, zeroFill: true)
        pl += " "
        pl += FormattingService.ljf(base: NAGroupName, len: 40)
        pl += "   "
        pl += FormattingService.ljf(base: "      Debit ", len: 12)
        pl += FormattingService.ljf(base: "     Credit ", len: 12)
        return pl
    }
}
