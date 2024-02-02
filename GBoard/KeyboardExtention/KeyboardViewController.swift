//
//  KeyboardViewController.swift
//  GBoard
//
//  Created by 남보경 on 2023/12/31.
//
import UIKit
import SnapKit

class KeyboardWrappingStackView: UIStackView {
    
    var deleteTimer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.axis = .vertical
        self.distribution = .fillEqually
        self.alignment = .fill
        self.spacing = 10
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class KeyboardRowStackView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.axis = .horizontal
        self.distribution = .fillEqually
        self.alignment = .fill
        self.spacing = 5
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EmptyView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.snp.makeConstraints{
            $0.size.equalTo(CGSize(width: 4.5, height: 45)) // horizontal row height와 같이 변경해야 함
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum KeyboardPage {
    case korean
    case english
    case number
    case symbol
}

class KeyboardViewController: UIInputViewController {
    
    var keyboardPage: KeyboardPage = .korean
    var deleteTimer: Timer?
    
    // 🤔 코드 개선을 위한 고민 - switch를 이용한 함수를 만들면 중복을 없앨 수 있지 않을까?
    let firstRowEn = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
    let secondRowEn = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
    let thirdRowEn = ["Z", "X", "C", "V", "B", "N", "M"]
    
    let firstRowNum = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    let secondRowNum = ["-", "/", ":", ";", "(", ")", "$", "&", "@", "“"]
    let thirdRowNum = [".", ",", "?", "!", "’"]
    
    let firstRowKo = ["ㅂ", "ㅈ", "ㄷ", "ㄱ", "ㅅ", "ㅛ", "ㅕ", "ㅑ", "ㅐ", "ㅔ"]
    let firstCapitalizeRowKo = ["ㅃ", "ㅉ", "ㄸ", "ㄲ", "ㅆ", "ㅛ", "ㅕ", "ㅑ", "ㅒ", "ㅖ"]
    let secondRowKo = ["ㅁ", "ㄴ", "ㅇ", "ㄹ", "ㅎ", "ㅗ", "ㅓ", "ㅏ", "ㅣ"]
    let thirdRowKo = ["ㅋ", "ㅌ", "ㅊ", "ㅍ", "ㅠ", "ㅜ", "ㅡ"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("KeyboardViewController - ViewDidLoad")
        setupKeyboardLayout()
    }
    
    func setupKeyboardLayout() {
        let wrapViewMargin: CGFloat = 3
        let verticalSpacing: CGFloat = 5
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width
        let buttonWidth = (screenWidth - (wrapViewMargin * 2) - (verticalSpacing * 9)) / 10  // 첫 번째 줄 기준으로 버튼 크기를 계산하고 다른 줄에도 적용
        
        // 최상위 view의 size를 임의 지정
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 260))
        
        // 전체적인 키보드 레이아웃
        let keyboardStackView = KeyboardWrappingStackView()
        self.view.addSubview(keyboardStackView)
        keyboardStackView.snp.makeConstraints{
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 3, bottom: .zero, right: 3))
        }
        
        // 첫 번째 줄 stackView - 한글
        let firstRowStackView = KeyboardRowStackView()
        for key in firstRowKo {
            let button = createButtonWithTitle(title: key)
            button.snp.makeConstraints {
                $0.width.equalTo(buttonWidth)
            }
            firstRowStackView.addArrangedSubview(button)
        }
        
        // 두 번째 줄 stackView - 한글
        let secondRowStackView = KeyboardRowStackView()
        secondRowStackView.isLayoutMarginsRelativeArrangement = true
        secondRowStackView.layoutMargins = UIEdgeInsets(top: .zero, left: buttonWidth / 2, bottom: .zero, right: buttonWidth / 2)
        
        for key in secondRowKo {
            let button = createButtonWithTitle(title: key)
            button.snp.makeConstraints {
                $0.width.equalTo(buttonWidth)
            }
            secondRowStackView.addArrangedSubview(button)
        }
        
        // 세 번째 줄 stackView = 한글
        let thirdRowStackView = KeyboardRowStackView()
        thirdRowStackView.distribution = .equalSpacing
        
        var shiftButton = UIButton()
        shiftButton.setImage(UIImage(systemName:"shift"), for: .normal)
        shiftButton.tintColor = .label
        shiftButton.backgroundColor = .darkerKeyColor
        shiftButton.layer.cornerRadius = 5
        shiftButton.addTarget(self, action: #selector(shiftButtonTapped(_:)), for: .touchUpInside)
        shiftButton.snp.makeConstraints {
            $0.width.equalTo(buttonWidth + 5)
        }
        thirdRowStackView.addArrangedSubview(shiftButton)
        
        let firstBlank = EmptyView()
        thirdRowStackView.addArrangedSubview(firstBlank)
        
        for key in thirdRowKo {
            let button = createButtonWithTitle(title: key)
            button.snp.makeConstraints {
                $0.width.equalTo(buttonWidth)
            }
            thirdRowStackView.addArrangedSubview(button)
        }
        
        var deleteButton = UIButton()
        deleteButton.setImage(UIImage(systemName:"delete.backward"), for: .normal)
        deleteButton.tintColor = .label
        deleteButton.layer.cornerRadius = 5
        deleteButton.backgroundColor = .darkerKeyColor
        deleteButton.addTarget(self, action: #selector(deleteButtonTouchDown(_:)), for: .touchDown)
        deleteButton.addTarget(self, action: #selector(deleteButtonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        deleteButton.snp.makeConstraints {
            $0.width.equalTo(buttonWidth + 5)
        }
        let secondBlank = EmptyView()
        
        thirdRowStackView.addArrangedSubview(secondBlank)
        thirdRowStackView.addArrangedSubview(deleteButton)
        
        // 네 번째 줄 stackView - 한글
        // 아래쪽에 지구본이랑 음성뜨는 설정해야 함(iphone SE 등 옛날 기종 중 홈버튼 있는거는 안됨)
        let fourthRowStackView = KeyboardRowStackView()
        fourthRowStackView.distribution = .fillProportionally
        let transformButton = UIButton()
        transformButton.setTitle("123", for: .normal)
        transformButton.titleLabel?.font = .systemFont(ofSize: 15)
        transformButton.setTitleColor(.label, for: .normal)
        transformButton.backgroundColor = .darkerKeyColor
        transformButton.layer.cornerRadius = 5
        transformButton.addTarget(self, action: #selector(shiftButtonTapped(_:)), for: .touchUpInside)
        transformButton.snp.makeConstraints {
            $0.width.equalTo(buttonWidth + 5)
        }
        fourthRowStackView.addArrangedSubview(transformButton)
        
        let globeButton = UIButton()
        globeButton.setTitle("한글", for: .normal)
        globeButton.titleLabel?.font = .systemFont(ofSize: 15)
        globeButton.setTitleColor(.label, for: .normal)
        globeButton.backgroundColor = .darkerKeyColor
        globeButton.layer.cornerRadius = 5
        globeButton.addTarget(self, action: #selector(shiftButtonTapped(_:)), for: .touchUpInside)
        globeButton.snp.makeConstraints {
            $0.width.equalTo(buttonWidth * 2)
        }
        fourthRowStackView.addArrangedSubview(globeButton)
        
        let spaceButton = UIButton()
        
        spaceButton.setTitle("스페이스", for: .normal)
        spaceButton.titleLabel?.font = .systemFont(ofSize: 15)
        spaceButton.setTitleColor(.label, for: .normal)
        spaceButton.backgroundColor = .basicKeyColor
        spaceButton.layer.cornerRadius = 5
        spaceButton.addTarget(self, action: #selector(spaceButtonTapped(_:)), for: .touchUpInside)
        spaceButton.addTarget(self, action: #selector(spaceButtomTouchDown(_:)), for: .touchDown)
        spaceButton.addTarget(self, action: #selector(spaceButtomTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        spaceButton.snp.makeConstraints {
            $0.height.equalTo(45)
        }
        fourthRowStackView.addArrangedSubview(spaceButton)
        
        let enterButton = UIButton()
        enterButton.tintColor = .label
        enterButton.setImage(UIImage(systemName: "return"), for: .normal)
        enterButton.backgroundColor = .darkerKeyColor
        enterButton.layer.cornerRadius = 5
        enterButton.addTarget(self, action: #selector(enterButtonTapped(_:)), for: .touchUpInside)
        enterButton.addTarget(self, action: #selector(enterButtomTouchDown(_:)), for: .touchDown)
        enterButton.addTarget(self, action: #selector(enterButtomTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        enterButton.snp.makeConstraints {
            $0.width.equalTo(buttonWidth * 2)
        }
        fourthRowStackView.addArrangedSubview(enterButton)
        
        let requestButton = UIButton()
        requestButton.tintColor = .white
        requestButton.setImage(UIImage(systemName: "ellipsis.curlybraces"), for: .normal)
        requestButton.backgroundColor = .gptColor
        requestButton.layer.cornerRadius = 5
        requestButton.addTarget(self, action: #selector(enterButtonTapped(_:)), for: .touchUpInside)
        requestButton.snp.makeConstraints {
            $0.width.equalTo(buttonWidth + 5)
        }
        fourthRowStackView.addArrangedSubview(requestButton)
        
        keyboardStackView.addArrangedSubview(firstRowStackView)
        keyboardStackView.addArrangedSubview(secondRowStackView)
        keyboardStackView.addArrangedSubview(thirdRowStackView)
        keyboardStackView.addArrangedSubview(fourthRowStackView)
    }
    
    func createButtonWithTitle(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 23)
        button.tintColor = .label
        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.backgroundColor = .basicKeyColor
        button.snp.makeConstraints {
            $0.height.equalTo(45)
        }
        return button
    }
    
    @objc func keyTapped(_ sender: UIButton) {
        guard let key = sender.titleLabel?.text else { return }
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.insertText(key)
    }
    
    // 기능 구현 아직 안함
    @objc func shiftButtonTapped(_ sender: UIButton) {
        sender.backgroundColor = .label
        sender.setImage(UIImage(named: "shift.fill"), for: .normal)
        print("shiftButtonTapped")
    }
    
    
    // 백스페이스 버튼 기능
    //    @objc func deleteButtomTouchDown(_ sender: UIButton) {
    //        print("deleteButtomTouchDown")
    //        sender.backgroundColor = .basicKeyColor
    //        sender.setImage(UIImage(systemName: "delete.backward.fill"), for: .normal)
    //        deleteCharacter()
    //
    //        // 지연 후 삭제를 위한 타이머 시작
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [self] in
    //            deleteTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(deleteCharacter), userInfo: nil, repeats: true)
    //        }
    //
    //    }
    //
    //    @objc func deleteButtonReleased(_ sender: UIButton) {
    //        print("deleteButtonReleased")
    //        sender.backgroundColor = .darkerKeyColor
    //        sender.setImage(UIImage(systemName: "delete.backward"), for: .normal)
    //        deleteTimer?.invalidate()
    //    }
    
    
    @objc func deleteButtonTouchDown(_ sender: UIButton) {
        sender.backgroundColor = .basicKeyColor
        deleteCharacter() // 첫 번째 문자 즉시 삭제
        
        // 연속 삭제를 위한 타이머 시작 (초기 지연 후)
        deleteTimer?.invalidate() // 혹시 모를 이전 타이머 정리
        deleteTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(deleteCharacter), userInfo: nil, repeats: true) // Timer 객체 생성
        deleteTimer?.fireDate = Date().addingTimeInterval(0.6) // Timer 실행 시점 지정
    }
    
    @objc func deleteButtonReleased(_ sender: UIButton) {
        sender.backgroundColor = .darkerKeyColor
        deleteTimer?.invalidate() // 버튼에서 손을 뗐을 때 타이머 중지
    }
    
    @objc func deleteCharacter() {
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.deleteBackward()
    }
    
    // 줄바꿈 기능
    @objc func enterButtonTapped(_ sender: UIButton) {
        print("enterButtonTapped")
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.insertText("\n")
    }
    
    @objc func enterButtomTouchDown(_ sender: UIButton) {
        print("enterButtomTouchDown")
        sender.setImage(UIImage(named: "return.fill"), for: .selected)
        sender.backgroundColor = .basicKeyColor
    }
    
    @objc func enterButtomTouchUp(_ sender: UIButton) {
        print("enterButtomTouchUp")
        sender.setImage(UIImage(named: "return"), for: .selected)
        sender.backgroundColor = .darkerKeyColor
    }
    
    
    // 스페이스바 기능
    @objc func spaceButtonTapped(_ sender: UIButton) {
        print("spaceButtonTapped")
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.insertText(" ")
    }
    
    @objc func spaceButtomTouchDown(_ sender: UIButton) {
        print("spaceButtomTouchDown")
        sender.backgroundColor = .darkerKeyColor
    }
    
    @objc func spaceButtomTouchUp(_ sender: UIButton) {
        print("spaceButtomTouchUp")
        sender.backgroundColor = .basicKeyColor
    }
}
