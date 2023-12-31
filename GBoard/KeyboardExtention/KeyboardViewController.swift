//
//  KeyboardViewController.swift
//  GBoard
//
//  Created by 남보경 on 2023/12/31.
//
import UIKit
import SnapKit

class KeyboardViewController: UIInputViewController {

    let keyboardRows = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["Z", "X", "C", "V", "B", "N", "M"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }

    func setupKeyboard() {
        let keyboardStackView = UIStackView()
        keyboardStackView.axis = .vertical
        keyboardStackView.distribution = .fillEqually
        keyboardStackView.alignment = .fill
        keyboardStackView.spacing = 5
        view.addSubview(keyboardStackView)

        keyboardStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 3, bottom: 10, right: 3))
        }

        for row in keyboardRows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.alignment = .fill
            rowStackView.spacing = 5
            keyboardStackView.addArrangedSubview(rowStackView)

            for key in row {
                let button = createButtonWithTitle(title: key)
                rowStackView.addArrangedSubview(button)
            }
        }
    }

    func createButtonWithTitle(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc func keyTapped(_ sender: UIButton) {
        guard let key = sender.titleLabel?.text else { return }
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.insertText(key)
    }
}
