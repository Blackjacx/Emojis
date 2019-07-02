//
//  ContentView.swift
//  Emoji
//
//  Created by Stefan Herold on 02.07.19.
//  Copyright © 2019 Coding Cobra. All rights reserved.
//

import SwiftUI

//let emojiData: [[Emoji]] = {
//    // File taken from https://unicode.org/Public/emoji/11.0/emoji-sequences.txt
//    let path = Bundle.main.path(forResource: "emoji-data", ofType: "txt")!
//    let data = FileManager.default.contents(atPath: path)
//    return emojisFromRawData(data).chunked(into: 5)
//}()

let emojiData: String = {
    let path = Bundle.main.path(forResource: "emoji-data", ofType: "txt")!
    let data = FileManager.default.contents(atPath: path)
    return emojisFromRawData(data).map { $0.emoji }.joined(separator: " ")
}()

struct EmojiList : View {
    var body: some View {
//        List(emojiData.identified(by: \.[0].id)) { emojiChunk in
//            EmojiRow(emojis: emojiChunk)
//        }

        NavigationView {
            ScrollView {
                Text(emojiData)
                    .lineLimit(nil)
                    .font(.system(size: 60))
                    .frame(width: UIScreen.main.bounds.width, height: 30000, alignment: .top)
            }

            .navigationBarTitle(Text("Emojis"))
        }
    }
}


enum DataSource {
    case internet(path: String)
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

        case .internet(let path):
            guard let url = URL(string: path) else {
                DispatchQueue.main.async {
                    completion( [] )
                }
                return
            }

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
        .map { $0.trimmingCharacters(in: .whitespaces) }

    guard let unicodeRange = components.first else { return nil }

    // split into start and end indices
    let unicodeSequence = unicodeRange
        .components(separatedBy: "..")
        .map { $0.trimmingCharacters(in: .whitespaces) }

    guard let metaSection = components.last else { return nil }

    guard let type = metaSection
        .components(separatedBy: "#")
        .first?
        .trimmingCharacters(in: .whitespaces), type == "Emoji" else { return nil }

    guard let unicodeVersion = metaSection.components(separatedBy: "#")
        .last?
        .components(separatedBy: "[")
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
        EmojiList()
    }
}
#endif
