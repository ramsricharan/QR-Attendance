//
//  BaseTabBarViewController.swift
//  QR Attendance
//
//  Created by Ram Sri Charan on 4/22/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit

class BaseTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    
    var CurrentDetails : UIViewController.BasicDetails?
    
    // Tutor Tabs
    let classHomeViewController : TutorClassHomeViewController = TutorClassHomeViewController()
    let QRCodeViewController : TutorQRCodeViewController = TutorQRCodeViewController()
    let MyStudentViewController : TutorMyStudentsViewController = TutorMyStudentsViewController()
    let ProfileViewController : MyProfileViewController = MyProfileViewController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        self.delegate = self

        tabBar.tintColor = UIColor.green
        tabBar.barTintColor = UIColor.darkText
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        if CurrentDetails?.UserType == "tutors"{
            initiateTutorTabs()
        }
        
        else if CurrentDetails?.UserType == "students"{
            initiateStudentTabs()
        }
    }
    
    ////////////////////////  Tab bar controller Methods ////////////////////////////

    // Responsible for animations
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let fromView: UIView = tabBarController.selectedViewController!.view
        let toView: UIView = viewController.view
        
        if fromView == toView {
            return false
        }
        
        if let tappedIndex = tabBarController.viewControllers?.index(of: viewController) {
            if tappedIndex > tabBarController.selectedIndex {
                UIView.transition(from: fromView, to: toView, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromLeft, completion: nil)
            } else {
                UIView.transition(from: fromView, to: toView, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromRight, completion: nil)
            }
        }
        return true
    }
    
    
    
    
    
    
    ////////////////////////  Helper Methods ////////////////////////////
    
    func initiateTutorTabs(){
        // Class Home viewController
        classHomeViewController.CurrentDetails = CurrentDetails
        let classHomeTab = UINavigationController(rootViewController: classHomeViewController)
        classHomeTab.tabBarItem.title = "Home"
        classHomeTab.tabBarItem.image = #imageLiteral(resourceName: "home_icon")
        
        
        // QR Code viewController
        QRCodeViewController.CurrentDetails = CurrentDetails
        let qrCodeTab = UINavigationController(rootViewController: QRCodeViewController)
        qrCodeTab.tabBarItem.title = "Generate QR"
        qrCodeTab.tabBarItem.image = #imageLiteral(resourceName: "generateQR_icon")
        
        
        
        // My Students viewController
        MyStudentViewController.CurrentDetails = CurrentDetails
        let myStudentTab = UINavigationController(rootViewController: MyStudentViewController)
        myStudentTab.tabBarItem.title = "My Students"
        myStudentTab.tabBarItem.image = #imageLiteral(resourceName: "users_icon")
        
        
        
        // My profile viewController
        ProfileViewController.CurrentDetails = CurrentDetails
        let profileTab = UINavigationController(rootViewController: ProfileViewController)
        profileTab.tabBarItem.title = "My Profile"
        profileTab.tabBarItem.image = #imageLiteral(resourceName: "profile_icon")
        
        
        viewControllers = [classHomeTab, qrCodeTab, myStudentTab, profileTab]
    }
    
    
    func initiateStudentTabs(){
        
        // QR Code Scanner tab
        let qrScannerViewController : StudentQRScannerViewController = StudentQRScannerViewController()
        qrScannerViewController.CurrentDetails = CurrentDetails
        let qrScannerTab = UINavigationController(rootViewController: qrScannerViewController)
        qrScannerTab.tabBarItem.title = "Scan QR"
        qrScannerTab.tabBarItem.image = #imageLiteral(resourceName: "scanQR_icon")
        
        
        
        // My Attendance tab
        let myAttendanceViewController : StudentMyAttendanceViewController = StudentMyAttendanceViewController()
        myAttendanceViewController.CurrentDetails = CurrentDetails
        myAttendanceViewController.ViewTitle = "My Attendance"
        
        let myAttendanceTab = UINavigationController(rootViewController: myAttendanceViewController)
        myAttendanceTab.tabBarItem.title = "My Attendance"
        myAttendanceTab.tabBarItem.image = #imageLiteral(resourceName: "attendance_icon")
        
        
        
        // My profile viewController
        ProfileViewController.CurrentDetails = CurrentDetails
        let profileTab = UINavigationController(rootViewController: ProfileViewController)
        profileTab.tabBarItem.title = "My Profile"
        profileTab.tabBarItem.image = #imageLiteral(resourceName: "profile_icon")
        
        
         viewControllers = [myAttendanceTab, qrScannerTab, profileTab]
    }
    

}
