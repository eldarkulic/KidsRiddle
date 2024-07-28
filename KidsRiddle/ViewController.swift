//
//  ViewController.swift
//  KidsRiddle
//
//  Created by Eldar on 26. 7. 2024..
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    var riddles: [Riddle] = []
        var currentRiddleIndex: Int = 0
        
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
            answerLabel.text = riddle.answer // Show the answer for now
        }
        
        @IBAction func nextButtonTapped(_ sender: UIButton) {
            currentRiddleIndex = (currentRiddleIndex + 1) % riddles.count
            showRiddle()
        }
    }

