//
//  ConvAcctNumber.swift
//  QrBooks
//
//  Created by Morris Albers on 9/26/23.
//

//import Foundation
//import Foundation
//struct ConvAcctNumber:Codable, Hashable {
//    static func == (lhs: ConvAcctNumber, rhs: ConvAcctNumber) -> Bool {
//        let lequiv:Int = lhs.canrC[3] + (1000 * lhs.canrC[2]) + (1000000 * lhs.canrC[1]) + (1000000000 * lhs.canrC[0])
//        let requiv:Int = rhs.canrC[3] + (1000 * rhs.canrC[2]) + (1000000 * rhs.canrC[1]) + (1000000000 * rhs.canrC[0])
//        return lequiv == requiv
//    }
//
//    static func != (lhs: ConvAcctNumber, rhs: ConvAcctNumber) -> Bool {
//        let lequiv:Int = lhs.canrC[3] + (1000 * lhs.canrC[2]) + (1000000 * lhs.canrC[1]) + (1000000000 * lhs.canrC[0])
//        let requiv:Int = rhs.canrC[3] + (1000 * rhs.canrC[2]) + (1000000 * rhs.canrC[1]) + (1000000000 * rhs.canrC[0])
//        return lequiv != requiv
//    }
//
//    static func > (lhs: ConvAcctNumber, rhs: ConvAcctNumber) -> Bool {
//        let lequiv:Int = lhs.canrC[3] + (1000 * lhs.canrC[2]) + (1000000 * lhs.canrC[1]) + (1000000000 * lhs.canrC[0])
//        let requiv:Int = rhs.canrC[3] + (1000 * rhs.canrC[2]) + (1000000 * rhs.canrC[1]) + (1000000000 * rhs.canrC[0])
//        return lequiv > requiv
//    }
//    
//    static func < (lhs: ConvAcctNumber, rhs: ConvAcctNumber) -> Bool {
//        let lequiv:Int = lhs.canrC[3] + (1000 * lhs.canrC[2]) + (1000000 * lhs.canrC[1]) + (1000000000 * lhs.canrC[0])
//        let requiv:Int = rhs.canrC[3] + (1000 * rhs.canrC[2]) + (1000000 * rhs.canrC[1]) + (1000000000 * rhs.canrC[0])
//        return lequiv < requiv
//    }
//
//    var canrC:[Int]
//    
//    init() {
//        self.canrC = [0,0,0,0]
//    }
//
//    init(canrC1: Int, canrC2: Int, canrC3: Int, canrC4: Int) {
//        self.canrC = []
//        self.canrC.append(canrC1)
//        self.canrC.append(canrC2)
//        self.canrC.append(canrC3)
//        self.canrC.append(canrC4)
//    }
//    
//    var canFormat1:String {
//        var working:[Int] = self.canrC
//        while working.count < 4 { working.append(0) }
//        let line:String = "\(String(format: "%02d", working[0]))" + ".\(String(format: "%03d", working[1]))" + ".\(String(format: "%03d", working[2]))" + ".\(String(format: "%03d", working[3]))"
//        return line
//    }
//    
//    var canIsZero:Bool {
//        return self.canrC[0] == 0 && self.canrC[1] == 0 && self.canrC[2] == 0 && self.canrC[3] == 0
//    }
//}
