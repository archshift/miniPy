//
//  RunViewController.swift
//  miniPy
//
//  Created by Gui Andrade on 6/15/19.
//  Copyright © 2019 Gui Andrade. All rights reserved.
//

import Foundation
import UIKit

class RunViewController : UIViewController {
    var label: UILabel?
    var textView: UITextView?

    let bgColor = UIColor.init(white: 0.1, alpha: 1)
    let textColor = UIColor.init(white: 0.9, alpha: 1)
    let borderColor = UIColor.systemPink
    let textPadding: CGFloat = 7
    let fontFace = "Menlo"
    
    var pyHandle: Int64 = 0
    
    var statusBarHeight: CGFloat {
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return min(statusBarSize.width, statusBarSize.height)
    }
    var keyboardHeight: CGFloat = 0.0
    
    var swipeFromLeft: UIScreenEdgePanGestureRecognizer?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func onSwipeFromLeft(_ sender: UIScreenEdgePanGestureRecognizer) {
        switch sender.state {
        case .began:
            PythonSingleton.asyncRequestStop(pyHandle: pyHandle)
            appDelegate.nav?.popViewController(animated: true)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = bgColor
        setNeedsStatusBarAppearanceUpdate()
        
        let label = UILabel()
        view.addSubview(label)
        self.label = label
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: self.view.topAnchor, constant: statusBarHeight + 10),
            ])
        
        label.text = "stdout"
        label.font = UIFont(name: fontFace, size: 13)
        label.textColor = borderColor
        
        let textView = UITextView()
        view.addSubview(textView)
        self.textView = textView
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            textView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            textView.topAnchor.constraint(equalTo: label.bottomAnchor),
            textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
            ])
        textView.backgroundColor = .init(white: 0, alpha: 0)
        textView.textColor = textColor
        textView.layer.borderWidth = 1
        textView.layer.borderColor = borderColor.cgColor
        textView.textContainerInset = .init(top: textPadding, left: textPadding, bottom: textPadding, right: textPadding)
        textView.font = UIFont(name: fontFace, size: 13)
        textView.isEditable = false
        
        textView.becomeFirstResponder()
        
        let swipeFromLeft = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.onSwipeFromLeft))
        swipeFromLeft.edges = .left
        view.addGestureRecognizer(swipeFromLeft)
    }
}
