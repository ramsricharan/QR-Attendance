//
//  ViewController.swift
//  QR Attendance
//
//  Created by Ram Sri Charan on 4/20/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    
    // My variables
    var isTutorSelected = true
    var isStudentSelected = false
    
    var window: UIWindow?

    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        setupViews()
        setUserTypeButtons()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
    }
    

    
    // Setting the status bar text color to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }


    
    
    
    
    func setUserTypeButtons(){
        
        var colorOne, colorTwo : UIColor?
        
        if isTutorSelected{
            // Tutor is selected
            colorOne = UIColor.blue
            colorTwo = UIColor.white
        }
            
        else{
            // Student is selected
            colorOne = UIColor.white
            colorTwo = UIColor.blue
        }
        
        userTypeTutorButton.backgroundColor = colorOne
        userTypeTutorButton.setTitleColor(colorTwo, for: .normal)
        
        userTypeStudentButton.backgroundColor = colorTwo
        userTypeStudentButton.setTitleColor(colorOne, for: .normal)
        
    }
    
    
    
    // Todo if successfully logged in
    func goToNextPage(){
        // Dismiss current page
//        self.dismiss(animated: false, completion: nil)
        
        // Reload the master details page
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let layout = UICollectionViewFlowLayout()
        let customCollectionView = MyClassesTableViewController(collectionViewLayout: layout)
        window?.rootViewController = UINavigationController(rootViewController: customCollectionView)

//        window?.rootViewController = UINavigationController(rootViewController: MyClassesTableViewController())
//        window?.rootViewController = MyClassesTableViewController()
        
    }
    
    // Checking for errors in user input..
    func checkUserInput() -> Bool{
        let username = usernameText.text!
        let password = passwordText.text!
        var isError = true
        var errorMessage = ""
        
        // Check if user inputs are null
        if username.isEmpty || password.isEmpty {
            isError = true
            errorMessage = "Username and Password cannot be empty"
            
            print("username or password is empty")
        }
            // Check if username is valid
        else if !username.contains("@qr.com"){
            isError = true
            errorMessage = "Username must be a valid email ID. Make sure it contains @qr.com suffix"
        }
            
            // If no errors
        else{
            isError = false
            print("No error..")
        }
        
        // If there are errors
        if(isError){
            self.showAlert(AlertTitle: "Input Error", Message: errorMessage)
        }
        
        return isError
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // Action Handles
    
    
    
    @objc func studentTapped(){
        isStudentSelected = true
        isTutorSelected = false
        setUserTypeButtons()
    }
    
    @objc func tutorTapped(){
        isStudentSelected = false
        isTutorSelected = true
        setUserTypeButtons()
    }
    
    
    
    @objc func handleRegister(){
        print("Register pressed")
        let registrationPage = RegistrationViewController()
        present(registrationPage, animated : true, completion : nil)
    }
    
    
    
    
    @objc override func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y = -60 // Move view 60 points upward
    }
    
    @objc override func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    
    @objc func handleLogin(){
        print("Login pressed")
        let loadingScreen = UIViewController.displaySpinner(onView: self.view, Message: "Loggin in")
        
        // Check for errors..
        if(!checkUserInput()){
            // Try to authenticate
            let email = usernameText.text!
            let password = passwordText.text!
            
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                
                if(error != nil){
                    print(error ?? "error")
                    let errorMessage = error?.localizedDescription ?? "Seomething went wrong. Please try again."
                    self.showAlert(AlertTitle: "Failed to login", Message: errorMessage)
                    UIViewController.removeSpinner(spinner: loadingScreen)
                    
                    return
                }
                else{
                    // User exists in database
                    let uid = user?.uid
                    let userType = self.getUserType()
                    
                    let ref : DatabaseReference = Database.database().reference().child(userType)
                    ref.observeSingleEvent(of: .value, with: { (snapshot)
                        in
                        
                        let userVerified =  snapshot.hasChild(uid!)
                        
                        if userVerified{
                            // UserType matches
                            UIViewController.removeSpinner(spinner: loadingScreen)
                            self.goToNextPage()
                        }
                            
                        else{
                            // UserType does not match
                            do{
                                try Auth.auth().signOut()
                            } catch let error{
                                print(error)
                            }

                            UIViewController.removeSpinner(spinner: loadingScreen)
                            self.showAlert(AlertTitle: "Failed to login", Message: "You do not have access to the '\(userType)' account")
                        }
                    }) 
                }
            }
        }
            
        else{
            UIViewController.removeSpinner(spinner: loadingScreen)
        }
        
    }
    
    
    func getUserType() -> String {
        var userType = ""
        
        if isTutorSelected{
            userType = "tutors"
        }
        else if isStudentSelected{
            userType = "students"
        }
        
        
        return userType
    }
    
    
    
    
    
    
    
    
    
    
    
    // Views and their constraints
    
    // Background imageView
    let background : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.image = #imageLiteral(resourceName: "login_background")
        return image
    }()
    
    
    // ScrollView
    let scrollView : UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let baseStackView : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    
    // Imageview for logo
    lazy var appLogo : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = #imageLiteral(resourceName: "aoo_Logo")
        
        view.contentMode = .scaleAspectFill
        view.alpha = 0.8

        return view
    }()
    

    
    // Base container UIView
    var baseView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.8
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    
    // StackView to arrange all views in order
    var myStackView : UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        v.spacing = 10
        return v
    }()
    
    var usernameText : UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Username"
        view.adjustsFontSizeToFitWidth = true
        view.keyboardType = UIKeyboardType.emailAddress

        return view
    }()
    
    let usernameDivider : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var passwordText : UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Password"
        view.adjustsFontSizeToFitWidth = true
        view.isSecureTextEntry = true
        return view
    }()
    
    
    let passwordDivider : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let userTypeLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Who are you?"
        return label
    }()
    
    
    // Student and tutor selector
    let userTypeSelectorView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.layer.borderWidth = CGFloat(1.0)
        view.layer.borderColor = UIColor.blue.cgColor
        return view
    }()
    
    var userTypeStackView : UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.distribution = .fillEqually
        v.axis = .horizontal
        v.spacing = 0
        return v
    }()
    
    let userTypeStudentButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Student", for: UIControlState.normal)
        button.addTarget(self, action: #selector(studentTapped), for: .touchUpInside)
        button.backgroundColor = UIColor.blue
        return button
    }()
    
    let userTypeTutorButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tutor", for: UIControlState.normal)
        button.addTarget(self, action: #selector(tutorTapped), for: .touchUpInside)
        button.backgroundColor = UIColor.green
        return button
    }()
    
    
    // Login button
    let loginButton : UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.setTitle("Login", for: UIControlState.normal)
        view.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.setTitleColor(UIColor.white, for: .normal)
        view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
        
        
        return view
    }()
    
    
    
    // Label for New user
    let newUserPrompt : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.text = "New user? then create your new account"
        view.numberOfLines = 0
        view.textColor = UIColor.white
        return view
    }()
    
    // Register button
    let registerButton : UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Register", for: .normal)
        view.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        view.setTitleColor(UIColor.green, for: .normal)
        return view
    }()
    


    
    
    func setupViews(){
        // Adding the background image
        view.addSubview(background)
        background.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        background.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        background.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        background.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        background.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        

        // Adding the base ScrollView
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // Add BaseStackView
        scrollView.addSubview(baseStackView)
        baseStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8).isActive = true
        baseStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8).isActive = true
        baseStackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 8).isActive = true
        baseStackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -8).isActive = true

        
        
        let blankSpace : UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        
        baseStackView.addArrangedSubview(blankSpace)
        
        
        // Adding the title Views
        let appLogoHolderView : UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        appLogoHolderView.addSubview(appLogo)
        appLogo.centerXAnchor.constraint(equalTo: appLogoHolderView.centerXAnchor).isActive = true
        appLogo.centerYAnchor.constraint(equalTo: appLogoHolderView.centerYAnchor).isActive = true
        appLogo.heightAnchor.constraint(equalTo: appLogoHolderView.heightAnchor).isActive = true
        appLogo.widthAnchor.constraint(equalTo: appLogo.heightAnchor).isActive = true
        appLogo.layer.cornerRadius = (view.frame.height / 48)
        appLogo.layer.masksToBounds = true
        
        baseStackView.addArrangedSubview(appLogoHolderView)
        appLogoHolderView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        appLogoHolderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        
        
        
        // Adding the textFields views
        baseStackView.addArrangedSubview(baseView)
        
        baseView.centerXAnchor.constraint(equalTo: baseStackView.centerXAnchor).isActive = true
        baseView.heightAnchor.constraint(equalToConstant: 130).isActive = true


        // Add StackView to the baseView and set Constraints
        baseView.addSubview(myStackView)
        myStackView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        myStackView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
        myStackView.leftAnchor.constraint(equalTo: baseView.leftAnchor, constant: 10).isActive = true
        myStackView.rightAnchor.constraint(equalTo: baseView.rightAnchor, constant: -10).isActive = true

        // Adding all other views to the stackView
        myStackView.addArrangedSubview(usernameText)

        myStackView.addArrangedSubview(usernameDivider)
        usernameDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        myStackView.addArrangedSubview(passwordText)
        myStackView.addArrangedSubview(passwordDivider)
        passwordDivider.heightAnchor.constraint(equalToConstant: 2).isActive = true

        setupUsertypeViews()

        myStackView.addArrangedSubview(userTypeSelectorView)

        
        // Login button
        let loginButtonView = loginButton.getMyButtonView()
        baseStackView.addArrangedSubview(loginButtonView)
        
        

        let blankSpaceTwo = UIView().makeBlankSpace()
        baseStackView.addArrangedSubview(blankSpaceTwo)
        blankSpaceTwo.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        baseStackView.addArrangedSubview(newUserPrompt)
        baseStackView.addArrangedSubview(registerButton)

        // Pushing down the views
        blankSpace.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2, constant: -65).isActive = true
        
        
    }
    
    

    
    
    
    
    // Function to setup the views related to the userType selection
    func setupUsertypeViews(){
        // Setting up the user type selection
        userTypeSelectorView.addSubview(userTypeStackView)
        userTypeSelectorView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        // Adding constraints to the stackview in usertype baseview
        userTypeStackView.centerXAnchor.constraint(equalTo: userTypeSelectorView.centerXAnchor).isActive = true
        userTypeStackView.centerYAnchor.constraint(equalTo: userTypeSelectorView.centerYAnchor).isActive = true
        userTypeStackView.leftAnchor.constraint(equalTo: userTypeSelectorView.leftAnchor).isActive = true
        userTypeStackView.rightAnchor.constraint(equalTo: userTypeSelectorView.rightAnchor).isActive = true
        
        // Adding usertype buttons
        userTypeStackView.addArrangedSubview(userTypeTutorButton)
        userTypeStackView.addArrangedSubview(userTypeStudentButton)
    }
    
    

}

