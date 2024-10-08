//
//  NewAccountGroup.swift
//  LawCount
//
//  Created by Morris Albers on 10/8/24.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class SDNewAccountGroup: Codable {
    @Relationship(deleteRule: .cascade) var accounts: [SDNewAccountRecord]? = [SDNewAccountRecord]()
    var NASystem: SDSystem?
    var NAGroupNr:Int = 0
    var NAGroupName = ""
    
    enum CodingKeys: String, CodingKey {
        case NAGroupNr
        case NAGroupName
    }
    
    init(NAGroupNr: Int, NAGroupName: String = "") {
        self.NAGroupNr = NAGroupNr
        self.NAGroupName = NAGroupName
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        NAGroupNr = try container.decode(Int.self, forKey: .NAGroupNr)
        NAGroupName = try container.decode(String.self, forKey: .NAGroupName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(NAGroupNr, forKey: .NAGroupNr)
        try container.encode(NAGroupName, forKey: .NAGroupName)
    }
}
