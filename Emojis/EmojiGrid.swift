//
//  ContentView.swift
//  Emoji
//
//  Created by Stefan Herold on 02.07.19.
//  Copyright © 2019 Coding Cobra. All rights reserved.
//

import SwiftUI

struct EmojiGrid : View {

    @ObservedObject var emojiArray = EmojiArray(source: .remote(url: URL(string: urls[0])!))
    @ScaledMetric(relativeTo: .largeTitle) var spacing: CGFloat = 12
    @ScaledMetric(relativeTo: .largeTitle) var size: CGFloat = 50

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: size))]
    }
    private static let urls = [
        "https://unicode.org/Public/13.0.0/ucd/emoji/emoji-data.txt"
    ]

    var body: some View {

        ScrollView {
            LazyVGrid(columns: columns, spacing: spacing, content: {
                ForEach(emojiArray.values, id: \.id) { emoji in
                    Button(emoji.emoji, action: { print(emoji) })
                        .font(.largeTitle)
                        .frame(width: size, height: size, alignment: .center)
//                        .background(Color.red)
                }
            })
            .padding([.trailing, .leading], spacing)
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        EmojiGrid()
    }
}
#endif
