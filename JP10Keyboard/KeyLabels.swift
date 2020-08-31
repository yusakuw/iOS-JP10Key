//
//  KeyLabels.swift
//

import Foundation

class KeyLabels {
    static let shared = KeyLabels()
    private init() {}
    
    func getInputLabels(mode: KeyboardMode) -> [[[String]]] {
        switch mode {
        case .kanaMode:
            return self.kanaLabels
        case .numMode:
            return self.numLabels
        case .abcMode:
            return self.abcLabels
        }
    }
    
    func getInputLabel(x keyX: Int, y keyY: Int, direction: KeyDirection, mode: KeyboardMode) -> String? {
        let results = self.getInputLabels(x: keyX, y: keyY, mode: mode)
        if results.count == 0 { return nil }
        
        guard (direction.rawValue < results.count) else {
            return nil
        }
        return results[direction.rawValue]
    }
    
    func getInputLabels(x keyX: Int, y keyY: Int, mode: KeyboardMode) -> [String] {
        // キーボード範囲外はnil
        guard (0 <= keyX && keyX <= 4 && 0 <= keyY && keyY <= 3) else { return [] }
        
        if (keyX == 0) {
            switch keyY {
            case 0:
                return ["☆123"]
            case 1:
                return ["ABC"]
            case 2:
                return ["あいう"]
            case 3:
                return ["[change]"]
            default:
                return []
            }
        } else if (keyX == 4) {
            switch keyY {
            case 0:
                return ["[backspace]"]
            case 1:
                return ["空白"]
            case 2, 3:
                return ["確定"]
            default:
                return []
            }
        }

        let aryX = keyX - 1, aryY = keyY
        switch mode {
        case .kanaMode:
            return self.kanaLabels[aryY][aryX]
        case .numMode:
            return self.numLabels[aryY][aryX]
        case .abcMode:
            return self.abcLabels[aryY][aryX]
        }
    }
    
    private let kanaLabels: [[[String]]] = [
        [
            ["あ", "い", "う", "え", "お"],
            ["か", "き", "く", "け", "こ"],
            ["さ", "し", "す", "せ", "そ"]
        ],
        [
            ["た", "ち", "つ", "て", "と"],
            ["な", "に", "ぬ", "ね", "の"],
            ["は", "ひ", "ふ", "へ", "ほ"]
        ],
        [
            ["ま", "み", "む", "め", "も"],
            ["や", "（", "ゆ", "）", "よ"],
            ["ら", "り", "る", "れ", "ろ"]
        ],
        [
            ["ﾞ", "ﾟ", "小"],
            ["わ", "を", "ん", "ー"],
            ["、", "。", "？", "！"]
        ]
    ]
    
    private let numLabels: [[[String]]] = [
        [
            ["1", "☆", "♪", "→"],
            ["2", "¥", "$", "€"],
            ["3", "%", "°", "#"]
        ],
        [
            ["4", "○", "*", "・"],
            ["5", "+", "×", "÷"],
            ["6", "<", "=", ">"]
        ],
        [
            ["7", "「", "」", "："],
            ["8", "〒", "々", "〆"],
            ["9", "^", "|", "\\"]
        ],
        [
            ["(", ")", "[", "]"],
            ["0", "〜", "…"],
            [".", ",", "-", "/"]
        ]
    ]
    
    private let abcLabels: [[[String]]] = [
        [
            ["@", "#", "/", "&", "_"],
            ["A", "B", "C"],
            ["D", "E", "F"]
        ],
        [
            ["G", "H", "I"],
            ["J", "K", "L"],
            ["M", "N", "O"]
        ],
        [
            ["P", "Q", "R", "S"],
            ["T", "U", "V"],
            ["W", "X", "Y", "Z"]
        ],
        [
            ["a/A"],
            ["'", "\"", "(", ")"],
            [".", ",", "?", "!"]
        ]
    ]
}
