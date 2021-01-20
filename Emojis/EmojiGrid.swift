//
//  ContentView.swift
//  Emoji
//
//  Created by Stefan Herold on 02.07.19.
//  Copyright © 2019 Coding Cobra. All rights reserved.
//

import SwiftUI

struct EmojiGrid : View {

    @ObservedObject var emojiArray = EmojiArray(remoteVersion: .v13_0)
    @ScaledMetric(relativeTo: .largeTitle) var spacing: CGFloat = 12
    @ScaledMetric(relativeTo: .largeTitle) var size: CGFloat = 50

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: size))]
    }

    private var versions: [Emoji.Version] {
        Emoji.Version.allCases.map { $0 }.sorted().reversed()
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: spacing, content: {
                    ForEach(emojiArray.values, id: \.id) { emoji in
                        Button(emoji.emoji, action: { print(emoji) })
                            .font(.largeTitle)
                            .frame(width: size, height: size, alignment: .center)
                    }
                })
                .padding([.trailing, .leading], spacing)
            }
            .navigationBarTitle("Emojis v\(emojiArray.remoteVersion.rawValue) (\(emojiArray.values.count))")
            .navigationBarItems(trailing:
                                    Menu("Versions", content: {
                                        ForEach(versions, id: \.self) { version in
                                            Button(version.rawValue, action: { emojiArray.remoteVersion = version })
                                        }
                                    })
            )
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
