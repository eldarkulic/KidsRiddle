//
//  ViewController.swift
//  KidsRiddle
//
//  Created by Eldar on 26. 7. 2024..
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var riddleImageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    var riddles: [Riddle] = []
    var currentRiddleIndex: Int = 0
    var isAnswerRevealed: Bool = false
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemTeal
        
        if let loadedRiddles = loadRiddles() {
            riddles = loadedRiddles
            showRiddle()
        } else {
            questionLabel.text = "No riddles available"
            answerLabel.text = ""
        }
        nextButton.isEnabled = false
                nextButton.backgroundColor = UIColor.systemGray
    }
    
    func loadRiddles() -> [Riddle]? {
        if let url = Bundle.main.url(forResource: "riddle", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let riddles = try JSONDecoder().decode([Riddle].self, from: data)
                return riddles
            } catch {
                print("Error loading riddles: \(error)")
            }
        }
        return nil
    }
    
    func showRiddle() {
        let riddle = riddles[currentRiddleIndex]
        questionLabel.text = riddle.question
        answerLabel.text = "??"
        isAnswerRevealed = false
        riddleImageView.image = UIImage(named: "questionMark")

        
        nextButton.isEnabled = false
               nextButton.backgroundColor = UIColor.systemGray
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        currentRiddleIndex = (currentRiddleIndex + 1) % riddles.count
        showRiddle()
    }
    
    @IBAction func revealButtonTapped(_ sender: UIButton) {
        if !isAnswerRevealed {
            let riddle = riddles[currentRiddleIndex]
            answerLabel.text = riddle.answer
            isAnswerRevealed = true
            nextButton.isEnabled = true
            let lowercasedAnswer = riddle.answer.lowercased()
            riddleImageView.image = UIImage(named: lowercasedAnswer)
                       nextButton.backgroundColor = UIColor.systemBlue
        }
    }
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
    currentRiddleIndex = 0
    showRiddle()
    }
    
}

