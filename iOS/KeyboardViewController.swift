//
//  KeyboardViewController.swift
//  iOS
//
//  Created by twhiston on 29.03.19.
//  Copyright © 2019 twhiston. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    //@IBOutlet var nextKeyboardButton: UIButton!
    // TODO - textrow buttons are a special case, they could benefit from their own setup function
    var textrow:UIView!
    var lrow1:UIView!
    var lrow2:UIView!
    var lrow3:UIView!
    var lrow3email:UIView!
    var urow1:UIView!
    var urow2:UIView!
    var urow3:UIView!
    var trow4:UIView!
    var nrow1:UIView!
    var nrow2:UIView!
    var nrow3:UIView!
    var n2row1:UIView!
    var n2row2:UIView!
    var n2row3:UIView!
    var ntrow4:UIView!
    var caps:Bool!
    var numMode:Int!
    
    var userLexicon: UILexicon?
    var currentWord: String? {
        var lastWord: String?
        if let stringBeforeCursor = textDocumentProxy.documentContextBeforeInput {
            stringBeforeCursor.enumerateSubstrings(in: stringBeforeCursor.startIndex...,
                                                   options: .byWords)
            { word, _, _, _ in
                if let word = word {
                    lastWord = word
                }
            }
        }
        return lastWord
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    @objc func didTapTextRowButton(sender: AnyObject?) {
        
         let button = sender as! UIButton
         guard let title = button.title(for: []) else { return }
         let proxy = textDocumentProxy as UITextDocumentProxy
        
        let current = currentWord ?? ""
        for _ in 0..<current.count {
            proxy.deleteBackward()
        }
        
        proxy.insertText(title)
        
        //If the next letter is not a defined character add a space
        let followingText = proxy.documentContextAfterInput ?? ""
        let charset = CharacterSet(charactersIn: " .,")
        if followingText.prefix(1).rangeOfCharacter(from: charset) == nil {
            proxy.insertText(" ")
        }
        
        updateTextDisplay()
    }
    
    @objc func didTapButton(sender: AnyObject?) {
        
        let button = sender as! UIButton
        guard var title = button.title(for: []) else { return }
        let proxy = textDocumentProxy as UITextDocumentProxy
        let followingText = proxy.documentContextAfterInput ?? ""
        let previousText = proxy.documentContextBeforeInput ?? ""
        
        //If we have selected text and our input is a bracket button we want to wrap the input in the brackets
        let selectedText = proxy.selectedText
        if (selectedText?.isEmpty != nil) {
            let charset = CharacterSet(charactersIn: "[]{}()<>")
            if title.rangeOfCharacter(from: charset) != nil {
                //If title matches one of the above and there is some selected text then we want to wrap it
                switch title {
                case "(", ")" :
                    title = "("+selectedText!+")"
                case "[", "]":
                    title = "["+selectedText!+"]"
                case "{", "}":
                    title = "{"+selectedText!+"}"
                case "<", ">":
                    title = "<"+selectedText!+">"
                default:
                    break
                }
                
            }
        }
        
        //Now do things based on the input, which may have been updated above due to wrapping
        switch title {
        case "⌫" :
            proxy.deleteBackward()
        case "⇧" :
            caps = !caps
            setKeyboardOnType()
            return
        case "↵" :
            proxy.insertText("\n")
        case "space" :
            //lexicon replacement
            attemptToReplaceCurrentWord()
            // if previous or next char is a space then add a full stop
            if previousText.suffix(1) == " " {
                proxy.deleteBackward()
                proxy.insertText(".")
                if(followingText.prefix(1) != " " && followingText.prefix(1) != "") {
                    proxy.insertText(" ")
                }
            } else if followingText.prefix(1) == " " {
                proxy.insertText(".")
            } else {
                proxy.insertText(" ")
            }
        case "12", "123" :
            numMode = 1
        case "#^" :
            numMode = 2
        case "ABC" :
            numMode = 0
        default :
            proxy.insertText(title)
        }
        updateTextDisplay()
        if numMode == 0 {
            updateCapsIfNeeded()
        }
        //Configures the display rows that are visible
        setKeyboardOnType()
        //Nothing should go after this switch
    }
    
    func updateTextDisplay(){
        
        let inputWord = currentWord ?? ""
        
        //get suggestions
        var replacements = [String](repeating: "", count: 3)
        
        if let beforeContext = textDocumentProxy.documentContextBeforeInput {
            if beforeContext == "" || (self.characterIsWhitespace(beforeContext[beforeContext.index(before: beforeContext.endIndex)])) {
                replaceTextRowTitles(replacements)
                return
            }
        }
        
        let checker = UITextChecker()
        let guesses = checker.guesses(forWordRange: NSRange(0..<inputWord.utf16.count), in: inputWord , language: "en")
        let completions = checker.completions(forPartialWordRange: NSRange(0..<inputWord.utf16.count), in: inputWord, language: "en")
        
        let entries = userLexicon?.entries
        
        //Replacement entries are user lex entries we could offer to expand.
        let replacementEntries = entries?.filter {
            $0.userInput.lowercased() == currentWord?.lowercased()
        }
        
        if replacementEntries?.count ?? 0 > 0 {
            let first = replacementEntries?.first
            replacements[1] = first?.documentText ?? ""
        } else {
            if  0 < guesses?.count ?? 0 {
                replacements[1] = guesses![0]
            } else {
                replacements[1] = inputWord
            }
        }
        
        if  0 < completions?.count ?? 0 {
            replacements[0] = completions![0]
        } else if 1 < guesses?.count ?? 0 {
            replacements[0] = guesses![1]
        }
        
        if  1 < completions?.count ?? 0 {
            replacements[2] = completions![1]
        } else {
            replacements[2] = inputWord
        }
        replaceTextRowTitles(replacements)
    }
    
    func replaceTextRowTitles(_ replacements: [String]){
        for i in 0..<replacements.count {
            let display = textrow.subviews[i] as! UIButton
            display.setTitle(replacements[i], for: [])
        }
    }
    
    func updateCapsIfNeeded() {
        caps = self.shouldAutoCapitalize()
    }
    
    private func setKeyboardOnType(){
        
        let keyboardType = textDocumentProxy.keyboardType

        switch(keyboardType) {
        case .emailAddress:
            setEmailKeys()
        default:
            setLetterKeys()
        }
        
        configureNumpad()
    }
    
    //Don't call this directly, call setKeyboardOnType
    private func configureNumpad(){
        if numMode == 1 {
            hideLetterKeys()
            nrow1.isHidden = false
            nrow2.isHidden = false
            nrow3.isHidden = false
            n2row1.isHidden = true
            n2row2.isHidden = true
            n2row3.isHidden = true
            ntrow4.isHidden = false
        } else if numMode == 2 {
            hideLetterKeys()
            nrow1.isHidden = true
            nrow2.isHidden = true
            nrow3.isHidden = true
            n2row1.isHidden = false
            n2row2.isHidden = false
            n2row3.isHidden = false
            ntrow4.isHidden = false
        } else {
            nrow1.isHidden = true
            nrow2.isHidden = true
            nrow3.isHidden = true
            n2row1.isHidden = true
            n2row2.isHidden = true
            n2row3.isHidden = true
            ntrow4.isHidden = true
        }
    }
    
    //Don't call this directly, call setKeyboardOnType
    private func hideLetterKeys(){
        urow1.isHidden = true
        urow2.isHidden = true
        urow3.isHidden = true
        lrow1.isHidden = true
        lrow2.isHidden = true
        lrow3.isHidden = true
        lrow3email.isHidden = true
        trow4.isHidden = true
    }
    
    //Don't call this directly, call setKeyboardOnType
    private func setLetterKeys(){
        if caps {
            urow1.isHidden = false
            urow2.isHidden = false
            urow3.isHidden = false
            lrow1.isHidden = true
            lrow2.isHidden = true
            lrow3.isHidden = true
            lrow3email.isHidden = true
        } else {
            urow1.isHidden = true
            urow2.isHidden = true
            urow3.isHidden = true
            lrow1.isHidden = false
            lrow2.isHidden = false
            lrow3.isHidden = false
            lrow3email.isHidden = true
        }
        trow4.isHidden = false
    }
    
    //Don't call this directly, call setKeyboardOnType
    private func setEmailKeys(){
        urow1.isHidden = true
        urow2.isHidden = true
        urow3.isHidden = true
        lrow1.isHidden = false
        lrow2.isHidden = false
        lrow3.isHidden = true
        lrow3email.isHidden = false
        trow4.isHidden = false
    }
    
    func createButtonWithTitle(title: String, fontSize: CGFloat) -> UIButton {
        
        let button = UIButton(type: .system) as UIButton
        button.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        button.setTitle(title, for: [])
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
//        button.setTitleColor(UIColor.darkGray, for: [])
        button.backgroundColor = UIColor.darkGray
        button.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: [])
        
        return button
    }
    
    func createRowOfButtons(buttonTitles: [NSString], target: Selector, fontSize: CGFloat ) -> UIView {
    
        var buttons = [UIButton]()
        let keyboardRowView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 414, height: 50)))
    
        for buttonTitle in buttonTitles{
            let button = createButtonWithTitle(title: buttonTitle as String, fontSize: fontSize)
            button.addTarget(self, action: target, for: .touchUpInside)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }
    
        addIndividualButtonConstraints(buttons: buttons, mainView: keyboardRowView)
    
        return keyboardRowView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        caps = true
        numMode = 0
        
        let buttonCaps1 = ["Q", "D", "R", "W", "B", "J", "F", "U", "P", "⇧"]
        let buttonCaps2 = ["A", "S", "H", "T", "G", "Y", "N", "E", "O", "I"]
        let buttonCaps3 = ["Z", "X", "M", "C", "V", "K", "L", ",", ".", "⌫"]
        
        let buttonLower1 = ["q", "d", "r", "w", "b", "j", "f", "u", "p", "⇧"]
        let buttonLower2 = ["a", "s", "h", "t", "g", "y", "n", "e", "o", "i"]
        let buttonLower3 = ["z", "x", "m", "c", "v", "k", "l", ",", ".", "⌫"]
        let buttonLower3email = ["z", "x", "m", "c", "v", "k", "l", "@", ".", "⌫"]
        
        let buttonText4 = ["space", "123", "↵"]
        
        let buttonsNum1 = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        let buttonsNum2 = ["(", "-", "/", ":", ";", "£", "&", "\"", ")"]
        let buttonsNum3 = ["#^", ".", "?", "!", "'", "@", "⌫"]
        let buttons2Num1 = ["[", "{", "#", "%", "^", "*", "+", "=", "}", "]"]
        let buttons2Num2 = ["<", "_", "\\", "|", "~", "$", "€", "`", "'", ">"]
        let buttons2Num3 = ["123", ".", "?", "!", "‘", "@", "⌫"]
        
        let buttonsNum4 = ["space", "ABC", "↵"]
        
        let textDisplay = ["","",""]
        
        lrow1 = createRowOfButtons(buttonTitles: buttonLower1 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        lrow2 = createRowOfButtons(buttonTitles: buttonLower2 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        lrow3 = createRowOfButtons(buttonTitles: buttonLower3 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        lrow3email = createRowOfButtons(buttonTitles: buttonLower3email as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        urow1 = createRowOfButtons(buttonTitles: buttonCaps1 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        urow2 = createRowOfButtons(buttonTitles: buttonCaps2 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        urow3 = createRowOfButtons(buttonTitles: buttonCaps3 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        trow4 = createRowOfButtons(buttonTitles: buttonText4 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
    
        nrow1 = createRowOfButtons(buttonTitles: buttonsNum1 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        nrow2 = createRowOfButtons(buttonTitles: buttonsNum2 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        nrow3 = createRowOfButtons(buttonTitles: buttonsNum3 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        
        n2row1 = createRowOfButtons(buttonTitles: buttons2Num1 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        n2row2 = createRowOfButtons(buttonTitles: buttons2Num2 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        n2row3 = createRowOfButtons(buttonTitles: buttons2Num3 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        
        ntrow4 = createRowOfButtons(buttonTitles: buttonsNum4 as [NSString], target: #selector(self.didTapButton), fontSize: 32)
        
        textrow = createRowOfButtons(buttonTitles: textDisplay as [NSString], target: #selector(self.didTapTextRowButton), fontSize: 24)
        
        self.view.addSubview(textrow)
        self.view.addSubview(lrow1)
        self.view.addSubview(lrow2)
        self.view.addSubview(lrow3)
        self.view.addSubview(lrow3email)
        self.view.addSubview(urow1)
        self.view.addSubview(urow2)
        self.view.addSubview(urow3)
        self.view.addSubview(trow4)
        self.view.addSubview(nrow1)
        self.view.addSubview(nrow2)
        self.view.addSubview(nrow3)
        self.view.addSubview(n2row1)
        self.view.addSubview(n2row2)
        self.view.addSubview(n2row3)
        self.view.addSubview(ntrow4)
        
        textrow.translatesAutoresizingMaskIntoConstraints = false
        lrow1.translatesAutoresizingMaskIntoConstraints = false
        lrow2.translatesAutoresizingMaskIntoConstraints = false
        lrow3.translatesAutoresizingMaskIntoConstraints = false
        lrow3email.translatesAutoresizingMaskIntoConstraints = false
        trow4.translatesAutoresizingMaskIntoConstraints = false
        urow1.translatesAutoresizingMaskIntoConstraints = false
        urow2.translatesAutoresizingMaskIntoConstraints = false
        urow3.translatesAutoresizingMaskIntoConstraints = false
        nrow1.translatesAutoresizingMaskIntoConstraints = false
        nrow2.translatesAutoresizingMaskIntoConstraints = false
        nrow3.translatesAutoresizingMaskIntoConstraints = false
        n2row1.translatesAutoresizingMaskIntoConstraints = false
        n2row2.translatesAutoresizingMaskIntoConstraints = false
        n2row3.translatesAutoresizingMaskIntoConstraints = false
        ntrow4.translatesAutoresizingMaskIntoConstraints = false
        
        
        addConstraintsToInputView(inputView: self.view, rowViews: [textrow, nrow1, nrow2, nrow3, ntrow4])
        addConstraintsToInputView(inputView: self.view, rowViews: [textrow, n2row1, n2row2, n2row3, ntrow4])
        addConstraintsToInputView(inputView: self.view, rowViews: [textrow, lrow1, lrow2, lrow3, trow4])
        addConstraintsToInputView(inputView: self.view, rowViews: [textrow, lrow1, lrow2, lrow3email, trow4])
        addConstraintsToInputView(inputView: self.view, rowViews: [textrow, urow1, urow2, urow3, trow4])
        
        requestSupplementaryLexicon { lexicon in
            self.userLexicon = lexicon
        }
        setKeyboardOnType()
        updateCapsIfNeeded()
        
    }
    
    func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        
        for (index, rowView) in rowViews.enumerated() {
            let rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .right, relatedBy: .equal, toItem: inputView, attribute: .right, multiplier: 1.0, constant: -1)
            
            let leftConstraint = NSLayoutConstraint(item: rowView, attribute: .left, relatedBy: .equal, toItem: inputView, attribute: .left, multiplier: 1.0, constant: 1)
            
            inputView.addConstraints([leftConstraint, rightSideConstraint])
            
            var topConstraint: NSLayoutConstraint
            
            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: inputView, attribute: .top, multiplier: 1.0, constant: 0)
                
            }else{
                
                let prevRow = rowViews[index-1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: prevRow, attribute: .bottom, multiplier: 1.0, constant: 0)
                
                let firstRow = rowViews[0]
                let heightConstraint = NSLayoutConstraint(item: firstRow, attribute: .height, relatedBy: .equal, toItem: rowView, attribute: .height, multiplier: 1.0, constant: 0)
                
                inputView.addConstraint(heightConstraint)
            }
            inputView.addConstraint(topConstraint)
            
            var bottomConstraint: NSLayoutConstraint
            
            if index == rowViews.count - 1 {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .bottom, relatedBy: .equal, toItem: inputView, attribute: .bottom, multiplier: 1.0, constant: 0)
                
            }else{
                
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .bottom, relatedBy: .equal, toItem: nextRow, attribute: .top, multiplier: 1.0, constant: 0)
            }
            
            inputView.addConstraint(bottomConstraint)
        }
        
    }
    
    func addIndividualButtonConstraints(buttons: [UIButton], mainView: UIView){
        
        for (index, button) in buttons.enumerated() {
            
            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 1.0, constant: 1)
            
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1.0, constant: -1)
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == buttons.count - 1 {
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: mainView, attribute: .right, multiplier: 1.0, constant: -1)
                
            }else{
                
                let nextButton = buttons[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: nextButton, attribute: .left, multiplier: 1.0, constant: -1)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            
            if index == 0 {
                
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: mainView, attribute: .left, multiplier: 1.0, constant: 1)
                
            }else{
                
                let prevtButton = buttons[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: prevtButton, attribute: .right, multiplier: 1.0, constant: 1)
                
                let firstButton = buttons[0]
                let widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .width, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1.0, constant: 0)
                
                mainView.addConstraint(widthConstraint)
            }
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        let desiredHeight:CGFloat!
//        if UIDevice.current.userInterfaceIdiom == .phone{
//            desiredHeight = 259
//        }else{
//            if UIDevice.current.orientation == .portrait{
//                desiredHeight = 260
//            }else {
//                desiredHeight = 300
//            }
//        }
//        desiredHeight = 270
//        let heightConstraint = NSLayoutConstraint(item: view as Any, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: desiredHeight)
//        view.addConstraint(heightConstraint)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
        // Also hit when a cursor moves
        setKeyboardOnType()
        updateTextDisplay()
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        updateTextDisplay()
    }
    
    
//    func darkMode() -> Bool {
//        let darkMode = { () -> Bool in
//            let proxy = self.textDocumentProxy
//            return proxy.keyboardAppearance == UIKeyboardAppearance.dark
//        }()
//
//        return darkMode
//    }
    
    func shouldAutoCapitalize() -> Bool {
        
        let traits = self.textDocumentProxy
        if let autocapitalization = traits.autocapitalizationType {
            let documentProxy = self.textDocumentProxy
            //var beforeContext = documentProxy.documentContextBeforeInput
            
            if documentProxy.documentContextBeforeInput?.count == 0 || (documentProxy.documentContextBeforeInput == nil){
                return true
            }
            
            switch autocapitalization {
            case .none:
                return false
            case .words:
                if let beforeContext = documentProxy.documentContextBeforeInput {
                    let previousCharacter = beforeContext[beforeContext.index(before: beforeContext.endIndex)]
                    return self.characterIsWhitespace(previousCharacter)
                }
                else {
                    return true
                }
                
            case .sentences:
                if let beforeContext = documentProxy.documentContextBeforeInput {
                    let offset = min(3, beforeContext.count)
                    var index = beforeContext.endIndex
                    
                    for i in 0 ..< offset {
                        index = beforeContext.index(before: index)
                        let char = beforeContext[index]
                        
                        if characterIsPunctuation(char) {
                            if i == 0 {
                                return false //not enough spaces after punctuation
                            }
                            else {
                                return true //punctuation with at least one space after it
                            }
                        }
                        else {
                            if !characterIsWhitespace(char) {
                                return false //hit a foreign character before getting to 3 spaces
                            }
                            else if characterIsNewline(char) {
                                return true //hit start of line
                            }
                        }
                    }
                    
                    return true //either got 3 spaces or hit start of line
                }
                else {
                    return true
                }
            case .allCharacters:
                return true
            @unknown default:
                return false
                //fatalError
            }
        }
        return false
    }
    
    func characterIsPunctuation(_ character: Character) -> Bool {
        return (character == ".") || (character == "!") || (character == "?")
    }
    
    func characterIsNewline(_ character: Character) -> Bool {
        return (character == "\n") || (character == "\r")
    }
    
    func characterIsWhitespace(_ character: Character) -> Bool {
        // there are others, but who cares
        return (character == " ") || (character == "\n") || (character == "\r") || (character == "\t")
    }

}

// MARK: - Private methods
private extension KeyboardViewController {
    // This looks in the uxer lexicon for something that matches the current input and replaces it
    // useful for custom autocorrects or text expansion eg. omw -> on my way!
    // TODO - for corrections and not expansions we also need a way to show suggestions from the lexicon
    func attemptToReplaceCurrentWord() {
        guard let entries = userLexicon?.entries,
            let currentWord = currentWord?.lowercased() else {
                return
        }
        
        let replacementEntries = entries.filter {
            $0.userInput.lowercased() == currentWord
        }
        
        if let replacement = replacementEntries.first {
            if replacement.documentText == currentWord.uppercased(){
                return
            }
            for _ in 0..<currentWord.count {
                textDocumentProxy.deleteBackward()
            }
            
            textDocumentProxy.insertText(replacement.documentText)
        }
    }
}
