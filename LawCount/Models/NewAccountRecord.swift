//
//  NewAccountRecord.swift
//  LawCount
//
//  Created by Morris Albers on 8/27/24.
//

import Foundation
import SwiftData

struct NewAccountRecord: Codable, Hashable {
    static func == (lhs: NewAccountRecord, rhs: NewAccountRecord) -> Bool {
        return lhs.NARAAccountNr == rhs.NARAAccountNr
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(NARAAccountNr)
    }
    var NARAAccountNr:Int = 0
    var NARAAccountName:String = ""
    var NARAAccountGroup:Int = 0
    var NARADebit:Money = Money()
    var NARACredit:Money = Money()

    init(NARAAccountNr: Int, NARAAccountName: String, NARAAccountGroup: Int, NARADebit: Money, NARACredit: Money) {
        self.NARAAccountNr = NARAAccountNr
        self.NARAAccountName = NARAAccountName
        self.NARAAccountGroup = NARAAccountGroup
        self.NARADebit = NARADebit
        self.NARACredit = NARACredit
    }
    
    init() {
        self.NARAAccountNr = 0
        self.NARAAccountName = ""
        self.NARAAccountGroup = 0
        self.NARADebit = Money()
        self.NARACredit = Money()
    }
    
    @Transient var printLine:String {
        var pl:String = "  "
        pl += FormattingService.rjf(base: String(NARAAccountNr), len: 5, zeroFill: true)
        pl += " "
        pl += FormattingService.ljf(base: NARAAccountName, len: 40)
        pl += " "
        pl += FormattingService.ljf(base: NARADebit.rawMoney11, len: 12)
        pl += FormattingService.ljf(base: NARACredit.rawMoney11, len: 12)
        return pl
    }

}

