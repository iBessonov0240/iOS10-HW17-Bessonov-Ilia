//
//  ViewController.swift
//  iOS10-HW17-Bessonov Ilia
//
//  Created by i0240 on 07.08.2023.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Prorerties

    private var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .black
            } else {
                self.view.backgroundColor = .white
            }
        }
    }

    private var isStarting = false
    private let queue = DispatchQueue.global(qos: .utility)
    private var workItem: DispatchWorkItem?
    private let group = DispatchGroup()

    // MARK: - Outlets

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        label.backgroundColor = .systemGray6
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .black
        textField.tintColor = .systemGray4
        textField.textAlignment = .center
        textField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.backgroundColor = .systemGray6
        textField.isSecureTextEntry = true
        return textField
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var anotherButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Button", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(anotherButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Toggle", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stop", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var generatePasswordLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        label.backgroundColor = .systemGray6
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
    }

    // MARK: - Setup

    private func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }

        var password: String = ""
        isStarting = true
        workItem?.cancel()

        let newWorkItem = DispatchWorkItem {
            // Will strangely ends at 0000 instead of ~~~
            while password != passwordToUnlock && self.isStarting {  // Increase MAXIMUM_PASSWORD_SIZE value for more
                self.group.enter()
                password = self.generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
                //             Your stuff here
                self.group.notify(queue: .main) {
                    self.generatePasswordLabel.text = "\(password)"
                    print("\(password)")
                }
                self.group.leave()
                // Your stuff here
            }

            self.group.notify(queue: .main) {
                self.activityIndicator.stopAnimating()

                if password == passwordToUnlock {
                    self.label.text = "Password found: \(password)"
                    self.textField.isSecureTextEntry = false
                } else {
                    self.label.text = "password isn't unlock"
                }
            }
        }
        workItem = newWorkItem
        queue.async(execute: newWorkItem)
    }

    private func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }

    private func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index])
                                   : Character("")
    }

    private func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var str: String = string

        if str.count <= 0 {
            str.append(characterAt(index: 0, array))
        }
        else {
            str.replace(at: str.count - 1,
                        with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))

            if indexOf(character: str.last!, array) == 0 {
                str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
            }
        }

        return str
    }

    private func generateRandomPassword() {
        let allowedCharacters = Array(String().printable)
        let passwordLength = 3
        var randomPassword = ""

        for _ in 0..<passwordLength {
            let randomIndex = Int.random(in: 0..<allowedCharacters.count)
            randomPassword.append(allowedCharacters[randomIndex])
        }

        textField.text = randomPassword
        bruteForce(passwordToUnlock: randomPassword)
    }

    private func setupHierarchy() {
        view.addSubviews([label, textField, activityIndicator, anotherButton, button, stopButton, generatePasswordLabel])
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            textField.heightAnchor.constraint(equalToConstant: 30),

            activityIndicator.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -5),
            activityIndicator.centerYAnchor.constraint(equalTo: textField.centerYAnchor),

            anotherButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 15),
            anotherButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            anotherButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            button.topAnchor.constraint(equalTo: anotherButton.bottomAnchor, constant: 15),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            generatePasswordLabel.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 20),
            generatePasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            generatePasswordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25)
        ])
    }

    // MARK: - Actions

    @objc func anotherButtonTapped() {
//        generateRandomPassword()
        group.notify(queue: .main) {
            self.bruteForce(passwordToUnlock: self.textField.text ?? "")
            self.activityIndicator.startAnimating()
        }
    }

    @objc func buttonTapped() {
        group.notify(queue: .main) {
            self.isBlack.toggle()
        }
    }

    @objc func stopButtonTapped() {
        isStarting = false
        group.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
        }
    }
}
