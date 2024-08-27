//
//  InterimChartofAccounts.swift
//  LawCount
//
//  Created by Morris Albers on 8/22/24.
//

import Foundation
import SwiftData

struct ICAChartOfAccounts: Codable {
    var ICAGroups: [ICAGroup]
    
    init(ICAGroups: [ICAGroup]) {
        self.ICAGroups = ICAGroups
    }
    
    init() {
        self.ICAGroups = []
    }
}

struct ICAGroup: Codable, Hashable {
    static func == (lhs: ICAGroup, rhs: ICAGroup) -> Bool {
        return lhs.ICAGGroupNr == rhs.ICAGGroupNr
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ICAGGroupNr)
    }

    var ICAGGroupNr:Int = 0
    var ICAGGroupName = ""
    var ICAGAccounts:[ICAAccount]
    
    init(ICAGGroupNr: Int, ICAGGroupName: String = "", ICAGAccounts: [ICAAccount]) {
        self.ICAGGroupNr = ICAGGroupNr
        self.ICAGGroupName = ICAGGroupName
        self.ICAGAccounts = ICAGAccounts
    }

    init() {
        self.ICAGGroupNr = 0
        self.ICAGGroupName = ""
        self.ICAGAccounts = [ICAAccount]()
    }
    
    @Transient var printLine:String {
        var pl:String = FormattingService.rjf(base: String(ICAGGroupNr), len: 5, zeroFill: true)
        pl += " "
        pl += FormattingService.ljf(base: ICAGGroupName, len: 40)
        pl += "   "
        pl += FormattingService.ljf(base: "      Debit ", len: 12)
        pl += FormattingService.ljf(base: "     Credit ", len: 12)
        return pl
    }
}

struct ICAAccount: Codable, Hashable {
    static func == (lhs: ICAAccount, rhs: ICAAccount) -> Bool {
        return lhs.ICAAAccountNr == rhs.ICAAAccountNr
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ICAAAccountNr)
    }
    var ICAAAccountNr:Int = 0
    var ICAAAccountName = ""
    var ICAADebit:Money = Money()
    var ICAACredit:Money = Money()
    
    init() {
        self.ICAAAccountNr = 0
        self.ICAAAccountName = ""
        self.ICAADebit = Money()
        self.ICAACredit = Money()
    }
    
    @Transient var printLine:String {
        var pl:String = "  "
        pl += FormattingService.rjf(base: String(ICAAAccountNr), len: 5, zeroFill: true)
        pl += " "
        pl += FormattingService.ljf(base: ICAAAccountName, len: 40)
        pl += " "
        pl += FormattingService.ljf(base: ICAADebit.rawMoney11, len: 12)
        pl += FormattingService.ljf(base: ICAACredit.rawMoney11, len: 12)
        return pl
    }

}
