//
//  MainViewControllerLogicTests.swift
//  macCANableTests
//
//  Created by Robert Huston on 3/7/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import XCTest

@testable import macCANable

class MainViewControllerLogicTests: XCTestCase {

    var mockMainViewController: MockMainViewController!
    
    var subjectSpy: SpyMainViewControllerLogic!
    // NOTE: We need to use a spy since there's some things we can't observe otherwise (e.g., NotificationCenter)
    
    override func setUpWithError() throws {
        mockMainViewController = MockMainViewController()
        subjectSpy = SpyMainViewControllerLogic(hostController: mockMainViewController)
        mockMainViewController.logic = subjectSpy
    }
    
    override func tearDownWithError() throws {
        mockMainViewController = nil
        subjectSpy = nil
    }
    
    // MARK: - activeSerialPort
    
    func testSettingActiveSerialPortCleanlyReleasesPreviousPort() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let firstMockSerialPort = MockORSSerialPort(device: dummyDevice)!
        subjectSpy.activeSerialPort = firstMockSerialPort
        firstMockSerialPort.delegate = subjectSpy
        XCTAssert(!firstMockSerialPort.closeWasCalled)
        
        subjectSpy.activeSerialPort = nil
        
        XCTAssert(firstMockSerialPort.closeWasCalled)
        XCTAssertNil(firstMockSerialPort.delegate)
    }
    
    func testSettingActiveSerialPortToNewPortSetsPortDelegate() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let firstMockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        subjectSpy.activeSerialPort = firstMockSerialPort
        
        let delegate = firstMockSerialPort.delegate as? MainViewControllerLogic
        XCTAssertEqual(delegate, subjectSpy)
    }
    
    func testSettingActiveSerialPortToNewPortSetsPortForCANableSpeed() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let firstMockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        subjectSpy.activeSerialPort = firstMockSerialPort
        
        XCTAssertEqual(firstMockSerialPort.baudRate, 115200)
    }
    
    func testSettingActiveSerialPortEnablesHostControllerOpenButtonForNonNilPort() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let firstMockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockMainViewController.openCloseButtonState = .unset
        
        subjectSpy.activeSerialPort = firstMockSerialPort
        
        XCTAssertEqual(mockMainViewController.openCloseButtonState, .enabled)
    }
    
    func testSettingActiveSerialPortDisablesHostControllerOpenButtonForNilPort() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let firstMockSerialPort = MockORSSerialPort(device: dummyDevice)!
        subjectSpy.activeSerialPort = firstMockSerialPort
        
        mockMainViewController.openCloseButtonState = .unset
        
        subjectSpy.activeSerialPort = nil
        
        XCTAssertEqual(mockMainViewController.openCloseButtonState, .disabled)
    }
    
    // MARK: - activeSerialPortIsOpen
    
    func testSettingActivePortOpenEnablesHostControllerControls() throws {
        XCTAssertEqual(mockMainViewController.portOpenControlsState, .unset)
        
        subjectSpy.activeSerialPortIsOpen = true
        
        XCTAssertEqual(mockMainViewController.portOpenControlsState, .enabled)
    }
    
    func testClearingActivePortOpenDisablesHostControllerControls() throws {
        XCTAssertEqual(mockMainViewController.portOpenControlsState, .unset)
        
        subjectSpy.activeSerialPortIsOpen = false
        
        XCTAssertEqual(mockMainViewController.portOpenControlsState, .disabled)
    }
    
    // MARK: - viewWillAppear
    
    func testViewWillAppearDeassertsActiveSerialPortIsOpen() throws {
        XCTAssertEqual(mockMainViewController.portOpenControlsState, .unset)
        
        subjectSpy.viewWillAppear()
        
        XCTAssertEqual(mockMainViewController.portOpenControlsState, .disabled)
    }
    
    func testViewWillAppearEnablesNotifications() throws {
        XCTAssertEqual(subjectSpy.nofificationsState, .unset)
        
        subjectSpy.viewWillAppear()
        
        XCTAssertEqual(subjectSpy.nofificationsState, .enabled)
    }
    
    // MARK: - viewWillDisappear
    
    func testViewWillDisappearDisablesNotifications() throws {
        XCTAssertEqual(subjectSpy.nofificationsState, .unset)
        
        subjectSpy.viewWillDisappear()
        
        XCTAssertEqual(subjectSpy.nofificationsState, .disabled)
    }
    
    func testViewWillDisappearReleasesActiveSerialPort() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Dilbert"
        mockSerialPort.delegate = nil
        
        subjectSpy.activeSerialPort = mockSerialPort
        
        subjectSpy.viewWillDisappear()

        XCTAssertNil(subjectSpy.activeSerialPort)
    }

    // MARK: - viewDidDisappear
    
    func testViewDidDisappearIssuesPortMenuUpdateNotifications() throws {
        subjectSpy.serialPortStatusChangeNotificationPosted = false
        
        subjectSpy.viewDidDisappear()
        
        XCTAssert(subjectSpy.serialPortStatusChangeNotificationPosted)
    }

    // MARK: - getAvailablePortList
    
    func testGetAvailablePortListIgnoresBluetoothIncomingPort() throws {
        let results = subjectSpy.getAvailablePortList()
        
        let foundItem = results.first(where: {$0.name == "Bluetooth-Incoming-Port"})
        XCTAssertNil(foundItem)
    }
    
    func testGetAvailablePortListReturnsKnownList() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort_1 = MockORSSerialPort(device: dummyDevice)!
        let mockSerialPort_2 = MockORSSerialPort(device: dummyDevice)!
        let mockSerialPort_3 = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort_1.name = "Curly"
        mockSerialPort_1.delegate = nil
        mockSerialPort_2.name = "Larry"
        mockSerialPort_2.delegate = subjectSpy
        mockSerialPort_3.name = "Moe"
        mockSerialPort_3.delegate = nil
        
        var portList: [ORSSerialPort] = []
        portList.append(mockSerialPort_1)
        portList.append(mockSerialPort_2)
        portList.append(mockSerialPort_3)
        
        let mockSerialPortManager = MockORSSerialPortManager()
        mockSerialPortManager.availablePorts = portList
        
        subjectSpy.serialPortManager = mockSerialPortManager
        
        let results = subjectSpy.getAvailablePortList()
        
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].name, "Curly")
        XCTAssertEqual(results[0].inUse, false)
        XCTAssertEqual(results[1].name, "Larry")
        XCTAssertEqual(results[1].inUse, true)
        XCTAssertEqual(results[2].name, "Moe")
        XCTAssertEqual(results[2].inUse, false)
    }
    
    // MARK: - getActivePortName
    
    func testGetActivePortNameReturnsNilForNilActiveSerialPort() throws {
        XCTAssertNil(subjectSpy.activeSerialPort)
        
        let activePortName = subjectSpy.getActivePortName()
        
        XCTAssertNil(activePortName)
    }
    
    func testGetActivePortNameReturnsNameForActiveSerialPort() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Dilbert"
        mockSerialPort.delegate = nil
        
        subjectSpy.activeSerialPort = mockSerialPort
        
        let activePortName = subjectSpy.getActivePortName()
        
        XCTAssertEqual(activePortName, "Dilbert")
    }
    
    // MARK: - handleNewPortSelection
    
    func testHandleNewPortSelectionSelectsNewPortAndPostsNotification() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort_1 = MockORSSerialPort(device: dummyDevice)!
        let mockSerialPort_2 = MockORSSerialPort(device: dummyDevice)!
        let mockSerialPort_3 = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort_1.name = "Dilbert"
        mockSerialPort_1.delegate = nil
        mockSerialPort_2.name = "Alice"
        mockSerialPort_2.delegate = nil
        mockSerialPort_3.name = "Wally"
        mockSerialPort_3.delegate = nil
        
        var portList: [ORSSerialPort] = []
        portList.append(mockSerialPort_1)
        portList.append(mockSerialPort_2)
        portList.append(mockSerialPort_3)
        
        let mockSerialPortManager = MockORSSerialPortManager()
        mockSerialPortManager.availablePorts = portList
        
        subjectSpy.serialPortManager = mockSerialPortManager
        
        XCTAssertNil(subjectSpy.activeSerialPort)
        subjectSpy.serialPortStatusChangeNotificationPosted = false
        
        subjectSpy.handleNewPortSelection(selectedPortName: "Alice")
        
        XCTAssertEqual(subjectSpy.activeSerialPort?.name, "Alice")
        XCTAssert(subjectSpy.serialPortStatusChangeNotificationPosted)
    }
    
    func testHandleNewPortSelectionSelectsNonePortAndPostsNotification() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Dilbert"
        mockSerialPort.delegate = nil
        
        subjectSpy.activeSerialPort = mockSerialPort
        subjectSpy.serialPortStatusChangeNotificationPosted = false
        
        subjectSpy.handleNewPortSelection(selectedPortName: "None")
        
        XCTAssertNil(subjectSpy.activeSerialPort)
        XCTAssert(subjectSpy.serialPortStatusChangeNotificationPosted)
    }
    
    func testHandleNewPortSelectionDoesNotNotifyForUnchangedSelection() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort_1 = MockORSSerialPort(device: dummyDevice)!
        let mockSerialPort_2 = MockORSSerialPort(device: dummyDevice)!
        let mockSerialPort_3 = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort_1.name = "Dilbert"
        mockSerialPort_1.delegate = nil
        mockSerialPort_2.name = "Alice"
        mockSerialPort_2.delegate = nil
        mockSerialPort_3.name = "Wally"
        mockSerialPort_3.delegate = nil
        
        var portList: [ORSSerialPort] = []
        portList.append(mockSerialPort_1)
        portList.append(mockSerialPort_2)
        portList.append(mockSerialPort_3)
        
        let mockSerialPortManager = MockORSSerialPortManager()
        mockSerialPortManager.availablePorts = portList
        
        subjectSpy.serialPortManager = mockSerialPortManager
        
        subjectSpy.activeSerialPort = mockSerialPort_2
        subjectSpy.serialPortStatusChangeNotificationPosted = false
        
        subjectSpy.handleNewPortSelection(selectedPortName: "Alice")
        
        XCTAssertEqual(subjectSpy.activeSerialPort?.name, "Alice")
        XCTAssert(!subjectSpy.serialPortStatusChangeNotificationPosted)
    }
    
    func testHandleNewPortSelectionProtectsOpenSerialPort() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort_1 = MockORSSerialPort(device: dummyDevice)!
        let mockSerialPort_2 = MockORSSerialPort(device: dummyDevice)!
        let mockSerialPort_3 = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort_1.name = "Dilbert"
        mockSerialPort_1.delegate = nil
        mockSerialPort_2.name = "Alice"
        mockSerialPort_2.delegate = nil
        mockSerialPort_3.name = "Wally"
        mockSerialPort_3.delegate = nil
        
        var portList: [ORSSerialPort] = []
        portList.append(mockSerialPort_1)
        portList.append(mockSerialPort_2)
        portList.append(mockSerialPort_3)
        
        let mockSerialPortManager = MockORSSerialPortManager()
        mockSerialPortManager.availablePorts = portList
        
        subjectSpy.serialPortManager = mockSerialPortManager
        
        subjectSpy.activeSerialPort = mockSerialPort_2
        subjectSpy.activeSerialPortIsOpen = true
        subjectSpy.serialPortStatusChangeNotificationPosted = false
        
        subjectSpy.handleNewPortSelection(selectedPortName: "Wally")
        
        XCTAssertEqual(subjectSpy.activeSerialPort?.name, "Alice")
        XCTAssert(!subjectSpy.serialPortStatusChangeNotificationPosted)
    }
    
    // MARK: - handleOpenCloseCommand
    
    func testHandleOpenCloseCommandOpensIfSerialPortIsClosed() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Stewie"
        mockSerialPort.delegate = subjectSpy
        
        subjectSpy.activeSerialPort = mockSerialPort
        subjectSpy.activeSerialPortIsOpen = false
        
        subjectSpy.handleOpenCloseCommand()
        
        XCTAssert(mockSerialPort.openWasCalled)
        XCTAssert(!mockSerialPort.closeWasCalled)
    }
    
    func testHandleOpenCloseCommandClosesIfSerialPortIsOpen() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Stewie"
        mockSerialPort.delegate = subjectSpy
        
        subjectSpy.activeSerialPort = mockSerialPort
        subjectSpy.activeSerialPortIsOpen = true
        
        subjectSpy.handleOpenCloseCommand()
        
        XCTAssert(!mockSerialPort.openWasCalled)
        XCTAssert(mockSerialPort.closeWasCalled)
    }
    
    // MARK: - handleSendMessageCommand
    
    func testHandleTransmitCommandSendsViewDataToPort() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Stewie"
        mockSerialPort.delegate = subjectSpy
        
        subjectSpy.activeSerialPort = mockSerialPort
        subjectSpy.activeSerialPortIsOpen = true
        
        mockMainViewController.txID = "7FF"
        mockMainViewController.txDLC = "4"
        mockMainViewController.txDataBytes = ["DE", "AD", "BE", "EF", "00", "00", "00", "00"]
        
        subjectSpy.handleSendMessageCommand()
        
        XCTAssertEqual(mockSerialPort.dataToBeSent, "t7FF4DEADBEEF\r")
    }
    
    func testHandleTransmitCommandDoesNotSendForNilActivePort() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Stewie"
        mockSerialPort.delegate = subjectSpy
        
        subjectSpy.activeSerialPort = nil
        
        mockMainViewController.txID = "7FF"
        mockMainViewController.txDLC = "4"
        mockMainViewController.txDataBytes = ["DE", "AD", "BE", "EF", "00", "00", "00", "00"]
        
        subjectSpy.handleSendMessageCommand()
        
        XCTAssertEqual(mockSerialPort.dataToBeSent, "")
    }
    
    func testHandleTransmitCommandDoesNotSendForNonOpenActivePort() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Stewie"
        mockSerialPort.delegate = subjectSpy
        
        subjectSpy.activeSerialPort = mockSerialPort
        subjectSpy.activeSerialPortIsOpen = false
        
        mockMainViewController.txID = "7FF"
        mockMainViewController.txDLC = "4"
        mockMainViewController.txDataBytes = ["DE", "AD", "BE", "EF", "00", "00", "00", "00"]
        
        subjectSpy.handleSendMessageCommand()
        
        XCTAssertEqual(mockSerialPort.dataToBeSent, "")
    }
    
    func testHandleTransmitCommandDoesNotSendForBadTxData() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Stewie"
        mockSerialPort.delegate = subjectSpy
        
        subjectSpy.activeSerialPort = mockSerialPort
        subjectSpy.activeSerialPortIsOpen = true
        
        mockMainViewController.txID = "Foobar"
        mockMainViewController.txDLC = "4"
        mockMainViewController.txDataBytes = ["DE", "AD", "BE", "EF", "00", "00", "00", "00"]
        
        subjectSpy.handleSendMessageCommand()
        
        XCTAssertEqual(mockSerialPort.dataToBeSent, "")
    }
    
    // MARK: - setUpCanableForCommunication
    
    func testSetUpCanableForCommunicationSendsPortConfigurationMessage() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Stewie"
        mockSerialPort.delegate = subjectSpy
        
        subjectSpy.activeSerialPort = mockSerialPort
        subjectSpy.activeSerialPortIsOpen = true
        
        mockMainViewController.bitRate = "125 kbps"  // Maps to S4
        
        subjectSpy.setUpCanableForCommunication()
        
        XCTAssertEqual(mockSerialPort.dataToBeSent, "C\rS4\rO\r")
    }
    
    func testSetUpCanableForCommunicationDoesNotSendForNilActivePort() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Stewie"
        mockSerialPort.delegate = subjectSpy
        
        subjectSpy.activeSerialPort = nil
        
        mockMainViewController.bitRate = "125 kbps"  // Maps to S4
        
        subjectSpy.setUpCanableForCommunication()
        
        XCTAssertEqual(mockSerialPort.dataToBeSent, "")
    }
    
    func testSetUpCanableForCommunicationDoesNotSendForNonOpenActivePort() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Stewie"
        mockSerialPort.delegate = subjectSpy
        
        subjectSpy.activeSerialPort = mockSerialPort
        subjectSpy.activeSerialPortIsOpen = false
        
        mockMainViewController.bitRate = "125 kbps"  // Maps to S4
        
        subjectSpy.setUpCanableForCommunication()
        
        XCTAssertEqual(mockSerialPort.dataToBeSent, "")
    }
    
    // MARK: - ORSSerialPortDelegate.serialPort(_:didReceive:)
    
    func testSerialPortDidReceivePostsRxMessageToHostVCInSocketCANFormat() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Brian"
        mockSerialPort.delegate = subjectSpy
        
        subjectSpy.activeSerialPort = mockSerialPort
        subjectSpy.activeSerialPortIsOpen = true
        
        let rxData = "t7FF4DEADBEEF".data(using: String.Encoding.utf8)!
        
        mockSerialPort.delegate?.serialPort?(mockSerialPort, didReceive: rxData)
        
        XCTAssertEqual(mockMainViewController.postedRxMessage, "7FF#DE.AD.BE.EF")
    }
    
    // MARK: - ORSSerialPortDelegate.serialPortWasOpened()
    
    func testSerialPortWasOpenedMarksActiveSerialPortAsOpenAndConfiguresPort() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Peter"
        mockSerialPort.delegate = subjectSpy
        
        subjectSpy.activeSerialPort = mockSerialPort
        subjectSpy.activeSerialPortIsOpen = false
        
        mockMainViewController.bitRate = "500 kbps"  // Maps to S6
        
        mockSerialPort.delegate?.serialPortWasOpened?(mockSerialPort)
        
        XCTAssert(subjectSpy.activeSerialPortIsOpen)
        XCTAssertEqual(mockSerialPort.dataToBeSent, "C\rS6\rO\r")
    }
    
    // MARK: - ORSSerialPortDelegate.serialPortWasClosed()
    
    func testSerialPortWasClosedMarksActiveSerialPortAsClosed() throws {
        let dummyDevice:io_object_t = UInt32.max // -1 in Objective-C
        let mockSerialPort = MockORSSerialPort(device: dummyDevice)!
        
        mockSerialPort.name = "Peter"
        mockSerialPort.delegate = subjectSpy
        
        subjectSpy.activeSerialPort = mockSerialPort
        subjectSpy.activeSerialPortIsOpen = true
        
        mockSerialPort.delegate?.serialPortWasClosed?(mockSerialPort)
        
        XCTAssert(!subjectSpy.activeSerialPortIsOpen)
    }
    
}

// MARK: - Spy MainViewControllerLogic

class SpyMainViewControllerLogic: MainViewControllerLogic {
    
    enum ItemState {
        case unset
        case disabled
        case enabled
    }
    
    var nofificationsState: ItemState = .unset
    
    var serialPortStatusChangeNotificationPosted = false
    
    override func enableNotifications() {
        nofificationsState = .enabled
        super.enableNotifications()
    }
    
    override func disableNotifications() {
        nofificationsState = .disabled
        super.disableNotifications()
    }
    
    override func postSerialPortStatusChangeNotification() {
        serialPortStatusChangeNotificationPosted = true
        super.postSerialPortStatusChangeNotification()
    }
    
}

// MARK: - Mock MainViewController

class MockMainViewController: MainViewController {
    
    enum ItemState {
        case unset
        case disabled
        case enabled
    }
    
    var openCloseButtonState: ItemState = .unset
    var portOpenControlsState: ItemState = .unset
        
    var txID: String = ""
    var txDLC: String = ""
    var txDataBytes: [String] = []
    
    var postedRxMessage: String = ""
    
    override func setOpenCloseButtonEnableState(enabled: Bool) {
        if enabled {
            openCloseButtonState = .enabled
        } else {
            openCloseButtonState = .disabled
        }
    }
    
    override func setControlStatesForOpenPortState(isOpen: Bool) {
        if isOpen {
            portOpenControlsState = .enabled
        } else {
            portOpenControlsState = .disabled
        }
    }
    
    override func getSelectedBitRate() -> String {
        return bitRate
    }
    
    override func getTxID() -> String {
        return txID
    }
    
    override func getTxDLC() -> String {
        return txDLC
    }
    
    override func getTxDataBytes() -> [String] {
        return txDataBytes
    }
    
    override func postRxMessage(_ message: String) {
        postedRxMessage = message
    }
    
}

// MARK: - Mock ORSSerialPort

class MockORSSerialPort: ORSSerialPort {
    
    var openWasCalled = false
    var closeWasCalled = false
    
    var dataToBeSent = ""
    
    var mockName: String = ""
    
    override var name: String {
        get {
            return mockName
        }
        set {
            mockName = newValue
        }
    }
    
    override func open() {
        openWasCalled = true
    }
    
    override func close() -> Bool {
        closeWasCalled = true
        return true
    }
    
    override func send(_ data: Data) -> Bool {
        dataToBeSent = String(data: data, encoding: String.Encoding.utf8)!
        return true
    }
    
}

// MARK: - Mock ORSSerialPortManager

class MockORSSerialPortManager: ORSSerialPortManager {
    
    var mockAvailablePorts: [ORSSerialPort] = []
    
    override var availablePorts: [ORSSerialPort] {
        get {
            return mockAvailablePorts
        }
        set {
            mockAvailablePorts = newValue
        }
    }
    
}
