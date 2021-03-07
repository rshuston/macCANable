//
//  CANableUtilitiesTests.swift
//  macCANableTests
//
//  Created by Robert Huston on 3/7/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import XCTest

@testable import macCANable

class CANableUtilitiesTests: XCTestCase {

    // MARK: - GenerateCANableMessageFromData(id:dlc:d:) -> String?
    
    func testGenerateCANableMessageFromDataRejectsTooShortID() throws {
        let result = GenerateCANableMessageFromData(id: "0", dlc: "1", d: ["00"])
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableMessageFromDataRejectsTooLongID() throws {
        let result = GenerateCANableMessageFromData(id: "0000", dlc: "1", d: ["00"])
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableMessageFromDataRejectsInvalidID() throws {
        let result = GenerateCANableMessageFromData(id: "xyz", dlc: "1", d: ["00"])
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableMessageFromDataRejectsTooLargeID() throws {
        let result = GenerateCANableMessageFromData(id: "ABC", dlc: "1", d: ["00"])
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableMessageFromDataRejectsWrongSizeDLC() throws {
        let result = GenerateCANableMessageFromData(id: "000", dlc: "11", d: ["00"])
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableMessageFromDataRejectsInvalidDLC() throws {
        let result = GenerateCANableMessageFromData(id: "000", dlc: "x", d: ["00"])
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableMessageFromDataRejectsTooLowDLC() throws {
        let result = GenerateCANableMessageFromData(id: "000", dlc: "0", d: ["00"])
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableMessageFromDataRejectsTooHighDLC() throws {
        let result = GenerateCANableMessageFromData(id: "000", dlc: "9", d: ["00"])
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableMessageFromDataRejectsWrongSizedData() throws {
        let result = GenerateCANableMessageFromData(id: "000", dlc: "2", d: ["00"])
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableMessageFromDataRejectsInvalidData() throws {
        let result = GenerateCANableMessageFromData(id: "000", dlc: "4", d: ["11", "22", "xyzzy", "44"])
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableMessageFromDataProducesShortMessage() throws {
        let result = GenerateCANableMessageFromData(id: "7AD", dlc: "4", d: ["DE", "AD", "BE", "EF"])
        
        XCTAssertEqual(result, "t7AD4DEADBEEF")
    }
    
    func testGenerateCANableMessageFromDataProducesFullMessage() throws {
        let result = GenerateCANableMessageFromData(id: "123", dlc: "8", d: ["11", "22", "33", "44", "55", "66", "77", "88"])
        
        XCTAssertEqual(result, "t12381122334455667788")
    }
    
    // MARK: - GenerateCANableDataFromMessage() -> (id: String, dlc: String, d: [String])?
    
    func testGenerateCANableDataFromMessageRejectsEmptyMessage() throws {
        let result = GenerateCANableDataFromMessage("")
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableDataFromMessageRejectsMessageWithTooLargeID() throws {
        let result = GenerateCANableDataFromMessage("tCAB21122")
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableDataFromMessageRejectsMessageWithInvalidID() throws {
        let result = GenerateCANableDataFromMessage("txyz21122")
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableDataFromMessageRejectsMessageWithTooSmallDLC() throws {
        let result = GenerateCANableDataFromMessage("t123011")
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableDataFromMessageRejectsMessageWithTooLargeDLC() throws {
        let result = GenerateCANableDataFromMessage("t123911")
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableDataFromMessageRejectsMessageWithInvalidData() throws {
        let result = GenerateCANableDataFromMessage("t1231xy")
        
        XCTAssertNil(result)
    }
    
    func testGenerateCANableDataFromMessageProcessesMinimalMessage() throws {
        let result = GenerateCANableDataFromMessage("t1231FF")
        
        let id = result?.id
        let dlc = result?.dlc
        let d = result?.d
        
        XCTAssertEqual(id, "123")
        XCTAssertEqual(dlc, "1")
        XCTAssertEqual(d, ["FF"])
    }
    
    func testGenerateCANableDataFromMessageProcessesShortMessage() throws {
        let result = GenerateCANableDataFromMessage("t7AD4DEADBEEF")
        
        let id = result?.id
        let dlc = result?.dlc
        let d = result?.d
        
        XCTAssertEqual(id, "7AD")
        XCTAssertEqual(dlc, "4")
        XCTAssertEqual(d, ["DE", "AD", "BE", "EF"])
    }
    
    func testGenerateCANableDataFromMessageProcessesFullMessage() throws {
        let result = GenerateCANableDataFromMessage("t7FF81122334455667788")
        
        let id = result?.id
        let dlc = result?.dlc
        let d = result?.d
        
        XCTAssertEqual(id, "7FF")
        XCTAssertEqual(dlc, "8")
        XCTAssertEqual(d, ["11", "22", "33", "44", "55", "66", "77", "88"])
    }

}
