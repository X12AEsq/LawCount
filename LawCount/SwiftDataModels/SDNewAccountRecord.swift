//
//  SDNewAccountRecord.swift
//  LawCount
//
//  Created by Morris Albers on 10/8/24.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model

class SDNewAccountRecord: Codable {
    var NARAAccountNr:Int = 0
    var NARAAccountName:String = ""
    var NARAAccountGroup:SDNewAccountGroup?
    var NARADebit:Money = Money()
    var NARACredit:Money = Money()
    
    enum CodingKeys: CodingKey {
        case NARAAccountNr
        case NARAAccountName
    }

    init(NARAAccountNr: Int, NARAAccountName: String, NARAAccountGroup: SDNewAccountGroup? = nil, NARADebit: Money, NARACredit: Money) {
        self.NARAAccountNr = NARAAccountNr
        self.NARAAccountName = NARAAccountName
        self.NARAAccountGroup = NARAAccountGroup
        self.NARADebit = NARADebit
        self.NARACredit = NARACredit
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        NARAAccountNr = try container.decode(Int.self, forKey: .NARAAccountNr)
        NARAAccountName = try container.decode(String.self, forKey: .NARAAccountName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(NARAAccountNr, forKey: .NARAAccountNr)
        try container.encode(NARAAccountName, forKey: .NARAAccountName)
    }
}
