//
//  ContentView.swift
//  Emoji
//
//  Created by Stefan Herold on 02.07.19.
//  Copyright © 2019 Coding Cobra. All rights reserved.
//
// Find emoji data at https://unicode.org/Public/13.0.0/ucd/emoji/emoji-data.txt

import SwiftUI

let emojis: [Emoji] = {
    let path = Bundle.main.path(forResource: "emoji-data", ofType: "txt")!
    let data = FileManager.default.contents(atPath: path)
    return emojisFromRawData(data)
}()

struct EmojiGrid : View {

    let columns = [
        GridItem(.adaptive(minimum: 44))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12, content: {
                ForEach(emojis, id: \.id) { emoji in
                    EmojiButton(emoji: emoji)
                }
            })
            .padding([.trailing, .leading], 12)
        }
    }
}


enum DataSource {
    case remote(url: URL)
    case local(path: String)
}

typealias RequestCompletion = ([Emoji]) -> Void

func readEmojiData(from source: DataSource, completion: @escaping RequestCompletion) throws {

    DispatchQueue.global(qos: .default).async {

        switch source {
        case .local(let path):
            let data = FileManager.default.contents(atPath: path)
            DispatchQueue.main.async {
                completion( emojisFromRawData(data) )
            }

        case .remote(let url):
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in

                guard error == nil else {
                    DispatchQueue.main.async {
                        completion( [] )
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion( emojisFromRawData(data) )
                }
            }

            task.resume()
        }
    }
}

func emojisFromRawData(_ data: Data?) -> [Emoji] {

    guard let data = data, let raw = String(data: data, encoding: .utf8) else {
        return []
    }

    let lines = raw.components(separatedBy: .newlines)

    let emojis = lines.compactMap (emojisForSingleLine).flatMap { $0 }
    return emojis
}

/// Generates list of Emoji's based on a single line
func emojisForSingleLine(_ line: String) -> [Emoji]? {

    let trimmed = line.trimmingCharacters(in: .whitespaces)

    guard !trimmed.isEmpty && !trimmed.starts(with: "#") else { return nil } // remove comment & blank line

    // extract unicode range
    let components = trimmed
        .components(separatedBy: ";")
        .map({ $0.trimmingCharacters(in: .whitespaces) })

    guard let unicodeSequence = components.first?.components(separatedBy: ".."),
          let metaComponents = components.last?.components(separatedBy: "#"),
          let type = metaComponents.first?.trimmingCharacters(in: .whitespaces),
          type == "Emoji",
          let unicodeVersion = metaComponents.last?.components(separatedBy: "[")
            .first?
            .trimmingCharacters(in: .whitespaces) else { return nil }

    return convertToUInt32Array(unicodeSequence)
        .compactMap { UnicodeScalar($0) }
        .map { Emoji(id: Int($0.value), unicodeScalar: $0, emoji: String($0), unicodeVersion: unicodeVersion) }
}

func convertToUInt32Array(_ stringArray: [String]) -> [UInt32] {

    let converted = stringArray.compactMap { UInt32($0, radix: 16) } // convert array elements

    switch converted.count {
    case 2:     return Array(converted[0]...converted[1])
    case 1:     return converted
    default:    return []
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
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
