//
//  FormattingService.swift
//  npmb
//
//  Created by Morris Albers on 2/25/23.
//

import Foundation

struct FormattingService {
    
    public static func rjf(base:String, len:Int, zeroFill:Bool) -> String {
        var workBase = base
        var workFill = " "
        if zeroFill {
            workFill = "0"
        }
        if workBase.count == len {
            return workBase
        }
        if workBase.count < len {
            while workBase.count < len {
                workBase = workFill + workBase
            }
        } else {
            while workBase.count > len {
                let work = workBase.dropLast(1)
                workBase = String(work)
            }
        }
        return workBase
    }

    public static func ljf(base:String, len:Int) -> String {
        var workBase = base
        if workBase.count == len {
            return workBase
        }
        if workBase.count < len {
            while workBase.count < len {
                workBase = workBase + " "
            }
        } else {
            while workBase.count > len {
                workBase = String(workBase.dropLast(1))
            }
        }
        return workBase
    }

    public static func spaces(len:Int) -> String {
        var workBase = ""
        while workBase.count < len {
            workBase += " "
        }
        return workBase
    }

}

