//
//  MainViewControllerLogic.swift
//  macCANable
//
//  Created by Robert Huston on 3/6/21.
//

import Foundation

class MainViewControllerLogic: NSObject {
    
    // It's weak because we don't own the host MainViewController!
    weak var hostViewController: MainViewController!
        
    init(hostViewController: MainViewController) {
        self.hostViewController = hostViewController

        // Add more stuff here as needed
        
        super.init()
    }
    
    // MARK: - View Life Cycle
    
    func viewDidLoad() {
        // Nothing for now
    }

}
