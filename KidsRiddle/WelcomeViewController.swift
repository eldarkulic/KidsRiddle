//
//  WelcomeViewController.swift
//  KidsRiddle
//
//  Created by Eldar on 28. 2. 2025..
//

import Foundation
import UIKit

class WelcomeViewController: UIViewController {

    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Unesite vaše ime"
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        return textField
    }()

    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Započni", for: .normal)
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nameTextField)
        view.addSubview(startButton)

        NSLayoutConstraint.activate([
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            nameTextField.widthAnchor.constraint(equalToConstant: 200),

            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20)
        ])
    }

    @objc func startButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Molimo unesite vaše ime")
            return
        }

        UserDefaults.standard.set(name, forKey: "userName")

        let mainVC = MainViewController() 
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: true)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Greška", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
