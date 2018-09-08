//
//  MyClassesTableViewController.swift
//  QR Attendance
//
//  Created by Ram Sri Charan on 4/20/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit
import Firebase

class MyClassesTableViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private let reuseIdentifier = "Cell"
    

    struct ClassDetails {
        var ClassID : String?
        var ClassName : String?
        var PosterURL : String?
    }
    
    struct UserDetails {
        let UserName : String?
        let UserID : String?
        let UserType : String?
    }
    
    var CurrentUserDetails = UserDetails(UserName: "userName", UserID: "userId", UserType: "userType")
    
    var MyClassList = [ClassDetails]()
    
   
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(myCustomCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        view.backgroundColor = UIColor.black
        
        
        
        // If user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(logoutPressed), with: nil, afterDelay: 0)
        }
            
            //  if user is logged in
        else{
            // First getting the data from the cloud
//            getUserDetails()


            // Navigation bar setup
            self.navigationItem.title = "My Classes"
            
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
                
                //[NSForegroundColorAttributeName: UIColor.orange]
            
            
            let addClassButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddClass))
            
            let logoutButton : UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "logout_icon"), style: .plain, target: self, action: #selector(logoutPressed))
            
            self.navigationItem.leftBarButtonItem = logoutButton
            self.navigationItem.rightBarButtonItem = addClassButton
            
        }

    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if Auth.auth().currentUser?.uid != nil {
             getUserDetails()
        }

    }
    
    
    
    
    
    
    
    
    
    
    
    ////////////////////////////// Helper methods //////////////////////////////
    
    func getUserDetails(){
        let userId = Auth.auth().currentUser?.uid
        let ref : DatabaseReference = Database.database().reference()
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            
            var userType = ""
            if(snapshot.childSnapshot(forPath: "tutors").hasChild(userId!)){
                userType = "tutors"
            }
            else{
                userType = "students"
            }
            
            let currentUserSnaphot : DataSnapshot = snapshot.childSnapshot(forPath: userType).childSnapshot(forPath: userId!)
            let userName = currentUserSnaphot.childSnapshot(forPath: "user_name").value as? String ?? ""
            
            self.CurrentUserDetails = UserDetails(UserName: userName, UserID: userId, UserType: userType)
            
            self.populateMyClassesList()

        })
    }
    
    
    func populateMyClassesList(){
        MyClassList.removeAll()
        
        let usertype = CurrentUserDetails.UserType!
        let userid = CurrentUserDetails.UserID!
        
        let ref : DatabaseReference = Database.database().reference()
        ref.observeSingleEvent(of: .value, with: {(snapshot)
            in
            let myClassSnapshot = snapshot.childSnapshot(forPath: usertype).childSnapshot(forPath: userid).childSnapshot(forPath: "my_classes")
            
            if myClassSnapshot.childrenCount >= 1 {
                let enumerator = myClassSnapshot.children
                while let currentClass = enumerator.nextObject() as? DataSnapshot {
                    
                    let classId = currentClass.key
                    if !classId.contains("default"){
                        let className = snapshot.childSnapshot(forPath: "classes").childSnapshot(forPath: classId).childSnapshot(forPath: "class_name").value as? String
                        
                        let posterUrl = snapshot.childSnapshot(forPath: "classes").childSnapshot(forPath: classId).childSnapshot(forPath: "poster_path").value as? String
                        
                        
                        let currentClassDetails = ClassDetails.init(ClassID: classId, ClassName: className, PosterURL: posterUrl)
                        self.MyClassList.append(currentClassDetails)
                    }
                    
                }
                self.collectionView?.reloadData()
            }
        })
    }
    
    
    
    // For students to add new class using id
    func addClassUsingIdForStudents(){
        // Create the alert controller.
        let alert = UIAlertController(title: "Add New Class", message: "Please provide a valid code provided by your tutor of the class you wish to enroll.", preferredStyle: .alert)
        
        // Add the text field. You can configure it however you need.
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Class Code"
        })
        
        // Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (action) -> Void in
            let textField = (alert?.textFields![0])! as UITextField
            let givenClassId = textField.text
            if !(givenClassId?.isEmpty)!{
                
                // Check if has invalid Character
                if (givenClassId?.hasInvalidCharacters())!{
                    self.showAlert(AlertTitle: "Enrollment failed", Message: "Class Code has invalid characters.")
                }
                else{
                    self.checkAndAddClass(givenClassId: givenClassId!)
                }
            }
            else{
                self.showAlert(AlertTitle: "Enrollment failed", Message: "Class Code cannot be blank.")
            }
        }))
        
        // Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func checkAndAddClass(givenClassId : String){
        
        let studentId = CurrentUserDetails.UserID!
        let ref : DatabaseReference = Database.database().reference()

        
        
        // Check if this is a valid class id
        ref.observeSingleEvent(of: .value, with: {(snapshot)
            in
            
            let classesSnapshot : DataSnapshot = snapshot.childSnapshot(forPath: "classes")
            let currentClassSnapshot : DataSnapshot = classesSnapshot.childSnapshot(forPath: givenClassId)
            
            
            // Checking for valid class id
            if classesSnapshot.hasChild(givenClassId){
                // Class id is valid
                
                if givenClassId == "default"{
                    
                }
                
                else if currentClassSnapshot.hasChild(studentId){
                    // Student already enrolled
                    self.showAlert(AlertTitle: "Enrollment failed", Message: "You already enrolled to this class!")
                }
                
                else{
                    // New enrollment.. Add student to class
                    ref.child("classes").child(givenClassId).child("students").child(studentId).setValue("0")
                    
                    // Add this class to the students class list
                    ref.child("students").child(studentId).child("my_classes").child(givenClassId).setValue("0")
                    
                    // Reload the classes List
                     self.populateMyClassesList()
                }
                
            }
            
            else{
                // Invalid class Id
                self.showAlert(AlertTitle: "Invalid Class Code", Message: "The class code that you entered is invalid. Please make sure you use a valid Class Code to enroll into the class.")
            }
            
        })
    }
    
    
    
    
    
    
    
    
    
    
    ////////////////////////////// Action handlers //////////////////////////////

    
    @objc func handleAddClass(){
        print("Add class pressed")
        if CurrentUserDetails.UserType == "tutors"{
        self.navigationController?.pushViewController(AddNewClassViewController(), animated: true)
        }
        else if CurrentUserDetails.UserType == "students" {
            print("Students")
            addClassUsingIdForStudents()
        }
    }
    
    // Logout button handler
    @objc func logoutPressed(){
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
    
    
    
    
    
    
    
    
    
    
    
    
    

    //////////////////////      Collection View related methods      ////////////////////

    //
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MyClassList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! myCustomCell
        
        cell.posterImageView.image = nil
        
        self.downloadImageIntoView(imagePath: MyClassList[indexPath.row].PosterURL!, imageView: cell.posterImageView)
        cell.classNameLabel.text = MyClassList[indexPath.row].ClassName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 150 , height: 200)
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let cellWidth : CGFloat = 150.0
        
        let numberOfCells = floor(self.view.frame.size.width / cellWidth)
        let edgeInsets = (self.view.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)
        
        return UIEdgeInsetsMake(20, edgeInsets, 0, edgeInsets)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let tabBarController : BaseTabBarViewController = BaseTabBarViewController()
        
        let details = UIViewController.BasicDetails(UserName: CurrentUserDetails.UserName, UserID: CurrentUserDetails.UserID, UserType: CurrentUserDetails.UserType, ClassID: MyClassList[indexPath.row].ClassID, ClassName: MyClassList[indexPath.row].ClassName, PosterURL: MyClassList[indexPath.row].PosterURL)
        
        tabBarController.CurrentDetails = details
        

        
        self.navigationController?.pushViewController(tabBarController, animated: true)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    



}







////////////////////////////// Custom Collection view cell  //////////////////////////////



class myCustomCell : UICollectionViewCell {
    
    // Background image
    var myImage : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints  = false
        image.contentMode = .scaleToFill
        image.image = #imageLiteral(resourceName: "book_cover")
        return image
    }()
    
    // BaseView
    let baseView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Book Poster imageView
    let posterImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    // Class name label
    var classNameLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        backgroundColor = UIColor.red
        
        // Setting up the background image
        addSubview(myImage)
        myImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        myImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        myImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
        myImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        // Setting the baseView
        addSubview(baseView)
//        baseView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        baseView.leftAnchor.constraint(equalTo: leftAnchor, constant: 22).isActive = true
        baseView.rightAnchor.constraint(equalTo: rightAnchor, constant: -9).isActive = true
        baseView.topAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true
        baseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11).isActive = true
        
        
        // Setting the poster ImageView
        addSubview(posterImageView)
        posterImageView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        posterImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        posterImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        posterImageView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 5).isActive = true

        // Setting the class name label
        addSubview(classNameLabel)
        classNameLabel.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        classNameLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor).isActive = true
        classNameLabel.leftAnchor.constraint(equalTo: baseView.leftAnchor, constant: 4).isActive = true
        classNameLabel.rightAnchor.constraint(equalTo: baseView.rightAnchor, constant: -4).isActive = true
        
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}




