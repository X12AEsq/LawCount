//
//  InterimChartofAccounts.swift
//  LawCount
//
//  Created by Morris Albers on 8/22/24.
//

import Foundation
struct ICAChartOfAccounts: Codable {
    var ICAGroups: [ICAGroup]
    
    init(ICAGroups: [ICAGroup]) {
        self.ICAGroups = ICAGroups
    }
    
    init() {
        self.ICAGroups = []
    }
}

struct ICAGroup: Codable {
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
        self.ICAGAccounts = []
    }
}

struct ICAAccount: Codable {
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
}
