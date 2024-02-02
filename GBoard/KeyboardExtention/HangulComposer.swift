//
//  HangulComposer.swift
//  KeyboardExtention
//
//  Created by 남보경 on 2024/01/01.
//

import Foundation
import UIKit

struct VowelPair: Hashable {
    let firstVowel: String
    let secondVowel: String
}

class HangulComposer: UIInputViewController {
    private var cho: Int? = nil
    private var jung: Int? = nil
    private var jong: Int? = nil
    
    private var consonant = ["ㄱ","ㄴ","ㄷ","ㄹ","ㅁ","ㅂ","ㅅ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ","ㄲ","ㄸ","ㅃ","ㅆ","ㅉ"]
    private var vowel = ["ㅏ","ㅑ","ㅓ","ㅕ","ㅗ","ㅛ","ㅜ","ㅠ","ㅡ","ㅣ","ㅐ","ㅒ","ㅔ","ㅖ","ㅘ","ㅙ","ㅚ","ㅝ","ㅞ","ㅟ","ㅢ"]
    
    // 홑받침의 배열
    private var singleBase = ["ㄱ","ㄴ","ㄷ","ㄹ","ㅁ","ㅂ","ㅅ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
    
    // 받침이 가능한 쌍받침의 배열
    private var doubleBase = ["ㄲ","ㅆ"]
    
    // 받침이 가능한 겹받침의 배열
    private var mixBase = ["ㄳ","ㄵ","ㄶ","ㄺ","ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅄ"]
    
    // 복모음이 가능한 첫 번째 모음의 배열
    private var firstVowelArray = ["ㅗ","ㅜ","ㅡ"]
    
    // 복모음이 가능한 두 번째 모음의 배열
    private var secondVowelArray = ["ㅏ","ㅓ","ㅣ","ㅔ","ㅐ"]
    
    
    /*
     글자 배열의 종류를 프로그램적으로는 대략 9가지로 나눌 수 있을 것 같다.
     
     1. 자음만
     2. 모음만
     3. 자음 + 단모음
     4. 자음 + 단모음 + 홑받침
     5. 자음 + 단모음 + 쌍자음
     -> 쌍자음이라는 경우의 수를 분리하고, 복모음 시 홑받침만 가능하게 하기 위해 분리
     6. 자음 + 단모음 + 겹자음
     7. 자음 + 복모음
     8. 자음 + 복모음 + 홑받침
     
     초성과 중성 종성에 각각 할당해주는 방식으로 적용해야 함
     
     */
    // 텍스트 입력 이벤트에 따라 활성화/비활성화
    //    let composer = HangulComposer()
    //    composer.activate() // 텍스트 입력 시작
    //    composer.process(input: "ㅎ") // 입력 처리
    //    composer.deactivate() // 텍스트 입력 종료
    private var isActive = false
    private var previousText: String = ""
    
    private var CanBeDoubleVowel: Bool? = nil
    private var CanBeDoubleBase: Bool? = nil
    
    func process(input: String) {
        guard isActive else { return } // isActive를 통해 흐름 제어
        
        if cho == nil { // 첫 글자 (이전글자와 연결 마지막에 다시 확인해보기)
            
            if isChosung(input) {
                cho = getChosungIndex(input) // cho에 자음의 인덱스를 할당
                return
            } else { return } // 첫 글자가 모음일 때 process() 종료
            
        } else { // 초성에 할당된 자음이 있을 때
            // 중성 판별
            if jung == nil {
                if isVowel(input) {
                    jung = getJungsungIndex(input)
                    return
                } else { // 자음이 연달아 들어왔을 때
                    cho = getChosungIndex(input) // 이전 자음(초성)을 덮어씀
                    return
                }
            } else if jung != nil && CanBeDoubleBase == true { // 겹모음이 가능할 때 input을 판별하는 단계
                if isVowel(input) {
                    switch jung {
                    case 8:
                        guard input == "ㅣ" || input == "ㅏ" || input == "ㅐ" else { break }
                        
                        // 겹모음이 만들어질 때
                        jung = getJungsungIndex(complexVowels[VowelPair(firstVowel: "ㅗ", secondVowel: input)]!)
                        CanBeDoubleBase = nil
                        return
                    case 13:
                        guard input == "ㅣ" || input == "ㅓ" || input == "ㅔ" else { break }
                        
                        // 겹모음이 만들어질 때
                        jung = getJungsungIndex(complexVowels[VowelPair(firstVowel: "ㅜ", secondVowel: input)]!)
                        CanBeDoubleBase = nil
                        return
                    case 18:
                        guard input == "ㅣ" else { break }
                        
                        // 겹모음이 만들어질 때
                        jung = getJungsungIndex(complexVowels[VowelPair(firstVowel: "ㅡ", secondVowel: "ㅣ")]!)
                        CanBeDoubleBase = nil
                        return
                    default:
                        print("예외 발생 In process()")
                        CanBeDoubleBase = nil
                        return
                    }
                    
                    // 겹모음이 만들어지지 않는 모음이 들어왔을 때 break 후 진입
                    cho = nil
                    jung = nil
                    CanBeDoubleBase = nil
                    return
                    
                } else {
                    // 자음이 들어왔을 때
                    cho = getChosungIndex(input) // 이전 자음(초성)을 덮어씀
                    return
                }
                
            }
        }
    }
    let complexVowels: [VowelPair: String] = [
        VowelPair(firstVowel: "ㅗ", secondVowel: "ㅣ"): "ㅚ",
        VowelPair(firstVowel: "ㅗ", secondVowel: "ㅏ"): "ㅘ",
        VowelPair(firstVowel: "ㅗ", secondVowel: "ㅐ"): "ㅙ",
        VowelPair(firstVowel: "ㅜ", secondVowel: "ㅓ"): "ㅝ",
        VowelPair(firstVowel: "ㅜ", secondVowel: "ㅔ"): "ㅞ",
        VowelPair(firstVowel: "ㅜ", secondVowel: "ㅣ"): "ㅟ",
        VowelPair(firstVowel: "ㅡ", secondVowel: "ㅣ"): "ㅢ",
    ]
    
    func combineVowels(firstVowel: String, secondVowel: String) -> String? {
        if let complexVowel = complexVowels[VowelPair(firstVowel: firstVowel, secondVowel: secondVowel)] {
            return complexVowel
        }
        return nil
    }
    
    private func composeHangul() -> String {
        guard let cho = cho, let jung = jung else { return "" }
        
        let base = 0xAC00
        let code = base + (cho * 21 + jung) * 28 + (jong ?? 0)
        return String(UnicodeScalar(code)!)
    }
    
    // 초성인지 판별하는 함수
    private func isChosung(_ input: String) -> Bool {
        if consonant.contains(input) {
            // input이 자음(단자음 or 쌍자음)일 때
            return true
        } else {
            // input이 모음일 때
            return false
        }
    }
    
    // 모음인지의 여부와 겹모음 가능 여부를 판별하는 함수
    private func isVowel(_ input: String) -> Bool {
        // 모음 판별 로직 구현
        if vowel.contains(input) {
            guard firstVowelArray.contains(input) else {
                // 겹모음이 불가한 모음일 때
                CanBeDoubleVowel = false
                return true
            }
            // 겹모음이 가능할 때
            CanBeDoubleVowel = true
            return true
        } else {
            return false
        }
    }
    
    // 초성 인덱스 가져오는 함수
    private func getChosungIndex(_ input: String) -> Int {
        // 초성 인덱스 반환 로직 구현
        
        // 🚨 임의 변경 금지 🚨
        // 초성 인덱스 계산에 사용되는 배열
        let chosungArray = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ" , "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
        let result = chosungArray.firstIndex(of: input) ?? 99 // 에러처리 할 때 쓸 숫자
        
        return result
    }
    
    // 중성 인덱스 가져오는 함수
    private func getJungsungIndex(_ input: String) -> Int {
        // 중성 인덱스 반환 로직 구현
        
        // 🚨 임의 변경 금지 🚨
        // 중성 인덱스 계산에 사용되는 배열
        let jungsungArray = ["ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ","ㅘ","ㅙ","ㅚ","ㅛ","ㅜ","ㅝ","ㅞ","ㅟ","ㅠ","ㅡ","ㅢ","ㅣ"]
        return 0
    }
    
    func activate() {
        isActive = true
        // 활성화 관련 로직
    }
    
    func deactivate() {
        isActive = false
        // 비활성화 관련 로직
    }
}
