//
//  KanaMod.swift
//

import Foundation

class KanaMod {
    static let shared = KanaMod()
    private init() {}

    // resetの機会のほうが多いため捨て仮名をkey、元の仮名をvalueに設定
    private let suteganaTable = [
        "ぁ": "あ",
        "ぃ": "い",
        "ぅ": "う",
        "ぇ": "え",
        "ぉ": "お",
        "ヵ": "か",
        "ㇰ": "く",
        "ヶ": "け",
        "ㇱ": "し",
        "ㇲ": "す",
        "っ": "つ",
        "ㇳ": "と",
        "ㇴ": "ぬ",
        "ㇵ": "は",
        "ㇶ": "ひ",
        "ㇷ": "ふ",
        "ㇷ゚": "ぷ",
        "ㇸ": "へ",
        "ㇹ": "ほ",
        "ㇺ": "む",
        "ゃ": "や",
        "ゅ": "ゆ",
        "ょ": "よ",
        "ㇻ": "ら",
        "ㇼ": "り",
        "ㇽ": "る",
        "ㇾ": "れ",
        "ㇿ": "ろ",
        "ゎ": "わ"
    ]
    
    func resetKana(_ str: String) -> String {
        var prefix = str
        let ch = prefix.removeLast()
        
        if let largeCh = self.suteganaTable[String(ch)] {
            return prefix + largeCh
        }

        guard let lastValue = ch.unicodeScalars.last?.value else { return str }
        
        if lastValue == 0x3099 || lastValue == 0x309A {
            // 濁点, 半濁点
            return prefix + String(ch.unicodeScalars.dropLast())
        }
        
        return str
    }
    
    func switchSutegana(_ str: String) -> String {
        var prefix = str
        let ch = prefix.removeLast()
        
        if let largeCh = self.suteganaTable[String(ch)] {
            return prefix + largeCh
        }

        guard let pureCh = self.resetKana(String(ch)).last else { return str }

        if let newCh = self.suteganaTable.filter({ $1 == String(pureCh) }).first?.key {
            return prefix + newCh
        } else {
            return str
        }
    }
    
    func switchDakuon(_ str: String) -> String {
        var prefix = str
        let ch = prefix.removeLast()
        
        guard let lastValue = ch.unicodeScalars.last?.value else {
            return str + "\u{3099}"
        }
        if lastValue == 0x3099 { // 濁点
            return prefix + String(ch.unicodeScalars.dropLast())
        }

        guard let pureCh = self.resetKana(String(ch)).last else { return str }
        return prefix + String(pureCh) + "\u{3099}"
    }
    
    func switchHandakuon(_ str: String) -> String {
        var prefix = str
        let ch = prefix.removeLast()
        
        guard let lastValue = ch.unicodeScalars.last?.value else {
            return str + "\u{309A}"
        }
        if lastValue == 0x309A { // 半濁点
            return prefix + String(ch.unicodeScalars.dropLast())
        }

        guard let pureCh = self.resetKana(String(ch)).last else { return str }
        return prefix + String(pureCh) + "\u{309A}"
    }
}
