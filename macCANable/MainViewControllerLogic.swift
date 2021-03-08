//
//  MainViewControllerLogic.swift
//  macCANable
//
//  Created by Robert Huston on 3/6/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import Foundation

class MainViewControllerLogic: NSObject {
    
    static let SerialPortStatusChangedKey = "MainViewControllerLogic-SerialPortStatusChangedKey"
    static let SerialPortStatusOriginKey = "MainViewControllerLogic-SerialPortStatusOriginKey"
    
    // It's weak because we don't own the host MainViewController
    weak var hostController: MainViewController!
    
    var serialPortManager: ORSSerialPortManager
    
    // It's weak because we don't own the ORSSerialPort
    weak var activeSerialPort: ORSSerialPort? {
        didSet {
            oldValue?.close()
            oldValue?.delegate = nil
            
            activeSerialPort?.delegate = self
            activeSerialPort?.baudRate = 115200
            
            hostController?.setOpenCloseButtonEnableState(enabled: activeSerialPort != nil)
        }
    }
    
    var activeSerialPortIsOpen: Bool {
        didSet {
            hostController?.setControlStatesForOpenPortState(isOpen: activeSerialPortIsOpen)
        }
    }
    
    init(hostController: MainViewController) {
        self.hostController = hostController

        serialPortManager = ORSSerialPortManager.shared()
        activeSerialPortIsOpen = false
        
        super.init()
    }
    
    // MARK: - View Life Cycle
    
    func viewDidLoad() {
        // Nothing for now
    }
    
    func viewWillAppear() {
        activeSerialPortIsOpen = false
        enableNotifications()
    }
    
    func viewWillDisappear() {
        disableNotifications()
        activeSerialPort = nil
    }
    
    func viewDidDisappear() {
        // This triggers any other open windows to refresh their port pop-up menus
        postSerialPortStatusChangeNotification()
    }
    
    // MARK: - Data Access
    
    func getAvailablePortList() -> [(name: String, inUse: Bool)] {
        var list: [(name: String, inUse: Bool)] = []
        for availablePort in serialPortManager.availablePorts {
            guard availablePort.name != "Bluetooth-Incoming-Port" else { continue }
            let portInUse = availablePort !== activeSerialPort && availablePort.delegate != nil
            list.append((name: availablePort.name, inUse: portInUse))
        }
        return list
    }
    
    func getActivePortName() -> String? {
        return activeSerialPort?.name
    }
    
    // MARK: - UI Operation Handlers
    
    func handleNewPortSelection(selectedPortName: String) {
        guard !activeSerialPortIsOpen else { return }  // Should never happen, but ...
        
        var selectedPort = serialPortManager.availablePorts.first(where: {$0.name == selectedPortName})
        
        var shouldChangePort = false
        if selectedPortName == "None" && activeSerialPort != nil {
            shouldChangePort = true
            selectedPort = nil
        } else if selectedPort !== activeSerialPort {
            shouldChangePort = true
        }
        
        if shouldChangePort {
            // NOTE: This is the first of TWO places where we set activeSerialPort!
            activeSerialPort = selectedPort
            
            postSerialPortStatusChangeNotification()
        }
    }
    
    func handleOpenCloseCommand() {
        if activeSerialPortIsOpen {
            activeSerialPort?.close()
        } else {
            activeSerialPort?.open()
        }
    }
    
    func handleSendMessageCommand() {
        guard activeSerialPort != nil else { return }
        guard activeSerialPortIsOpen else { return }
        
        let id = hostController.getTxID()
        let dlc = hostController.getTxDLC()
        var data = hostController.getTxDataBytes()
        
        let n = Int(dlc)!
        if n < 8 {
            data.removeSubrange(n...7)
        }
        
        if let message = GenerateCANableMessageFromData(id: id, dlc: dlc, d: data) {
            let serialCommand = message + "\r"
            let serialData = serialCommand.data(using: String.Encoding.utf8)!
            activeSerialPort!.send(serialData)
        }
    }
    
    func setUpCanableForCommunication() {
        guard activeSerialPort != nil else { return }
        guard activeSerialPortIsOpen else { return }
        
        let selectedBitRate = hostController.getSelectedBitRate()
        let canableBitRate: String
        switch selectedBitRate {
            case "10 kbps":
                canableBitRate = "S0"
            case "20 kbps":
                canableBitRate = "S1"
            case "50 kbps":
                canableBitRate = "S2"
            case "100 kbps":
                canableBitRate = "S3"
            case "125 kbps":
                canableBitRate = "S4"
            case "250 kbps":
                canableBitRate = "S5"
            case "500 kbps":
                canableBitRate = "S6"
            case "750 kbps":
                canableBitRate = "S7"
            case "1 Mbps":
                canableBitRate = "S8"
            default:
                canableBitRate = "S6"  // 500 kbps
        }
        let serialCommand = "C\r\(canableBitRate)\rO\r"
        let serialData = serialCommand.data(using: String.Encoding.utf8)!
        activeSerialPort!.send(serialData)
    }
    
    // MARK: - Notification Management
    
    func enableNotifications() {
        let nc = NotificationCenter.default
        
        // Our ViewController notifications
        nc.addObserver(self, selector: #selector(notif_seriaPortStatusWasChanged),
                       name: NSNotification.Name.MainViewControllerLogic.SerialPortStatusChanged, object: nil)
        
        // ORSSerialPort notifications
        nc.addObserver(self, selector: #selector(notif_serialPortsWereConnected(_:)),
                       name: NSNotification.Name.ORSSerialPortsWereConnected, object: nil)
        nc.addObserver(self, selector: #selector(notif_serialPortsWereDisconnected(_:)),
                       name: NSNotification.Name.ORSSerialPortsWereDisconnected, object: nil)
    }
    
    func disableNotifications() {
        let nc = NotificationCenter.default
        
        nc.removeObserver(self, name: NSNotification.Name.MainViewControllerLogic.SerialPortStatusChanged, object: nil)
        
        nc.removeObserver(self, name: NSNotification.Name.ORSSerialPortsWereConnected, object: nil)
        nc.removeObserver(self, name: NSNotification.Name.ORSSerialPortsWereDisconnected, object: nil)
    }
    
    func postSerialPortStatusChangeNotification() {
        let nc = NotificationCenter.default
        let userInfo: [String : Any] = [
            MainViewControllerLogic.SerialPortStatusChangedKey : activeSerialPort?.name ?? "",
            MainViewControllerLogic.SerialPortStatusOriginKey : self
        ]

        nc.post(name: NSNotification.Name.MainViewControllerLogic.SerialPortStatusChanged, object: self, userInfo: userInfo)
    }
    
    // MARK: - Notification Receivers
    
    @objc func notif_seriaPortStatusWasChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let portName = userInfo[MainViewControllerLogic.SerialPortStatusChangedKey] as! String
            print("Port status was changed to: \(portName)")
            let origin = userInfo[MainViewControllerLogic.SerialPortStatusOriginKey] as! MainViewControllerLogic
            if origin == self {
                print("...by self")
            } else {
                print("...by someone else")
                hostController.populatePortMenu()
            }
        }
    }
    
    @objc func notif_serialPortsWereConnected(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let ports = userInfo[ORSConnectedSerialPortsKey] as! [ORSSerialPort]
            let portNamesList = ports.map{$0.name}
            let portNames = portNamesList.joined(separator: ",")
            print("Ports were connected: \(portNames)")
            
            hostController.populatePortMenu()
        }
    }
    
    @objc func notif_serialPortsWereDisconnected(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let ports = userInfo[ORSDisconnectedSerialPortsKey] as! [ORSSerialPort]
            let portNamesList = ports.map{$0.name}
            let portNames = portNamesList.joined(separator: ",")
            print("Ports were disconnected: \(portNames)")
            
            if activeSerialPort != nil {
                if ports.contains(activeSerialPort!) {
                    // NOTE: This is the second of TWO places where we set activeSerialPort!
                    activeSerialPort = nil
                    activeSerialPortIsOpen = false
                }
            }
            
            hostController.populatePortMenu()
        }
    }
    
}

// MARK: - Notification Name

extension Notification.Name {
    class MainViewControllerLogic {
        static let SerialPortStatusChanged = NSNotification.Name(rawValue: "com.pinpointdynamics.macCANable.SerialPortStatusChanged")
    }
}

// MARK: - ORSSerialPortDelegate

extension MainViewControllerLogic: ORSSerialPortDelegate {
    
    // Required ...
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("SerialPort \(serialPort) was removed from system")
        // No need to handle this, since the global ORSSerialPortsWereDisconnected notification
        // gets triggered beforehand, and we handle the port cleanup there.
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        print("SerialPort \(serialPort) received data")
        if let rxString = String(data: data, encoding: String.Encoding.utf8) {
            print("\"" + rxString + "\"")
            let message = rxString.trimmingCharacters(in: .newlines)
            if let messageParts = GenerateCANableDataFromMessage(message) {
                let id = messageParts.id
                let dlc = messageParts.dlc
                let d = messageParts.d
                
                // Use SocketCAN utility format: III#DD.DD.DD...
                var rxMsg = "\(id)#"
                let n = Int(dlc)!
                for i in 0..<n {
                    let dataField = i == 0 ? "\(d[i])" : ".\(d[i])"
                    rxMsg.append(dataField)
                }
                
                hostController.postRxMessage(rxMsg)
            }
        }
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceivePacket packetData: Data, matching descriptor: ORSSerialPacketDescriptor) {
        print("SerialPort \(serialPort) received packet")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceiveResponse responseData: Data, to request: ORSSerialRequest) {
        print("SerialPort \(serialPort) received response")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("SerialPort \(serialPort) encountered an error: \(error)")
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        print("SerialPort \(serialPort) was opened")
        activeSerialPortIsOpen = true
        setUpCanableForCommunication()
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        print("SerialPort \(serialPort) was closed")
        activeSerialPortIsOpen = false
    }
    
}
