//
//  StringUtilities.swift
//  macCANable
//
//  Created by Robert Huston on 3/7/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import Foundation

func LeftPadString(_ string: String, withPad pad: String, withLimit limit: Int) -> String {
    let charsToPad = limit - string.count
    return charsToPad < 1 ? string : "".padding(toLength: charsToPad, withPad: pad, startingAt: 0) + string
}

func BreakString(_ string: String, atOffset: Int) -> (prefix: String, suffix: String) {
    let n = ClampValue(atOffset, minimum: 0, maximum: string.count)
    let index = string.index(string.startIndex, offsetBy: n)
    let prefix = string.prefix(upTo: index)
    let suffix = string.suffix(from: index)
    
    return (String(prefix), String(suffix))
}
