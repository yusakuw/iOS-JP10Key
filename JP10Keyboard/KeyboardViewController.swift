//
//  KeyboardViewController.swift
//

import UIKit

protocol KeyboardInputDelegate: AnyObject {
    func insertText(_ text: String)
    func convertText(rawText: String, convertedText: String)
    func deleteBackward()
}

class KeyboardViewController: UIInputViewController, KeyboardInputDelegate {
    var candViewController: CandidateCollectionViewController!
    var keyboardView: KeyboardView!
    
    var candidateRawText: String = "" {
        didSet {
            if self.candidateRawText.isEmpty {
                self.keyboardView.changeReturnKeyLabel(ReturnKeyText.newline)
                self.keyboardView.changeSpaceKeyLabel(SpaceKeyText.space)
            } else {
                self.keyboardView.changeReturnKeyLabel(ReturnKeyText.confirm)
                self.keyboardView.changeSpaceKeyLabel(SpaceKeyText.next)
            }
            self.candViewController.changeRawString(
                self.candidateRawText.precomposedStringWithCanonicalMapping
            )
        }
    }
    
    private enum keyboardHeight: CGFloat {
        case portrait = 260
        case landscape = 196
    }
    var heightConstrait: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.candViewController = UIStoryboard(name: "Candidate", bundle: nil).instantiateInitialViewController() as? CandidateCollectionViewController
        self.candViewController.keyboardInputDelegate = self
        self.view.addSubview(self.candViewController.view)
        
        self.keyboardView = UINib(nibName: "KeyboardView", bundle: nil).instantiate(withOwner: self, options: nil).first as? KeyboardView
        self.keyboardView.delegate = self
        self.view.addSubview(self.keyboardView)
        
        self.keyboardView.changeKey.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.clipsToBounds = false
        
        self.addConstraints()
    }
    
    private func addConstraints() {
        self.heightConstrait = self.view.heightAnchor.constraint(equalToConstant: 0)
        self.heightConstrait.priority = UILayoutPriority(rawValue: 990)
        
        self.candViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.candViewController.view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.candViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.candViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.candViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true

        self.keyboardView.translatesAutoresizingMaskIntoConstraints = false
        self.keyboardView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.keyboardView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.keyboardView.topAnchor.constraint(equalTo: self.candViewController.view.bottomAnchor).isActive = true
        self.keyboardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    override func viewWillLayoutSubviews() {
        self.heightConstrait.isActive = false
        if self.isLandscape(self.view.bounds.size) {
            self.heightConstrait.constant = keyboardHeight.landscape.rawValue
        } else {
            self.heightConstrait.constant = keyboardHeight.portrait.rawValue
        }
        self.heightConstrait.isActive = true
        
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.keyboardView.needsInputModeSwitchKey = self.needsInputModeSwitchKey
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.heightConstrait.isActive = false
        if self.isLandscape(size) {
            self.heightConstrait.constant = keyboardHeight.landscape.rawValue
        } else {
            self.heightConstrait.constant = keyboardHeight.portrait.rawValue
        }
        self.heightConstrait.isActive = true

        for btn in self.keyboardView.subviews {
            btn.setNeedsLayout()
        }
    }
    
    private func isLandscape(_ viewSize: CGSize) -> Bool {
        return viewSize.width >= 480
    }
    
    // MARK: - KeyboardInputDelegate
    
    func insertText(_ text: String) {
        switch text {
        case "ﾞ":
            self.toggleDakuten()
        case "ﾟ":
            self.toggleHandakuten()
        case "小":
            self.toggleSutegana()
        case "a/A":
            self.toggleCapital()
        case "\n":
            if self.candidateRawText.isEmpty {
                self.textDocumentProxy.insertText("\n")
            } else {
                self.selectCandidate()
            }
        case " ":
            if self.candidateRawText.isEmpty {
                self.textDocumentProxy.insertText(" ")
            } else {
                self.chooseNextCandidate()
            }
        default:
            let newCh = text.lowercased()
            self.candidateRawText += newCh
            self.textDocumentProxy.setMarkedText(self.candidateRawText, selectedRange: NSMakeRange((self.candidateRawText as NSString).length, 0))
        }
    }
    
    private func toggleDakuten() {
        self.candidateRawText = KanaMod.shared.switchDakuon(self.candidateRawText)
        self.textDocumentProxy.setMarkedText(self.candidateRawText, selectedRange: NSMakeRange((self.candidateRawText as NSString).length, 0))
    }
    
    private func toggleHandakuten() {
        self.candidateRawText = KanaMod.shared.switchHandakuon(self.candidateRawText)
        self.textDocumentProxy.setMarkedText(self.candidateRawText, selectedRange: NSMakeRange((self.candidateRawText as NSString).length, 0))
    }
    
    private func toggleSutegana() {
        self.candidateRawText = KanaMod.shared.switchSutegana(self.candidateRawText)
        self.textDocumentProxy.setMarkedText(self.candidateRawText, selectedRange: NSMakeRange((self.candidateRawText as NSString).length, 0))
    }
    
    private func toggleCapital() {
        if self.candidateRawText.isEmpty {
            return
        }
        let ch = self.candidateRawText.last!
        let newCh: String
        if ch.isUppercase {
            newCh = ch.lowercased()
        } else /*if ch.isLowercase*/ {
            newCh = ch.uppercased()
        }
        self.candidateRawText = self.candidateRawText.dropLast() + newCh
        self.textDocumentProxy.setMarkedText(self.candidateRawText, selectedRange: NSMakeRange((self.candidateRawText as NSString).length, 0))
    }
    
    private func selectCandidate() {
        if let selected = self.candViewController.collectionView.indexPathsForSelectedItems, selected.count > 0 {
            self.candViewController.collectionView(self.candViewController.collectionView, didSelectItemAt: selected.first!)
        } else {
            self.textDocumentProxy.insertText(self.candidateRawText)
            self.candidateRawText = ""
        }
    }
    
    private func chooseNextCandidate() {
        if let selected = self.candViewController.collectionView.indexPathsForSelectedItems, selected.count > 0 {
            let newSelectRow: Int
            if selected.first!.row == self.candViewController.collectionView.numberOfItems(inSection: 0) {
                newSelectRow = 0
            } else {
                newSelectRow = selected.first!.row + 1
            }
            self.candViewController.collectionView.deselectItem(at: selected.first!, animated: true)
            self.candViewController.collectionView.selectItem(at: IndexPath(row: newSelectRow, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        } else {
            self.candViewController.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }

    func convertText(rawText: String, convertedText: String) {
        self.textDocumentProxy.insertText(convertedText)
        if let range = self.candidateRawText.range(of: rawText) {
            self.candidateRawText = String(self.candidateRawText[range.upperBound...])
        } else {
            self.candidateRawText = ""
        }
        self.textDocumentProxy.setMarkedText(self.candidateRawText, selectedRange: NSMakeRange((self.candidateRawText as NSString).length, 0))
    }
    
    func deleteBackward() {
        if self.candidateRawText.isEmpty {
            self.textDocumentProxy.deleteBackward()
        } else {
            self.candidateRawText.removeLast()
            self.textDocumentProxy.setMarkedText(self.candidateRawText, selectedRange: NSMakeRange((self.candidateRawText as NSString).length, 0))
        }
    }
}
