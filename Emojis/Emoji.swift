//
//  Emoji.swift
//  Emoji
//
//  Created by Stefan Herold on 02.07.19.
//  Copyright © 2019 Coding Cobra. All rights reserved.
//

import SwiftUI

struct Emoji: Identifiable {

    enum Version: String, CaseIterable {
        case v2_0 = "2.0"
        case v3_0 = "3.0"
        case v4_0 = "4.0"
        case v5_0 = "5.0"
        case v11_0 = "11.0"
        case v12_0 = "12.0"
        case v12_1 = "12.1"
        case v13_0 = "13.0"
    }

    let id: Int
    let unicodeScalar: Unicode.Scalar
    let emoji: String
    //    let description: String
    //    let category: String
    //    let aliases: [String]
    //    let tags: [String]
    let unicodeVersion: String
    //    let iosVersion: String
}

extension Emoji.Version: Comparable {

    static func < (lhs: Emoji.Version, rhs: Emoji.Version) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
