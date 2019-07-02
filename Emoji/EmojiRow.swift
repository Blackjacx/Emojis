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

        HStack {

            ForEach(self.emojis) { emoji in

                Button(emoji.emoji, action: {})
                    .frame(width: (UIScreen.main.bounds.width - (CGFloat(self.emojis.count+1) * 12)) / CGFloat(self.emojis.count),
                           height: (UIScreen.main.bounds.width - (CGFloat(self.emojis.count+1) * 12)) / CGFloat(self.emojis.count),
                           alignment: .center)
                    .font(.system(size: 44))
//                    .background(Color.red)

                Spacer(minLength: 12)
            }
        }
    }
}
