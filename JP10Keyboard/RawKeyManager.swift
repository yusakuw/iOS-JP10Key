//
//  RawKeyManager.swift
//

import Foundation

class RawKeyManager {
    func getRawKey(x: Int, y: Int, direction: KeyDirection, mode: KeyboardMode) -> String? {
        let rawKey: String?
        switch mode {
        case .kanaMode:
            rawKey = self.getKanaRawKey(x: x, y: y, direction: direction)
        case .numMode:
            rawKey = self.getNumRawKey(x: x, y: y, direction: direction)
        case .abcMode:
            rawKey = self.getAbcRawKey(x: x, y: y, direction: direction)
        }
        
        // write a key log here
        
        return rawKey
    }
    
    private func getKanaRawKey(x: Int, y: Int, direction: KeyDirection) -> String? {
        if (0 < x && x < 4 && y < 3) || (x == 2 && y == 3) {
            // ラベルと同一の文字
            return KeyLabels.shared.getInputLabel(x: x, y: y, direction: direction, mode: .kanaMode)
        }
        return nil
    }
    
    private func getNumRawKey(x: Int, y: Int, direction: KeyDirection) -> String? {
        if (0 < x && x < 4 && y < 3) || (x == 2 && y == 3) {
            // ラベルと同一の文字
            return KeyLabels.shared.getInputLabel(x: x, y: y, direction: direction, mode: .numMode)
        }
        return nil
    }
    
    private func getAbcRawKey(x: Int, y: Int, direction: KeyDirection) -> String? {
        if (0 < x && x < 4 && y < 3) || (x == 2 && y == 3) {
            // ラベルと同一の文字
            return KeyLabels.shared.getInputLabel(x: x, y: y, direction: direction, mode: .abcMode)
        }
        return nil
    }

}
