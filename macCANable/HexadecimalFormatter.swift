//
//  HexadecimalFormatter.swift
//  macCANable
//
//  Created by Robert Huston on 3/7/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import Foundation

class HexadecimalFormatter: Formatter {
    
    static let minimumDigits = 1
    static let maximumDigits = 8
    static let defaultDigits = 4
    
    var digits: Int
    
    init(_ numDigits: Int = HexadecimalFormatter.defaultDigits) {
        self.digits = ClampValue(numDigits, minimum: HexadecimalFormatter.minimumDigits, maximum: HexadecimalFormatter.maximumDigits)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        digits = coder.decodeInteger(forKey: "digits")
        super.init(coder: coder)
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(digits, forKey: "digits")
        super.encode(with: coder)
    }
    
    override func string(for obj: Any?) -> String? {
        let inputStr: String
        switch obj {
            case is String:
                inputStr = obj as! String
            case is Int:
                let n = obj as! Int
                inputStr = String(n, radix: 16)
            default:
                return nil
        }
        var uppercase = inputStr.uppercased()
        uppercase.removeAll { (c) -> Bool in
            return !Constants.HexadecimalDigits.contains(c)
        }
        let chopped = String(uppercase.prefix(digits))
        let padded = LeftPadString(chopped, withPad: "0", withLimit: digits)
        return padded
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        guard let obj = obj else {
            error?.pointee = "obj is nil"
            return false
        }
        var uppercase = string.uppercased()
        uppercase.removeAll { (c) -> Bool in
            return !Constants.HexadecimalDigits.contains(c)
        }
        let chopped = String(uppercase.prefix(digits))
        let padded = LeftPadString(chopped, withPad: "0", withLimit: digits)
        obj.pointee = padded as AnyObject
        return true
    }
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        var uppercase = partialString.uppercased()
        uppercase.removeAll { (c) -> Bool in
            return !Constants.HexadecimalDigits.contains(c)
        }
        let chopped = String(uppercase.prefix(digits))
        
        if chopped == partialString {
            return true
        } else {
            newString?.pointee = chopped as NSString
            return false
        }
    }
    
}
