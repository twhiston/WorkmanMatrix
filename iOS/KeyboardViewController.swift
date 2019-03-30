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
    
    var lrow1:UIView!
    var lrow2:UIView!
    var lrow3:UIView!
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
    var caps:Bool!
    var numMode:Int!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
    }
    
    func createButtonWithTitle(title: String) -> UIButton {
    
        let button = UIButton(type: .system) as UIButton
        button.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        button.setTitle(title, for: [])
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGray, for: [])
    
        button.addTarget(self, action: #selector(self.didTapButton), for: .touchUpInside)
    
    return button
    }
    
    @objc func didTapButton(sender: AnyObject?) {
        
        let button = sender as! UIButton
        guard let title = button.title(for: []) else { return }
        let proxy = textDocumentProxy as UITextDocumentProxy
        
        switch title {
        case "⌫" :
            proxy.deleteBackward()
        case "⇧" :
            caps = !caps
            setLetterKeys()
            return
        case "↵" :
            proxy.insertText("\n")
        case "space" :
            proxy.insertText(" ")
        case "12", "123" :
            numMode = 1
            configureNumpad()
        case "#^" :
            numMode = 2
            configureNumpad()
        case ".." :
            numMode = 0
            configureNumpad()
        //case "⇧" :
        default :
            proxy.insertText(title)
        }
        if numMode == 0 {
            updateCapsIfNeeded()
        }
        //Nothing should go after this switch
    
        
    }
    
    func updateCapsIfNeeded() {
        caps = self.shouldAutoCapitalize()
        setLetterKeys()
    }
    
    func configureNumpad(){
        if numMode == 1 {
            hideLetterKeys()
            nrow1.isHidden = false
            nrow2.isHidden = false
            nrow3.isHidden = false
            n2row1.isHidden = true
            n2row2.isHidden = true
            n2row3.isHidden = true
        } else if numMode == 2 {
            hideLetterKeys()
            nrow1.isHidden = true
            nrow2.isHidden = true
            nrow3.isHidden = true
            n2row1.isHidden = false
            n2row2.isHidden = false
            n2row3.isHidden = false
        } else {
            nrow1.isHidden = true
            nrow2.isHidden = true
            nrow3.isHidden = true
            n2row1.isHidden = true
            n2row2.isHidden = true
            n2row3.isHidden = true
        }
    }
    
    func hideLetterKeys(){
        urow1.isHidden = true
        urow2.isHidden = true
        urow3.isHidden = true
        lrow1.isHidden = true
        lrow2.isHidden = true
        lrow3.isHidden = true
        trow4.isHidden = true
    }
    
    func setLetterKeys(){
        if caps {
            urow1.isHidden = false
            urow2.isHidden = false
            urow3.isHidden = false
            lrow1.isHidden = true
            lrow2.isHidden = true
            lrow3.isHidden = true
        } else {
            urow1.isHidden = true
            urow2.isHidden = true
            urow3.isHidden = true
            lrow1.isHidden = false
            lrow2.isHidden = false
            lrow3.isHidden = false
        }
        trow4.isHidden = false
    }
    
    func createRowOfButtons(buttonTitles: [NSString]) -> UIView {
    
        var buttons = [UIButton]()
        let keyboardRowView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 414, height: 50)))
    
        for buttonTitle in buttonTitles{
    
            let button = createButtonWithTitle(title: buttonTitle as String)
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
        let buttonCaps3 = ["Z", "X", "M", "C", "V", "K", "L", ".", "@", "⌫"]
        
        let buttonLower1 = ["q", "d", "r", "w", "b", "j", "f", "u", "p", "⇧"]
        let buttonLower2 = ["a", "s", "h", "t", "g", "y", "n", "e", "o", "i"]
        let buttonLower3 = ["z", "x", "m", "c", "v", "k", "l", ",", ".", "⌫"]
        
        let buttonText4 = ["space", "123", "↵"]
        
        let buttonsNum1 = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        let buttonsNum2 = ["-", "/", ":", ";", "(", ")", "£", "&", "@", "\""]
        let buttonsNum3 = ["..", "#^", ".", "?", "!", "‘", "⌫", "↵"]
        let buttons2Num1 = ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="]
        let buttons2Num2 = ["_", "\\", "|", "~", "<", ">", "$", "€", "`", "'"]
        let buttons2Num3 = ["..", "12", ".", "?", "!", "‘", "⌫", "↵"]
        
        lrow1 = createRowOfButtons(buttonTitles: buttonLower1 as [NSString])
        lrow2 = createRowOfButtons(buttonTitles: buttonLower2 as [NSString])
        lrow3 = createRowOfButtons(buttonTitles: buttonLower3 as [NSString])
        urow1 = createRowOfButtons(buttonTitles: buttonCaps1 as [NSString])
        urow2 = createRowOfButtons(buttonTitles: buttonCaps2 as [NSString])
        urow3 = createRowOfButtons(buttonTitles: buttonCaps3 as [NSString])
        trow4 = createRowOfButtons(buttonTitles: buttonText4 as [NSString])
    
        nrow1 = createRowOfButtons(buttonTitles: buttonsNum1 as [NSString])
        nrow2 = createRowOfButtons(buttonTitles: buttonsNum2 as [NSString])
        nrow3 = createRowOfButtons(buttonTitles: buttonsNum3 as [NSString])
        
        n2row1 = createRowOfButtons(buttonTitles: buttons2Num1 as [NSString])
        n2row2 = createRowOfButtons(buttonTitles: buttons2Num2 as [NSString])
        n2row3 = createRowOfButtons(buttonTitles: buttons2Num3 as [NSString])
        
        
        self.view.addSubview(lrow1)
        self.view.addSubview(lrow2)
        self.view.addSubview(lrow3)
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
        
        lrow1.translatesAutoresizingMaskIntoConstraints = false
        lrow2.translatesAutoresizingMaskIntoConstraints = false
        lrow3.translatesAutoresizingMaskIntoConstraints = false
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
        
        addConstraintsToInputView(inputView: self.view, rowViews: [nrow1, nrow2, nrow3])
        addConstraintsToInputView(inputView: self.view, rowViews: [n2row1, n2row2, n2row3])
        addConstraintsToInputView(inputView: self.view, rowViews: [lrow1, lrow2, lrow3, trow4])
        addConstraintsToInputView(inputView: self.view, rowViews: [urow1, urow2, urow3, trow4])
        
        configureNumpad()
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
    
    override func viewWillLayoutSubviews() {
        //self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        let proxy = self.textDocumentProxy
    
        
        var textColor: UIColor
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        //self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    func darkMode() -> Bool {
        let darkMode = { () -> Bool in
            let proxy = self.textDocumentProxy
            return proxy.keyboardAppearance == UIKeyboardAppearance.dark
        }()
        
        return darkMode
    }
    
    func shouldAutoCapitalize() -> Bool {
//        if !UserDefaults.standard.bool(forKey: kAutoCapitalization) {
//            return false
//        }
        
        let traits = self.textDocumentProxy
        if let autocapitalization = traits.autocapitalizationType {
            let documentProxy = self.textDocumentProxy
            //var beforeContext = documentProxy.documentContextBeforeInput
            
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
