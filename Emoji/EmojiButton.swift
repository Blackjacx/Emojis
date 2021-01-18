//
//  EmojiButton.swift
//  Emoji
//
//  Created by Stefan Herold on 02.07.19.
//  Copyright © 2019 Coding Cobra. All rights reserved.
//

import SwiftUI

struct EmojiButton: View {
    var emoji: Emoji

    var body: some View {
        Button(emoji.emoji, action: { print(emoji) })
            .font(.system(size: 40))
//            .background(Color.red)
    }
}
