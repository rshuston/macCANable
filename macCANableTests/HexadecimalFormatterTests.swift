//
//  HexadecimalFormatterTests.swift
//  macCANableTests
//
//  Created by Robert Huston on 3/7/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import XCTest

@testable import macCANable

class HexadecimalFormatterTests: XCTestCase {

    // MARK: - Instantiation
    
    func testSetsDefaultDigits() throws {
        let subject = HexadecimalFormatter()
        
        XCTAssertEqual(subject.digits, HexadecimalFormatter.defaultDigits)
    }
    
    func testLimitsDigitsToMinimum() throws {
        let subject = HexadecimalFormatter(0)
        
        XCTAssertEqual(subject.digits, HexadecimalFormatter.minimumDigits)
    }
    
    func testLimitsDigitsToMaximum() throws {
        let subject = HexadecimalFormatter(20)
        
        XCTAssertEqual(subject.digits, HexadecimalFormatter.maximumDigits)
    }
    
    func testInitWithCoder() throws {
        let numDigits = 5
        let formatter5 = HexadecimalFormatter(numDigits)
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        
        formatter5.encode(with: archiver)
        let archivedData = archiver.encodedData
        
        let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: archivedData)
        
        let subject = HexadecimalFormatter(coder: unarchiver)
        
        XCTAssertNotNil(subject)
        XCTAssertEqual(subject?.digits, numDigits)
    }
    
    // MARK: - string(for:)
    
    func testStringForStrObjectReturnsUppercaseHexValue() throws {
        let subject = HexadecimalFormatter(4)
        
        let inputString = "beef"
        
        let outputString = subject.string(for: inputString)
        
        XCTAssertEqual(outputString, inputString.uppercased())
    }
    
    func testStringForStrObjectReturnsLimitedHexValue() throws {
        let subject = HexadecimalFormatter(4)
        
        let inputString = "deadbeef"
        
        let outputString = subject.string(for: inputString)
        
        XCTAssertEqual(outputString, "DEAD")
    }
    
    func testStringForStrObjectLeftPadsShortValues() throws {
        let subject = HexadecimalFormatter(4)
        
        let inputString = "FF"
        
        let outputString = subject.string(for: inputString)
        
        XCTAssertEqual(outputString, "00FF")
    }
    
    func testStringForIntObjectReturnsUppercaseHexValue() throws {
        let subject = HexadecimalFormatter(4)
        
        let inputNumber: Int = 48879
        
        let outputString = subject.string(for: inputNumber)
        
        XCTAssertEqual(outputString, "BEEF")
    }
    
    func testStringForNilObjectReturnsNil() throws {
        let subject = HexadecimalFormatter(4)
        
        let outputString = subject.string(for: nil)
        
        XCTAssertNil(outputString)
    }
    
    // MARK: - getObjectValue(_:for:errorDescription:)
    
    func testGetObjectValueGuardsAgainstNilObj() throws {
        let subject = HexadecimalFormatter(4)
        
        let inputString = "beef"
        
        var errorString: NSString?
        let success = subject.getObjectValue(nil, for: inputString, errorDescription: &errorString)
        
        XCTAssert(!success)
        XCTAssertEqual(errorString, "obj is nil")
    }
    
    func testGetObjectValueForStringGetsUppercaseHexValue() throws {
        let subject = HexadecimalFormatter(4)
        
        let inputString = "beef"
        
        var objectValue: AnyObject?
        var errorString: NSString?
        let success = subject.getObjectValue(&objectValue, for: inputString, errorDescription: &errorString)
        
        XCTAssert(success)
        XCTAssertNotNil(objectValue)
        XCTAssert(objectValue is String)
        let outputString = objectValue as? String ?? ""
        XCTAssertEqual(outputString, inputString.uppercased())
        XCTAssertNil(errorString)
    }
    
    func testGetObjectValueForStringGetsLimitedHexValue() throws {
        let subject = HexadecimalFormatter(4)
        
        let inputString = "deadbeef"
        
        var objectValue: AnyObject?
        var errorString: NSString?
        let success = subject.getObjectValue(&objectValue, for: inputString, errorDescription: &errorString)
        
        XCTAssert(success)
        XCTAssertNotNil(objectValue)
        XCTAssert(objectValue is String)
        let outputString = objectValue as? String ?? ""
        XCTAssertEqual(outputString, "DEAD")
        XCTAssertNil(errorString)
    }
    
    func testGetObjectValueForStringLeftPadsShortValues() throws {
        let subject = HexadecimalFormatter(4)
        
        let inputString = "ff"
        
        var objectValue: AnyObject?
        var errorString: NSString?
        let success = subject.getObjectValue(&objectValue, for: inputString, errorDescription: &errorString)
        
        XCTAssert(success)
        XCTAssertNotNil(objectValue)
        XCTAssert(objectValue is String)
        let outputString = objectValue as? String ?? ""
        XCTAssertEqual(outputString, "00FF")
        XCTAssertNil(errorString)
    }
    
    func testIsPartialStringValidDeclaresValidString() throws {
        let subject = HexadecimalFormatter(4)
        
        let inputString = "FACE"
        
        var newString: NSString?
        var errorString: NSString?
        let success = subject.isPartialStringValid(inputString, newEditingString: &newString, errorDescription: &errorString)
        
        XCTAssert(success)
        XCTAssertNil(newString)
        XCTAssertNil(errorString)
    }
    
    // MARK: - isPartialStringValid(_:newEditingString:errorDescription:)
    
    func testIsPartialStringValidFixesInvalidString() throws {
        let subject = HexadecimalFormatter(4)
        
        let inputString = "1xxF"
        
        var newString: NSString?
        var errorString: NSString?
        let success = subject.isPartialStringValid(inputString, newEditingString: &newString, errorDescription: &errorString)
        
        XCTAssert(!success)
        XCTAssertNotNil(newString)
        XCTAssertEqual(newString!, "1F")
        XCTAssertNil(errorString)
    }
    
    func testIsPartialStringValidLimitInvalidString() throws {
        let subject = HexadecimalFormatter(4)
        
        let inputString = "ABCDxE"
        
        var newString: NSString?
        var errorString: NSString?
        let success = subject.isPartialStringValid(inputString, newEditingString: &newString, errorDescription: &errorString)
        
        XCTAssert(!success)
        XCTAssertNotNil(newString)
        XCTAssertEqual(newString!, "ABCD")
        XCTAssertNil(errorString)
    }

}
