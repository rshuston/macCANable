//
//  NumericUtilities.swift
//  macCANable
//
//  Created by Robert Huston on 3/7/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import Foundation

public func ClampValue<T: Numeric & Comparable>(_ value: T, minimum: T, maximum: T) -> T {
    return value < minimum ? minimum : (value > maximum ? maximum : value)
}
