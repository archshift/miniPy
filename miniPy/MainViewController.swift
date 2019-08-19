//
//  LaunchScreenViewController.swift
//  miniPy
//
//  Created by Gui Andrade on 6/15/19.
//  Copyright © 2019 Gui Andrade. All rights reserved.
//

import Foundation
import UIKit


var runView: RunViewController?

class MainViewController : UIViewController, UITextViewDelegate {
    
    private var textView: UITextView?
    private var swipeFromRight: UIScreenEdgePanGestureRecognizer?
    
    let bgColor = UIColor(white: 0.2, alpha: 1)
    let textColor = UIColor(white: 0.8, alpha: 1)
    
    let tabSize = 4
    var defaultCode =
    """
    import math

    def sqrt2():
        return math.sqrt(2)

    print("The square root of 2 is", sqrt2())
    """

    var keyboardHeight: CGFloat = 0.0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func onSwipeFromRight(_ sender: UIScreenEdgePanGestureRecognizer) {
        switch sender.state {
        case .began:
            let text = self.textView?.text
            PythonSingleton.waitForFinish()
            runView = RunViewController()
            
            PythonSingleton.stdoutWriter = {buf in
                let newString = String.init(bytes: buf, encoding: .utf8)
                DispatchQueue.main.async {
                    runView?.textView?.text.append(newString ?? "<non-text data>")
                }
            }
            runView?.pyHandle = PythonSingleton.asyncRunInstance(code: text ?? "")
            
            appDelegate.nav?.pushViewController(runView!, animated: true)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = bgColor
        setNeedsStatusBarAppearanceUpdate()
        
        let textView = UITextView()
        view.addSubview(textView)
        self.textView = textView
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            textView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            textView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: statusBarHeight + 10),
            textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -keyboardHeight - 10),
            ])
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.smartInsertDeleteType = .no
        textView.backgroundColor = .init(white: 0, alpha: 0)
        textView.textColor = textColor
        textView.tintColor = .systemPink
        textView.font = UIFont(name: "Menlo", size: 13)
        
        textView.text = defaultCode
        textView.delegate = self
        textView.becomeFirstResponder()
        
        let swipeFromRight = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.onSwipeFromRight))
        swipeFromRight.edges = .right
        view.addGestureRecognizer(swipeFromRight)
    }
    
    // Tuple of (str insert pos, string, new cursor pos)
    var newChars: (Int, String, Int)?
    
    func updateCursorPos(_ textView: UITextView, pos: Int) {
        if let newPosition = textView.position(from: textView.beginningOfDocument, offset: pos) {
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = NSMutableString(string: textView.text)
        if let (at, string, cursor) = newChars {
            newChars = nil
            text.insert(string, at: at)
            textView.text = text as String
            updateCursorPos(textView, pos: cursor)
        }
    }
    
    func textView(_ textField: UITextView, shouldChangeTextIn range: NSRange,  replacementText string: String) -> Bool {
        if string.count > 1 {
            return true
        }
        // Do code formatting stuff now that we're pretty sure it's not pasted code
        
        let text = NSMutableString(string: textField.text)
        let insertEnd = range.lowerBound + string.lengthOfBytes(using: .utf8)
        
        let lineRange = text.lineRange(for: range)
        let line = text.substring(with: lineRange)
        
        if string == "\n" {
            var lineWhitespace = 0
            for char in line {
                if char != " " && char != "\t" {
                    break
                }
                lineWhitespace += 1
            }
            
            // Indent by previous line
            var string = String([Character].init(repeating: " ", count: lineWhitespace))
            
            let prevIndex = range.lowerBound
            if text.substring(to: prevIndex).last == ":" {
                // Add additional indent for colon
                string += [Character].init(repeating: " ", count: tabSize)
            }
            newChars = (insertEnd, string, insertEnd + string.count)
        }
        
        if string == "\"" {
            newChars = (insertEnd, "\"", insertEnd)
        }

        return true
    }
}
