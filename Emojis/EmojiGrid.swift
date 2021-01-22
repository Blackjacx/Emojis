//
//  ContentView.swift
//  Emoji
//
//  Created by Stefan Herold on 02.07.19.
//  Copyright © 2019 Coding Cobra. All rights reserved.
//

import SwiftUI

struct EmojiGrid : View {

    @ObservedObject var fetcher = EmojiFetcher()
    @ScaledMetric(relativeTo: .largeTitle) var spacing: CGFloat = 12
    @ScaledMetric(relativeTo: .largeTitle) var size: CGFloat = 50

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: size))]
    }

    private var versions: [Emoji.Version] {
        Emoji.Version.allCases.map { $0 }.sorted().reversed()
    }

    init() {
        fetcher.dataSource = .remote(version: .v13_0)
    }

    var body: some View {
        if fetcher.isLoading {
            ProgressView("Loading...")
        } else {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: spacing, content: {
                        ForEach(fetcher.emojis, id: \.id) { emoji in
                            Button(emoji.emoji, action: { print(emoji) })
                                .font(.largeTitle)
                                .frame(width: size, height: size, alignment: .center)
                        }
                    })
                    .padding([.trailing, .leading], spacing)
                }
                .navigationBarTitle("Emojis v\(fetcher.dataSource!.version.rawValue) (\(fetcher.emojis.count))")
                .navigationBarItems(trailing:
                                        Menu("Versions", content: {
                                            ForEach(versions, id: \.self) { version in
                                                Button(version.rawValue, action: {
                                                    fetcher.dataSource = .remote(version: version)
                                                })
                                            }
                                        })
                )
            }
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
