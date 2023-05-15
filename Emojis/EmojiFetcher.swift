//
//  EmojiFetcher.swift
//  Emojis
//
//  Created by Stefan Herold on 19.01.21.
//

import SwiftUI
import Combine

class EmojiFetcher: ObservableObject {

    enum DataSource {
        case remote(version: Emoji.Version)
        case local(version: Emoji.Version)

        var version: Emoji.Version {
            switch self {
            case .remote(let version), .local(let version):
                return version
            }
        }
    }

    @Published private(set) var isLoading: Bool = true

    private(set) var emojis: [Emoji] = [] {
        didSet {
            isLoading = false
        }
    }

    var dataSource: DataSource! {
        didSet {
            readEmojiData(from: dataSource)
        }
    }

    private var cancellable: Set<AnyCancellable> = []
    private var urlSession = URLSession.shared

    private func readEmojiData(from dataSource: DataSource?) {

        isLoading = true

        switch dataSource {
        case .local(let version):
            let data = FileManager.default.contents(atPath: version.localPath)
            DispatchQueue.global(qos: .default).async { [weak self] in
                guard let self = self else { return }
                let emojis = self.emojisFromRawData(data)
                DispatchQueue.main.async { [weak self] in
                    self?.emojis = emojis
                }
            }

        case .remote(let emojiVersion):
            urlSession
                .dataTaskPublisher(for: emojiVersion.remoteUrl)
                .map { self.emojisFromRawData($0.data) }
                .replaceError(with: [])
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
//                .assign(to: \.emojis, on: self)
//                .store(in: &cancellable)
                .map { (emo: Emoji) in
                    urlSession.dataTaskPublisher(for: URL(string: "")!)
                }
                .sink(receiveCompletion: { error in
                    print(error)
                }, receiveValue: { [weak self] result in
                    print(result)
                })
        case .none:
            break
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

    var remoteUrl: URL {
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

    var localPath: String {
        "undefined"
    }
}
