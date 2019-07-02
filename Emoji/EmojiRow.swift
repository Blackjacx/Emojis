//
//  EmojiRow.swift
//  Emoji
//
//  Created by Stefan Herold on 02.07.19.
//  Copyright © 2019 Coding Cobra. All rights reserved.
//

import SwiftUI


struct EmojiRow: View {
    var emojis: [Emoji]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(self.emojis) { emoji in
                Text(emoji.emoji).font(.largeTitle)
            }
        }
    }
}
