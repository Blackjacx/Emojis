//
//  Emoji.swift
//  Emoji
//
//  Created by Stefan Herold on 02.07.19.
//  Copyright © 2019 Coding Cobra. All rights reserved.
//

import SwiftUI

struct Emoji: Identifiable {
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
