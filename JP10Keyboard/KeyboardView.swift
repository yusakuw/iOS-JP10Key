//
//  KeyboardView.swift
//

import UIKit

enum ReturnKeyText: String {
    case confirm = "確定"
    case newline = "改行"
    case open = "開く"
}

enum SpaceKeyText: String {
    case space = "空白"
    case next = "次候補"
}



class KeyboardView: UIView {
    @IBOutlet var charKeys: [UIButton] = []
    @IBOutlet var numModeKey: KeyButton!
    @IBOutlet var abcModeKey: KeyButton!
    @IBOutlet var kanaModeKey: KeyButton!
    @IBOutlet var changeKey: KeyButton!
    @IBOutlet var deleteKey: UIButton!
    @IBOutlet var spaceKey: UIButton!
    @IBOutlet var returnKey: UIButton!
    @IBOutlet var keyPopupLabel: UILabel!
    @IBOutlet var keyPopupView: KeyPopupView!

    weak var delegate: KeyboardInputDelegate?
    
    var deleteKeyDownStartTime = Date()
    var deleteKeyTimer: Timer?
    
    var needsInputModeSwitchKey: Bool = true {
        didSet {
            if self.needsInputModeSwitchKey {
                // iPhone 8, iPhone SE, needs globe button
                self.changeKey.imageView?.image = UIImage(systemName: "globe")
            } else {
                // iPhone X series, system globe button enabled
                self.changeKey.imageView?.image = UIImage(systemName: "keyboard.chevron.compact.down")
            }
        }
    }
    
    var keyboardMode: KeyboardMode = .kanaMode {
        didSet {
            for x in 1...3 {
                for y in 0...3 {
                    let labels = KeyLabels.shared.getInputLabels(x: x, y: y,mode: self.keyboardMode)
                    guard labels.count > 0 else { break }
                    guard let button = charKeys.filter({$0.tag == 100+(x*10)+y}).first else { break }
                    if self.keyboardMode == .kanaMode && !(y == 3 && x != 2) {
                        button.setTitle(labels.first!, for: .normal)
                    } else if self.keyboardMode == .numMode && !(y == 3 && x != 2) {
                        button.titleLabel?.textAlignment = .center
                        button.titleLabel?.numberOfLines = 0
                        button.setTitle(
                            labels.first! + "\n" + labels.dropFirst(1).joined(),
                            for: .normal
                        )
                    } else {
                        button.setTitle(labels.joined(), for: .normal)
                    }
                }
            }
            self.numModeKey.bgColor = .systemGray2
            self.abcModeKey.bgColor = .systemGray2
            self.kanaModeKey.bgColor = .systemGray2
            switch self.keyboardMode {
            case .numMode:
                self.numModeKey.bgColor = .systemGroupedBackground
            case .abcMode:
                self.abcModeKey.bgColor = .systemGroupedBackground
            case .kanaMode:
                self.kanaModeKey.bgColor = .systemGroupedBackground
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        for charKey in self.charKeys {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapDetected(_:)))
            let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panDetected(_:)))
            charKey.addGestureRecognizer(tapRecognizer)
            charKey.addGestureRecognizer(panRecognizer)
        }
        self.numModeKey.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(numModeKeyTapDetected(_:))))
        self.abcModeKey.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(abcModeKeyTapDetected(_:))))
        self.kanaModeKey.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(kanaModeKeyTapDetected(_:))))

        self.spaceKey.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(spaceKeyTapDetected(_:))))
        self.returnKey.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnKeyTapDetected(_:))))

        self.deleteKey.addTarget(self, action: #selector(self.deleteKeyDown), for: .touchDown)
        self.deleteKey.addTarget(self, action: #selector(self.deleteKeyUp), for: [.touchUpInside, .touchUpOutside])

        // behavior of self.changeKey is defined at KeyboardViewController.swift

        self.keyPopupView.isHidden = true
        
        // 暫定
        self.keyboardMode = .kanaMode
    }
    
    @objc func tapDetected(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        guard let view = sender.view else { return }
        
        // detect key by tag: ref KeyboardView.xib
        let aryX: Int = view.tag % 100 / 10
        let aryY: Int = view.tag % 10

        let title = KeyLabels.shared.getInputLabel(
            x: aryX, y: aryY, direction: .none, mode: self.keyboardMode
        ) ?? ""
        self.delegate?.insertText(title)
        self.keyPopupView.isHidden = true
    }
    
    func changeReturnKeyLabel(_ info: ReturnKeyText) {
        self.returnKey.setTitle(info.rawValue, for: .normal)
    }
    func changeSpaceKeyLabel(_ info: SpaceKeyText) {
        self.spaceKey.setTitle(info.rawValue, for: .normal)
    }

    // MARK: Gestures
    
    @objc func panDetected(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        
        // detect key by tag: ref KeyboardView.xib
        let aryX: Int = view.tag % 100 / 10
        let aryY: Int = view.tag % 10
        
        // detect flick direction
        let pointFromOrigin = sender.location(in: view)
        let point = CGPoint(x: pointFromOrigin.x - view.bounds.width/2, y: pointFromOrigin.y - view.bounds.height/2)
        
        var direction: KeyDirection
        if abs(point.x) <= (view.bounds.width / 2) && abs(point.y) <= (view.bounds.height / 2) {
            direction = .none
        } else {
            if point.x >= point.y {
                if point.x <= -point.y {
                    direction = .up
                } else {
                    direction = .right
                }
            } else {
                if point.x <= -point.y {
                    direction = .left
                } else {
                    direction = .down
                }
            }
        }
        
        var title = KeyLabels.shared.getInputLabel(
            x: aryX, y: aryY, direction: direction, mode: self.keyboardMode
        )
        if title == nil {
            title = KeyLabels.shared.getInputLabel(
                x: aryX, y: aryY, direction: .none, mode: self.keyboardMode
            ) ?? ""
            direction = .none
        }
        
        switch sender.state {
        case .changed, .began:
            self.showKeyPopupView(view: view, direction: direction, text: title!)
        case .ended:
            self.delegate?.insertText(title!)
            self.keyPopupView.isHidden = true
        default:
            self.keyPopupView.isHidden = true
        }
    }
    
    private func showKeyPopupView(view: UIView, direction: KeyDirection, text: String) {
        switch direction {
        case .none:
            self.keyPopupView.center = view.center
        case .up:
            self.keyPopupView.center = CGPoint(
                x: view.center.x, y: view.center.y - view.frame.height
            )
        case .left:
            self.keyPopupView.center = CGPoint(
                x: view.center.x - view.frame.width, y: view.center.y
            )
        case .down:
            self.keyPopupView.center = CGPoint(
                x: view.center.x, y: view.center.y + view.frame.height
            )
        case .right:
            self.keyPopupView.center = CGPoint(
                x: view.center.x + view.frame.width, y: view.center.y
            )
        }
        self.keyPopupLabel.text = text
        self.keyPopupView.isHidden = false
    }

    @objc func numModeKeyTapDetected(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        if self.keyboardMode != .numMode {
            self.keyboardMode = .numMode
        }
    }
    
    @objc func abcModeKeyTapDetected(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        if self.keyboardMode != .abcMode {
            self.keyboardMode = .abcMode
        }
    }
    
    @objc func kanaModeKeyTapDetected(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        if self.keyboardMode != .kanaMode {
            self.keyboardMode = .kanaMode
        }
    }
    
    @objc func spaceKeyTapDetected(_ sender: UITapGestureRecognizer) {
        self.delegate?.insertText(" ")
    }
    
    @objc func returnKeyTapDetected(_ sender: UITapGestureRecognizer) {
        self.delegate?.insertText("\n")
    }
    
    @objc func deleteKeyDown() {
        self.delegate?.deleteBackward()
        self.deleteKeyDownStartTime = Date()
        self.deleteKeyTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            let span: TimeInterval = timer.fireDate.timeIntervalSince(self.deleteKeyDownStartTime)
            if span > 0.4 {
                self.delegate?.deleteBackward()
            }
        })
    }

    @objc func deleteKeyUp() {
        self.deleteKeyTimer?.invalidate()
    }
}
