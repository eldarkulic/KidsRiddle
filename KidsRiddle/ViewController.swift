//
//  ViewController.swift
//  KidsRiddle
//
//  Created by Eldar on 26. 7. 2024..
//
import MessageUI
import UIKit

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var riddles: [Riddle] = []
    var currentRiddleIndex: Int = 0
    var isAnswerRevealed: Bool = false
    
    lazy var maxRiddles: Int = {
        return riddles.count
    }()
    
    // UI Elements
    let riddleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let answerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "questionMark")
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        //    imageView.clipsToBounds = true
        
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.35
        imageView.layer.shadowOffset = CGSize(width: 5, height: 5)
        imageView.layer.shadowRadius = 8
        return imageView
    }()
    
    let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        
        let image = UIImage(systemName: "gearshape")
        button.setImage(image, for: .normal)
        
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let showButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Prikaži", for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Nastavi", for: .normal)
        button.backgroundColor = .lightGray
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let restartButton: UIButton = {
        let button = UIButton(type: .system)
        
        
        let image = UIImage(systemName: "arrow.counterclockwise")
        button.setImage(image, for: .normal)
        
        button.backgroundColor = .lightGray
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.3, green: 0.8, blue: 0.9, alpha: 1.0)
        
        // Add subviews
        view.addSubview(riddleLabel)
        view.addSubview(imageView)
        view.addSubview(showButton)
        view.addSubview(nextButton)
        view.addSubview(answerLabel)
        view.addSubview(restartButton)
        view.addSubview(settingsButton)
        
        //button actions
        showButton.addTarget(self, action: #selector(revealButtonTapped(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
        restartButton.addTarget(self, action: #selector(restartButtonTapped(_:)), for: .touchUpInside)
        
        // Set constraints
        setupConstraints()
        if let loadedRiddles = loadRiddles() {
            riddles = loadedRiddles
            showRiddle()
        } else {
            riddleLabel.text = "No riddles available"
            answerLabel.text = ""
        }
        //Settings Menu
        let settingsMenu = UIMenu(title: "Postavke", children: [
            UIAction(title: "Broj zagonetki") { [weak self] _ in
                self?.showLimitRiddlesAlert()
            },
            UIAction(title: "Jezik") { _ in
                print("Change Language tapped")
            },
            UIAction(title: "Pošalji feedback") {  [weak self] _ in
                self?.sendFeedback()
            }
        ])
        
        settingsButton.menu = settingsMenu
        settingsButton.showsMenuAsPrimaryAction = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "⚙️", menu: settingsMenu)
        
    }
    
    func sendFeedback() {
            guard MFMailComposeViewController.canSendMail() else {
                print("Mail services are not available")
                return
            }

            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(["eldar.kulic.dev@gmail.com"])
            mailComposer.setSubject("Feedback for Your App")
            mailComposer.setMessageBody("Hello Eldar,\n\nI would like to share the following feedback about your app:\n\n", isHTML: false)
            
            present(mailComposer, animated: true)
        }
    
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
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
    
    func showLimitRiddlesAlert() {
        let alert = UIAlertController(title: "Ograniči broj zagonetki",
                                      message: "Unesi maksimalan broj pitanja:",
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Unesite broj"
            textField.keyboardType = .numberPad
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text, let number = Int(text), number > 0 {
                guard let self = self else { return }  // Unwrapping weak self
                
                self.maxRiddles = number
                self.currentRiddleIndex = 0
                self.imageView.image = UIImage(named: "questionMark")
                self.showRiddle()
                
                print("Maksimalan broj zagonetki postavljen na: \(number)")
            } else {
                print("Neispravan unos")
            }
        }
        
        
        let cancelAction = UIAlertAction(title: "Otkaži", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc func nextButtonTapped(_ sender: UIButton) {
        currentRiddleIndex = (currentRiddleIndex + 1) % riddles.count
        imageView.image = UIImage(named: "questionMark")
        showRiddle()
    }
    
    @objc func revealButtonTapped(_ sender: UIButton) {
        if !isAnswerRevealed {
            let riddle = riddles[currentRiddleIndex]
            answerLabel.text = riddle.answer
            isAnswerRevealed = true
            nextButton.isEnabled = true
            let lowercasedAnswer = riddle.answer.lowercased()
            imageView.image = UIImage(named: lowercasedAnswer)
            nextButton.backgroundColor = UIColor.systemBlue
        }
        
        if currentRiddleIndex == maxRiddles {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.systemGray
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                let alert = UIAlertController(title: "Da li želite da počnete ispočetka?", message: nil, preferredStyle: .actionSheet)
                
                // Add options to the popup menu
                let acceptRestart = UIAlertAction(title: "Da!", style: .default) { _ in
                    self.currentRiddleIndex = 0
                    self.imageView.image = UIImage(named: "questionMark")
                    self.showRiddle()
                }
                
                let cancelRestart = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(acceptRestart)
                alert.addAction(cancelRestart)
                self.present(alert, animated: true, completion: nil)
            }}}
    
    
    
    func showRiddle() {
        let riddle = riddles[currentRiddleIndex]
        riddleLabel.text = riddle.question
        answerLabel.text = "??"
        isAnswerRevealed = false
    }
    
    @objc func restartButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Da li želite da počnete ispočetka?", message: nil, preferredStyle: .actionSheet)
        
        // Add options to the popup menu
        let acceptRestart = UIAlertAction(title: "Da!", style: .default) { _ in
            self.currentRiddleIndex = 0
            self.imageView.image = UIImage(named: "questionMark")
            self.showRiddle()
        }
        
        let cancelRestart = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(acceptRestart)
        alert.addAction(cancelRestart)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            restartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            restartButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            restartButton.heightAnchor.constraint(equalToConstant: 40),
            restartButton.widthAnchor.constraint(equalToConstant: 40),
            
            //   Settings Button (Top-Left) - If added later
            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            settingsButton.heightAnchor.constraint(equalToConstant: 40),
            settingsButton.widthAnchor.constraint(equalToConstant: 40),
            
            riddleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            riddleLabel.topAnchor.constraint(equalTo: restartButton.bottomAnchor, constant: 10),
            riddleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            riddleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: riddleLabel.bottomAnchor, constant: 50),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            answerLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            answerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            showButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            showButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            showButton.heightAnchor.constraint(equalToConstant: 50),
            showButton.widthAnchor.constraint(equalToConstant: 120),
            
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
}
