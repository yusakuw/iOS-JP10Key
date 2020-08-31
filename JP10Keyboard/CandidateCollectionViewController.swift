//
//  CandidateCollectionViewController.swift
//

import UIKit

private let reuseIdentifier = "CandidateCell"

class CandidateCollectionViewController: UICollectionViewController, InputManagerDelegate {
    var inputManager: InputManager?
    
    var keyboardInputDelegate: KeyboardInputDelegate?
    var candidates: [(String, String)] = [] {
        didSet {
            self.collectionView.reloadData()
            if !self.candidates.isEmpty {
                self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
            }
        }
    }
    
    func changeRawString(_ str: String) {
        self.inputManager?.requestCandidates(forInput: str)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputManager = InputManager()
        self.inputManager?.delegate = self
        
        self.candidates = []
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.candidates.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        let label = cell.contentView.viewWithTag(11100) as! UILabel
        label.text = self.candidates[indexPath.item].1
    
        cell.backgroundColor = .systemGroupedBackground
        let selectedBgView = UIView(frame: cell.frame)
        selectedBgView.backgroundColor = .systemGray
        cell.selectedBackgroundView = selectedBgView
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rawText = self.candidates[indexPath.item].0
        let convertedText = self.candidates[indexPath.item].1
        self.inputManager?.commitCandidate(rawText, value: convertedText)
        self.keyboardInputDelegate?.convertText(rawText: rawText, convertedText: convertedText)
    }
    
    // MARK: InputManagerDelegate
    
    private var objcInputCandidates: [InputCandidate] = [] {
        didSet {
            self.candidates = []
            for cand in self.objcInputCandidates {
                self.candidates.append((cand.input, cand.candidate))
            }
        }
    }
    
    func inputManager(_ inputManager: InputManager!, didCompleteWithCandidates candidates: [Any]!) {
        self.objcInputCandidates = candidates as! [InputCandidate]
    }
    
    func inputManager(_ inputManager: InputManager!, didFailWithError error: Error!) {
    }
    
}
