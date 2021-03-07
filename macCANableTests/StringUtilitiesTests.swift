//
//  StringUtilitiesTests.swift
//  macCANableTests
//
//  Created by Robert Huston on 3/7/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import XCTest

@testable import macCANable

class StringUtilitiesTests: XCTestCase {

    // MARK: - LeftPadString(_:withPad:withLimit) -> String
    
    func testPadLeftPadsString() throws {
        let unpaddedString = "123"
        
        let paddedString = LeftPadString(unpaddedString, withPad: "0", withLimit: 5)
        
        XCTAssertEqual(paddedString, "00123")
    }
    
    func testPadLeftPadsStringAlmostFullString() throws {
        let unpaddedString = "1234"
        
        let paddedString = LeftPadString(unpaddedString, withPad: "0", withLimit: 5)
        
        XCTAssertEqual(paddedString, "01234")
    }

    func testPadLeftLeavesFullString() throws {
        let fullString = "12345"
        
        let paddedString = LeftPadString(fullString, withPad: "0", withLimit: fullString.count)
        
        XCTAssertEqual(paddedString, fullString)
    }
    
    func testPadLeftPadsArbitraryCharacters() throws {
        let unpaddedString = "Jude"
        let padding = "Hey "
        
        let paddedString = LeftPadString(unpaddedString, withPad: padding, withLimit: unpaddedString.count + padding.count)
        
        XCTAssertEqual(paddedString, "Hey Jude")
    }
    
    // MARK: - BreakString(_:atOffset:) -> (prefix: String, suffix: String)
    
    func testBreakStringAtOffsetReturnsEmptySetForEmptyString() throws {
        let (prefix,suffix) = BreakString("", atOffset: 5)
        
        XCTAssertEqual(prefix, "")
        XCTAssertEqual(suffix, "")
    }
    
    func testBreakStringAtOffsetReturnsOnlyPrefixForLargeOffset() throws {
        let (prefix,suffix) = BreakString("123", atOffset: 5)
        
        XCTAssertEqual(prefix, "123")
        XCTAssertEqual(suffix, "")
    }
    
    func testBreakStringAtOffsetReturnsOnlySuffixForZeroOffset() throws {
        let (prefix,suffix) = BreakString("123", atOffset: 0)
        
        XCTAssertEqual(prefix, "")
        XCTAssertEqual(suffix, "123")
    }
    
    func testBreakStringAtOffsetReturnsPrefixAndSuffix() throws {
        let (prefix,suffix) = BreakString("12345", atOffset: 3)
        
        XCTAssertEqual(prefix, "123")
        XCTAssertEqual(suffix, "45")
    }

}
