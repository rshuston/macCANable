//
//  MainViewControllerTests.swift
//  macCANableTests
//
//  Created by Robert Huston on 3/7/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import XCTest

@testable import macCANable

class MainViewControllerTests: XCTestCase {

    var subject: MainViewController!
    var mockLogic: MockMainViewControllerLogic!
    
    // IBOutlets are weak references, so we need something strong to hold them for mocking
    struct MockMainViewControllerOutlets {
        let openCloseButton = NSButton()
        let availableSerialPorts = NSPopUpButton()
        let bitRate = NSPopUpButton()
        
        let sendButton = NSButton()
        
        let ID = NSTextField()
        let D0 = NSTextField()
        let D1 = NSTextField()
        let D2 = NSTextField()
        let D3 = NSTextField()
        let D4 = NSTextField()
        let D5 = NSTextField()
        let D6 = NSTextField()
        let D7 = NSTextField()
        
        let rxScrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 256, height: 12))
        
        init() {
            availableSerialPorts.addItem(withTitle: "None")
            availableSerialPorts.selectItem(at: 0)
            bitRate.addItem(withTitle: "500 kbps")
            bitRate.selectItem(at: 0)
            ID.stringValue = "7FF"
            D0.stringValue = "11"
            D1.stringValue = "22"
            D2.stringValue = "33"
            D3.stringValue = "44"
            D4.stringValue = "55"
            D5.stringValue = "66"
            D6.stringValue = "77"
            D7.stringValue = "88"
            rxScrollView.documentView = NSTextView(frame: NSRect(x: 0, y: 0, width: 256, height: 12))
            rxScrollView.hasVerticalScroller = true
        }
        
        func populateViewControllerOutlets(viewController: MainViewController) {
            viewController.o_OpenCloseButton = openCloseButton
            viewController.o_AvailableSerialPorts = availableSerialPorts
            viewController.o_BitRate = bitRate
            viewController.o_SendButton = sendButton
            viewController.o_ID = ID
            viewController.o_D0 = D0
            viewController.o_D1 = D1
            viewController.o_D2 = D2
            viewController.o_D3 = D3
            viewController.o_D4 = D4
            viewController.o_D5 = D5
            viewController.o_D6 = D6
            viewController.o_D7 = D7
            viewController.o_RxScrollView = rxScrollView
        }
    }
    
    var mockMainViewControllerOutlets: MockMainViewControllerOutlets!
    
    override func setUpWithError() throws {
        subject = MainViewController()
        
        mockLogic = MockMainViewControllerLogic(hostController: subject)
        subject.logic = mockLogic
        
        mockMainViewControllerOutlets = MockMainViewControllerOutlets()
        mockMainViewControllerOutlets.populateViewControllerOutlets(viewController: subject)
    }
    
    override func tearDownWithError() throws {
        mockMainViewControllerOutlets = nil
        mockLogic = nil
        subject = nil
    }
    
    // MARK: - viewDidLoad
    
    func testViewControllerViewDidLoadSetsUpViewControllerLogic() throws {
        // This test can't use the normal "subject" ViewController!
        let sut = MainViewController()
        let mockOutlets = MockMainViewControllerOutlets()
        mockOutlets.populateViewControllerOutlets(viewController: sut)
        
        sut.viewDidLoad()
        
        XCTAssertNotNil(sut.logic)
        XCTAssertEqual(sut.logic.hostController, sut)
    }
    
    // MARK: - viewWillAppear
    
    func testViewControllerViewWillAppearTriggersControllerLogic() throws {
        subject.viewWillAppear()
        
        XCTAssert(mockLogic.calledViewWillAppear)
    }
    
    // MARK: - viewWillDisappear
    
    func testViewControllerViewWillDisappearTriggersControllerLogic() throws {
        subject.viewWillDisappear()
        
        XCTAssert(mockLogic.calledViewWillDisappear)
    }
    
    // MARK: - viewDidDisappear
    
    func testViewControllerViewDidDisappearTriggersControllerLogic() throws {
        subject.viewDidDisappear()
        
        XCTAssert(mockLogic.calledViewDidDisappear)
    }
    
    // MARK: - IBActions
    
    func testSelectedSerialPortTriggersControllerLogicHandler() throws {
        subject.doSelectedSerialPort(NSPopUpButton())
        
        XCTAssert(mockLogic.calledHandleNewPortSelection)
    }
    
    func testDoOpenCloseTriggersControllerLogicHandler() throws {
        subject.doOpenClose(NSButton())
        
        XCTAssert(mockLogic.calledHandleOpenCloseCommand)
    }
    
    func testDoSendTriggersControllerLogicHandler() throws {
        subject.doSend(NSButton())
        
        XCTAssert(mockLogic.calledHandleSendMessageCommand)
    }
    
    func testDoClearRxClearsRxTextField() throws {
        let rxTextView = subject.o_RxScrollView.documentView! as! NSTextView
        rxTextView.string = "A cheerful little bird is sitting here singing."
        
        subject.doClearRx(NSButton())
        
        XCTAssertEqual(rxTextView.string, "")
    }
    
    // MARK: - MainViewContoller Data Interaction
    
    func testPopulatePortMenu() throws {
        mockLogic.availablePortList.append((name: "Curly", inUse: false))
        mockLogic.availablePortList.append((name: "Larry", inUse: true))
        mockLogic.availablePortList.append((name: "Moe", inUse: false))
        
        subject.populatePortMenu()
        
        let menuItems = subject.o_AvailableSerialPorts.itemArray
        XCTAssertEqual(menuItems.count, 5)  // None + separator + 3 test items
        
        XCTAssertEqual(menuItems[0].title, "None")
        XCTAssertEqual(menuItems[2].title, "Curly")
        XCTAssertEqual(menuItems[3].title, "Larry")
        XCTAssertEqual(menuItems[4].title, "Moe")
        
        XCTAssert(menuItems[0].isEnabled)
        XCTAssert(menuItems[2].isEnabled)
        XCTAssert(!menuItems[3].isEnabled)
        XCTAssert(menuItems[4].isEnabled)
    }
    
    func testGetSelectedBitRate() throws {
        let bitRate = subject.getSelectedBitRate()
        
        XCTAssertEqual(bitRate, "500 kbps")
    }
    
    func testGetTxID() throws {
        let txID = subject.getTxID()
        
        XCTAssertEqual(txID, "7FF")
    }
    
    func testGetTxDLC() throws {
        let txDLC = subject.getTxDLC()
        
        XCTAssertEqual(txDLC, "8")
    }
    
    func testGetTxDataBytes() throws {
        let txDataBytes = subject.getTxDataBytes()
        
        XCTAssertEqual(txDataBytes.count, 8)
        XCTAssertEqual(txDataBytes[0], "11")
        XCTAssertEqual(txDataBytes[1], "22")
        XCTAssertEqual(txDataBytes[2], "33")
        XCTAssertEqual(txDataBytes[3], "44")
        XCTAssertEqual(txDataBytes[4], "55")
        XCTAssertEqual(txDataBytes[5], "66")
        XCTAssertEqual(txDataBytes[6], "77")
        XCTAssertEqual(txDataBytes[7], "88")
    }
    
    func testPostRxMessagePostsFirstMessage() throws {
        subject.postRxMessage("XYZZY")
        
        let rxTextView = subject.o_RxScrollView.documentView! as! NSTextView
        XCTAssertEqual(rxTextView.string, "XYZZY")
    }
    
    func testPostRxMessageAppendsSubsequentMessage() throws {
        let rxTextView = subject.o_RxScrollView.documentView! as! NSTextView
        rxTextView.string = "XYZZY"
        
        subject.postRxMessage("PLUGH")
        
        XCTAssertEqual(rxTextView.string, "XYZZY\nPLUGH")
    }
    
    func testPostRxMessageScrollsAddedText() throws {
        let rxTextView = subject.o_RxScrollView.documentView! as! NSTextView
        rxTextView.string = "XYZZY"
        
        subject.postRxMessage("PLUGH")
        
        let verticalScrollerValue = subject.o_RxScrollView.verticalScroller!.floatValue
        XCTAssertNotEqual(verticalScrollerValue, 0.0)
    }
    
    func testClearRxMessagesRemovesText() throws {
        let rxTextView = subject.o_RxScrollView.documentView! as! NSTextView
        rxTextView.string = "A cheerful little bird is sitting here singing."
        
        subject.clearRxMessages()
        
        XCTAssertEqual(rxTextView.string, "")
    }
    
}

// MARK: - Mock MainViewControllerLogic

class MockMainViewControllerLogic: MainViewControllerLogic {
    
    var calledViewWillAppear = false
    var calledViewWillDisappear = false
    var calledViewDidDisappear = false

    var calledHandleNewPortSelection = false
    var calledHandleOpenCloseCommand = false
    var calledHandleSendMessageCommand = false
    
    var availablePortList: [(name: String, inUse: Bool)] = []
    
    override func viewWillAppear() {
        calledViewWillAppear = true
    }
    
    override func viewWillDisappear() {
        calledViewWillDisappear = true
    }
    
    override func viewDidDisappear() {
        calledViewDidDisappear = true
    }

    override func handleNewPortSelection(selectedPortName: String) {
        calledHandleNewPortSelection = true
    }
    
    override func handleOpenCloseCommand() {
        calledHandleOpenCloseCommand = true
    }
    
    override func handleSendMessageCommand() {
        calledHandleSendMessageCommand = true
    }
    
    override func getAvailablePortList() -> [(name: String, inUse: Bool)] {
        return availablePortList
    }

}
