//
//  DismissKeyboard.swift
//  QR Attendance
//
//  Created by Ram Sri Charan on 4/20/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import Foundation
import UIKit



extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController {
    // Helper method to show alert messages
    func showAlert(AlertTitle: String, Message : String){
        let alert = UIAlertController(title: AlertTitle, message: Message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}


extension UIViewController {
    
    // Downloading Image from web

    func downloadImageIntoView(imagePath : String, imageView : UIImageView){
        
        let poster_url = URL(string : imagePath)

        if !imagePath.isEmpty {
        DispatchQueue.global().async {
                let data = try? Data(contentsOf: poster_url!)
                DispatchQueue.main.async {
                    if(data == nil)
                    {
                        imageView.image = #imageLiteral(resourceName: "blank_image")
                    }
                    else{
                        imageView.image = UIImage(data: data!) ?? #imageLiteral(resourceName: "blank_image")
                    }
                }
            }
        }
    }
    
    
}








// Basic Model object
extension UIViewController {
    
    struct BasicDetails {
        let UserName : String?
        let UserID : String?
        let UserType : String?
        
        var ClassID : String?
        var ClassName : String?
        var PosterURL : String?
    }

}





// Move TextField Up to avoid keyboard
extension UIViewController{
    
    func avoidKeyboardObstruction(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y = -100 // Move view 100 points upward
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
}








