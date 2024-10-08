//
//  SDSystem.swift
//  LawCount
//
//  Created by Morris Albers on 10/8/24.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model

class SDSystem: Codable {
    @Relationship(deleteRule: .cascade) var accounts: [SDNewAccountGroup]? = [SDNewAccountGroup]()
    var id: Int
    
    enum CodingKeys: String, CodingKey {
        case id
    }
    
    init(id: Int) {
        self.id = id
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
}
