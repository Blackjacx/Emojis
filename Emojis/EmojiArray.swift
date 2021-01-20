//
//  EmojiArray.swift
//  Emojis
//
//  Created by Stefan Herold on 19.01.21.
//

import SwiftUI

class EmojiArray: ObservableObject {

    enum DataSource {
        case remote(url: URL)
        case local(path: String)
    }

    @Published var values: [Emoji] = []

    var remoteVersion: Emoji.Version {
        didSet {
            readEmojiData(from: .remote(url: remoteVersion.url))
        }
    }

    private var cancellable: Any?
    private var urlSession = URLSession.shared

    init(remoteVersion: Emoji.Version) {
        self.remoteVersion = remoteVersion
        readEmojiData(from: .remote(url: remoteVersion.url))
    }

    private func readEmojiData(from source: DataSource) {

        switch source {
        case .local(let path):
            let data = FileManager.default.contents(atPath: path)
            DispatchQueue.global(qos: .default).async { [weak self] in
                guard let self = self else { return }
                let emojis = self.emojisFromRawData(data)
                DispatchQueue.main.async { [weak self] in
                    self?.values = emojis
                }
            }

        case .remote(let url):
            cancellable = urlSession
                .dataTaskPublisher(for: url)
                .map { self.emojisFromRawData($0.data) }
                .replaceError(with: [])
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
                .assign(to: \.values, on: self)
        }
    }

    private func emojisFromRawData(_ data: Data?) -> [Emoji] {

        guard let data = data, let raw = String(data: data, encoding: .utf8) else {
            return []
        }
        let lines = raw.components(separatedBy: .newlines)
        return lines.compactMap { emojisForSingleLine($0) }.flatMap { $0 }
    }

    /// Generates list of Emoji's based on a single line
    private func emojisForSingleLine(_ line: String) -> [Emoji]? {

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

    private func convertToUInt32Array(_ stringArray: [String]) -> [UInt32] {

        let converted = stringArray.compactMap { UInt32($0, radix: 16) } // convert array elements

        switch converted.count {
        case 2:     return Array(converted[0]...converted[1])
        case 1:     return converted
        default:    return []
        }
    }
}

extension Emoji.Version {

    var url: URL {
        let urlString: String
        switch self {
        case .v2_0: urlString = "https://unicode.org/Public/emoji/2.0/emoji-data.txt"
        case .v3_0: urlString = "https://unicode.org/Public/emoji/3.0/emoji-data.txt"
        case .v4_0: urlString = "https://unicode.org/Public/emoji/4.0/emoji-data.txt"
        case .v5_0: urlString = "https://unicode.org/Public/emoji/5.0/emoji-data.txt"
        case .v11_0: urlString = "https://unicode.org/Public/emoji/11.0/emoji-data.txt"
        case .v12_0: urlString = "https://unicode.org/Public/emoji/12.0/emoji-data.txt"
        case .v12_1: urlString = "https://unicode.org/Public/emoji/12.1/emoji-data.txt"
        case .v13_0: urlString = "https://unicode.org/Public/13.0.0/ucd/emoji/emoji-data.txt"
        }
        return URL(string: urlString)!
    }
}