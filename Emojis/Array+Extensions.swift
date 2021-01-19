//
//  Array+Extensions.swift
//  Emojis
//
//  Created by Stefan Herold on 19.01.21.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
