//
//  MiscExtensions.swift
//  QR Attendance
//
//  Created by Ram Sri Charan on 4/25/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import Foundation
import UIKit

extension String {
    // Get the string before a character
    func getStringBeforeCharacter(lastCharacter : String) -> String {
        var result = ""
        let OriginalString = self
        if let range = OriginalString.range(of: lastCharacter) {
            result =  String(OriginalString[(OriginalString.startIndex)..<range.lowerBound])
        }
        return result
    }
}


// Date related extensions
extension Date
{
    func toMyString() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MMM/dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}


extension String
{
    func toMyDate() -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MMM/dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        return dateFormatter.date(from: self)!
    }
    
    
    func toMyDateString() -> String
    {
        
        let day = self.toMyDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: day)
    }
    
    
    // Check for invalid character in the QRCode
    func hasInvalidCharacters() -> Bool{
        let invalidChars: Set<Character> = [".", "#", "$", "[", "]" ]
        let hasInvalidChars = invalidChars.isDisjoint(with: self)
        if !hasInvalidChars {
            // Has invalid characters
            return true
        }
        else{
            return false
        }
    }
    
}




// My Custom Button Views
extension UIButton {
    func getMyButtonView() -> UIView {
        
        let buttonBaseView : UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        buttonBaseView.addSubview(self)
        buttonBaseView.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        self.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.widthAnchor.constraint(equalTo: buttonBaseView.widthAnchor, multiplier: 0.6).isActive = true
        self.centerXAnchor.constraint(equalTo: buttonBaseView.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: buttonBaseView.centerYAnchor).isActive = true
        
        
        return buttonBaseView
    }
}


extension UIView {
    
    func makeBlankSpace() -> UIView {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }
    
    
    // Fade animation
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        layer.add(animation, forKey: kCATransitionFade)
    }
    
    
}












// To hide bottom line
extension UINavigationBar {
    func hideBottomHairline() {
        self.hairlineImageView?.isHidden = true
    }
    
    func showBottomHairline() {
        self.hairlineImageView?.isHidden = false
    }
}

extension UIToolbar {
    func hideBottomHairline() {
        self.hairlineImageView?.isHidden = true
    }
    
    func showBottomHairline() {
        self.hairlineImageView?.isHidden = false
    }
}



extension UIView {
    fileprivate var hairlineImageView: UIImageView? {
        return hairlineImageView(in: self)
    }
    
    fileprivate func hairlineImageView(in view: UIView) -> UIImageView? {
        if let imageView = view as? UIImageView, imageView.bounds.height <= 1.0 {
            return imageView
        }
        
        for subview in view.subviews {
            if let imageView = self.hairlineImageView(in: subview) { return imageView }
        }
        
        return nil
    }
}






