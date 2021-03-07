//
//  CANableUtilities.swift
//  macCANable
//
//  Created by Robert Huston on 3/7/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import Foundation

func GenerateCANableMessageFromData(id: String, dlc: String, d: [String]) -> String? {
    /*
     * Message format: tIIINDD...
     * where
     *     t = literal "t" for "transmit" command
     *   III = 3-digit ID, 11-bit (hex, uppercase)
     *     N = 1-digit DLC
     *    DD = 2-digit data (hex, uppercase)
     *   ... = additional data bytes as governed by DLC
     */
    
    guard id.count == 3 else { return nil }
    guard Constants.HexadecimalDigits.union(id).count == 16 else { return nil }
    guard Int(id, radix: 16)! <= 0x7FF else { return nil }
    guard dlc.count == 1 else { return nil }
    guard Constants.DecimalDigits.union(dlc).count == 10 else { return nil }
    guard let n = Int(dlc), n > 0 && n < 9 else { return nil }
    guard d.count == n else { return nil }
    for item in d {
        guard item.count == 2 else { return nil }
        guard Constants.HexadecimalDigits.union(item).count == 16 else { return nil }
    }
    
    var message = "t" + id + dlc
    for item in d {
        message.append(item)
    }
    
    return message
}

func GenerateCANableDataFromMessage(_ message: String) -> (id: String, dlc: String, d: [String])? {
    /*
     * Message format: tIIINDD...
     * where
     *     t = literal "t" for "transmit" command
     *   III = 3-digit ID, 11-bit (hex, uppercase)
     *     N = 1-digit DLC
     *    DD = 2-digit data (hex, uppercase)
     *   ... = additional data bytes as governed by DLC
     */
    
    guard message.count >= 7 else { return nil }
    
    // Strip off "t" prefix
    var parts = BreakString(message, atOffset: 1)
    var str = parts.suffix
    
    // Extract ID value
    parts = BreakString(str, atOffset: 3)
    let id = parts.prefix
    guard Constants.HexadecimalDigits.union(id).count == 16 else { return nil }
    guard Int(id, radix: 16)! <= 0x7FF else { return nil }
    str = parts.suffix
    
    // Extract DLC value
    parts = BreakString(str, atOffset: 1)
    let dlc = parts.prefix
    guard let n = Int(dlc), n > 0 && n < 9 else { return nil }
    str = parts.suffix
    guard 2 * n == str.count else { return nil }
    
    // Extract data bytes
    var d: [String] = []
    for _ in 1...n {
        parts = BreakString(str, atOffset: 2)
        guard Constants.HexadecimalDigits.union(parts.prefix).count == 16 else { return nil }
        d.append(parts.prefix)
        str = parts.suffix
    }
    
    return (id, dlc, d)
}
