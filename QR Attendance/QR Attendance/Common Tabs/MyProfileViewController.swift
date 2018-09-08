//
//  TutorProfileViewController.swift
//  QR Attendance
//
//  Created by Ram Sri Charan on 4/22/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit
import Firebase

class MyProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    
    var imagePicker = UIImagePickerController()
    var CurrentDetails : UIViewController.BasicDetails?

    var userType = "", currentUserId = ""
    var UserName, PhoneNumber, SchoolName, AboutMe, ProfilePath : String?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.navigationItem.searchController?.isActive = false
        
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        
        self.hideKeyboardWhenTappedAround()
        self.avoidKeyboardObstruction()
        
        userType = (CurrentDetails?.UserType!)!
        currentUserId = (CurrentDetails?.UserID!)!
        
        setupViews()
        fetchDataFromDB()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.title = "My Profile"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.searchController = nil
    }
    
    
    
    
    
    
    
    
    
    ////////////////////////////   Action Handlers  ///////////////////////////////
    @objc func handleSave(){
        print("Save pressed")
        if(usernameText.text?.isEmpty)!{
            let alert = UIAlertController(title: "Unable to save", message: "User's name cannot be empty.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            saveDetailsToDB()
        }
    }
    
    
    @objc func handleLogout(){
        // Logging out the user
        do{
            try Auth.auth().signOut()
        } catch let error{
            print(error)
        }
        // Gping back to Login page
        let loginPage = LoginViewController()
        present(loginPage, animated : true, completion : nil)
    }
    
    
    @objc func handleProfileTapped(){
        print("Profile image clicked")
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    ////////////////////////////   Helper Methods  ///////////////////////////////

    // Gets the data of current user from the Firebase
    func fetchDataFromDB(){
        let ref : DatabaseReference = Database.database().reference()
        
        ref.child(userType).child(currentUserId).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            self.UserName = value?["user_name"] as? String ?? ""
            self.PhoneNumber = value?["phone_no"] as? String ?? ""
            self.SchoolName = value?["school_name"] as? String ?? ""
            self.AboutMe = value?["about_me"] as? String ?? ""
            self.ProfilePath = value?["picture_path"] as? String ?? ""
            
            self.setDataIntoViews()
        })
    }
    
    
    // Sets the data into the Views
    func setDataIntoViews(){
        
        // Set data only if available
        if(UserName != ""){
            usernameText.text = UserName
        }
        if(PhoneNumber != ""){
            phoneNumberText.text = PhoneNumber
        }
        if(SchoolName != ""){
            schoolNameText.text = SchoolName
        }
        if(AboutMe != ""){
            aboutMeText.text = AboutMe
        }
        
        if(ProfilePath != "" && ProfilePath != "No_image"){
            self.downloadImageIntoView(imagePath: ProfilePath!, imageView: profileImageView)
        }
    }
    
    
    
    // Save data to the database
    func saveDetailsToDB(){
        let loadingScreen = UIViewController.displaySpinner(onView: self.view, Message: "Saving Profile")
        
        let ref : DatabaseReference = Database.database().reference().child(userType).child(currentUserId)
        let newUserName = usernameText.text ?? ""
        let newPhoneNumber = phoneNumberText.text ?? ""
        let newSchoolName = schoolNameText.text ?? ""
        let newAboutMe = aboutMeText.text ?? ""
        let profileImageName = currentUserId + ".jpg"
        
        // Upload to database only if values changed
        if(newUserName != UserName){
            ref.child("user_name").setValue(newUserName)
        }
        if(newPhoneNumber != PhoneNumber){
            ref.child("phone_no").setValue(newPhoneNumber)
        }
        if(newSchoolName != SchoolName){
            ref.child("school_name").setValue(newSchoolName)
        }
        if(newAboutMe != AboutMe){
            ref.child("about_me").setValue(newAboutMe)
        }
        
        // Check if new image is uploaded
        if(profileImageView.image == #imageLiteral(resourceName: "blank_profile"))
        {
            print("No new image uploaded")
            
            ref.child("picture_path").setValue("No_image")

            UIViewController.removeSpinner(spinner: loadingScreen)
        }
            
            // New image is selected.. Need to upload it
        else{
            // Now upload the profile image
            let storageRef : StorageReference = Storage.storage().reference().child("profile_images").child(profileImageName)
            
            if let uploadImage = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1){
                storageRef.putData(uploadImage, metadata: nil, completion: {(metadata, error) in
                    if(error != nil){
                        print(error!)
                        return
                    }
                    
                    if let imageURL = metadata?.downloadURL()?.absoluteString {
                        ref.child("picture_path").setValue(imageURL)
                        // After Saving go to home
                        UIViewController.removeSpinner(spinner: loadingScreen)
                    }
                })
            }
        }
    }
    
    
    
    
    
    
    ////////////////////////////   ImagePicker Functions  ///////////////////////////////
    
    // On Cancelling the image upload
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image upload cancelled")
        dismiss(animated: true, completion: nil)
    }
    // Image picker functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Got the image")
        dismiss(animated: true, completion: nil)
        
        var selectedImageFromPicker : UIImage?
        
        // Check if image is edited
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            print("Got edited image")
            selectedImageFromPicker = editedImage
        }
            
            // If not take the original image
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            print("Got original image")
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    ////////////////////////////   My views  ///////////////////////////////
    
    //Base Scroll View
    let scrollView : UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black
        return view
    }()
    
    // StackView
    let stackView : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    
    // Profile ImageView holder
    let profileImageViewHolder : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    
    
    // Profile ImageVIew
    lazy var profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.image = #imageLiteral(resourceName: "blank_profile")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileTapped))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    // Blank view for spacing
    let blankSpaceOne : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    
    // baseview for all textFields
    let textFieldsBaseView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
    // textFields base stackView
    let textFieldStackView : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()
    
    
    
    // User name textfield and divider
    var usernameText : UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Name"
        view.adjustsFontSizeToFitWidth = true
//        view.font = UIFont.systemFont(ofSize: 18)
        return view
    }()
    
    let usernameDivider : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Company name text field and divider
    var schoolNameText : UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "School Name"
        view.adjustsFontSizeToFitWidth = true
//        view.font = UIFont.systemFont(ofSize: 18)
        return view
    }()
    
    let schoolNameDivider : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // Phone number text field and divider
    var phoneNumberText : UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Phone Number"
        view.keyboardType = .numberPad
        view.adjustsFontSizeToFitWidth = true
//        view.font = UIFont.systemFont(ofSize: 18)
        return view
    }()
    
    let phoneNumberDivider : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    // About me text view
    var aboutMeText : UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "About me"
        view.adjustsFontSizeToFitWidth = true
//        view.font = UIFont.systemFont(ofSize: 18)
        return view
    }()
    
    
    // Blank view for spacing
    let blankSpaceTwo : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // Login button
    let saveButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: UIControlState.normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.green.cgColor
        button.setTitleColor(UIColor.green, for: .normal)
        
        return button
    }()
    

    
    // Login button
    let logoutButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Logout", for: UIControlState.normal)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.red.cgColor
        button.setTitleColor(UIColor.red, for: .normal)
        
        return button
    }()
    
    
    
    func setupViews(){
        // Base ScrollView
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        // Adding StackView to the scrollView
        scrollView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8).isActive = true
        stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9).isActive = true
        
        // Adding other views to stackView
        stackView.addArrangedSubview(profileImageViewHolder)
        profileImageViewHolder.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45).isActive = true
        
        profileImageViewHolder.addSubview(profileImageView)
        profileImageView.centerYAnchor.constraint(equalTo: profileImageViewHolder.centerYAnchor).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: profileImageViewHolder.centerXAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageViewHolder.heightAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true

        
        stackView.addArrangedSubview(blankSpaceOne)
        blankSpaceOne.heightAnchor.constraint(equalToConstant: 20).isActive = true
        

        // Adding all textFields into the StackView
        arrangeTextFields()
        

        stackView.addArrangedSubview(blankSpaceTwo)
        blankSpaceTwo.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        // Adding the save button
        let saveButtonView = saveButton.getMyButtonView()
        stackView.addArrangedSubview(saveButtonView)
        
        let logoutButtonView = logoutButton.getMyButtonView()
        stackView.addArrangedSubview(logoutButtonView)
        
    }
    
    
    func arrangeTextFields(){
        stackView.addArrangedSubview(textFieldsBaseView)
        
        textFieldsBaseView.addSubview(textFieldStackView)
        textFieldStackView.topAnchor.constraint(equalTo: textFieldsBaseView.topAnchor, constant: 8).isActive = true
        textFieldStackView.bottomAnchor.constraint(equalTo: textFieldsBaseView.bottomAnchor, constant: -8).isActive = true
        textFieldStackView.leftAnchor.constraint(equalTo: textFieldsBaseView.leftAnchor, constant: 8).isActive = true
        textFieldStackView.rightAnchor.constraint(equalTo: textFieldsBaseView.rightAnchor, constant: -8).isActive = true
        
        textFieldStackView.addArrangedSubview(usernameText)
        textFieldStackView.addArrangedSubview(usernameDivider)
        usernameDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        textFieldStackView.addArrangedSubview(schoolNameText)
        textFieldStackView.addArrangedSubview(schoolNameDivider)
        schoolNameDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        textFieldStackView.addArrangedSubview(phoneNumberText)
        textFieldStackView.addArrangedSubview(phoneNumberDivider)
        phoneNumberDivider.heightAnchor.constraint(equalToConstant: 1).isActive  = true
        
        textFieldStackView.addArrangedSubview(aboutMeText)
        
    }

    
    
}
