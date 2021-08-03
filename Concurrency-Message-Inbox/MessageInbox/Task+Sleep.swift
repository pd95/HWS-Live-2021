//
//  Task+Sleep.swift
//  Task+Sleep
//
//  Created by Philipp on 03.08.21.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await sleep(nanoseconds: duration)
    }
}
