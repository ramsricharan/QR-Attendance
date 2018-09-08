//
//  TutorQRCodeViewController.swift
//  QR Attendance
//
//  Created by Ram Sri Charan on 4/22/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit



class TutorQRCodeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    
    let classSizes = ["  Small (10x10 meters)  ", "  Medium (50x50 meters)  ", "  Large (100x100 meters)  "]
    let classSizesLookup = ["Small", "Medium", "Large"]

    
    let validityTimes = ["1 min", "5 mins", "10 mins", "15 mins", "30 mins", "60 mins"]
    
    var CurrentDetails : UIViewController.BasicDetails?
    
    
    let locationManager = CLLocationManager()
    var longitude_String = "" , latitude_String = ""
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barStyle = .blackTranslucent

        view.backgroundColor = UIColor.darkGray
        setupViews()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
         initiateLocationServices()
        self.tabBarController?.title = "QR Code"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.searchController = nil
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.locationManager.stopUpdatingLocation()
    }
    
    
    
    
    
    
    
    
    ////////////////////////////   Location Services  ///////////////////////////////
    
    // Location services initiater
    func initiateLocationServices(){
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }

        let long = String (locValue.longitude)
        let lat = String (locValue.latitude)

        if long != longitude_String && lat != latitude_String {
            print("locations = \(locValue.latitude) \(locValue.longitude)")
            longitude_String = long
            latitude_String = lat
        }
    }
    
    
    
    
    
    
    
    
    ////////////////////////////   Helper Methods  ///////////////////////////////
    
    // Gives back selected Class Size string
    func getClassSizeString() -> String{
        return classSizesLookup[classSizePicker.selectedRow(inComponent: 0)]
//        let selectedClassSize = classSizes[classSizePicker.selectedRow(inComponent: 0)]
//        let formattedClassSize = selectedClassSize.getStringBeforeCharacter(lastCharacter: " (")
//        return formattedClassSize
        
    }

    // Gives back valid till time string
    func getValidityTimeString() -> String{
        let selectedValidityPeriod = validityTimes[validityPicker.selectedRow(inComponent: 0)]
        let formattedValidityPeriod = Double (selectedValidityPeriod.getStringBeforeCharacter(lastCharacter: " min"))
        
        let minutes: TimeInterval = formattedValidityPeriod! * 60
        let validityTillTime = Date() + minutes
        return validityTillTime.toMyString()

    }
    
    // Create the attendance child in the firebase
    func addAttendanceToDB(){
        
        let loadingScreen : UIView = UIViewController.displaySpinner(onView: self.view, Message: "Creating QR Code")

        let classSize = getClassSizeString()
        let validTill = getValidityTimeString()
        let currentClassId = CurrentDetails?.ClassID
        let location = [ "longitude" : longitude_String,
                         "latitude" : latitude_String]
        
        let ref : DatabaseReference = Database.database().reference()
        let attendanceRef : DatabaseReference = ref.child("classes").child(currentClassId!).child("attendance").childByAutoId()
        
        let attendanceId = attendanceRef.key
        let QRCodeImageName = "QRCode_\(attendanceId).jpg"
        let QRCodeImage = generateQRCodeFor(dataString: attendanceId)
        
                
        // Upload QRImage to storage
        let storageRef : StorageReference = Storage.storage().reference().child("QR_Codes").child(QRCodeImageName)
        
        if let uploadData = UIImagePNGRepresentation(QRCodeImage){
        
            print("Uploading QRCode started")
            ref.child("classes").child(currentClassId!).child("latest_attendance").setValue(attendanceId)

            attendanceRef.child("classroom_size").setValue(classSize)
            attendanceRef.child("validity_till").setValue(validTill)
            attendanceRef.child("class_location").setValue(location)
            

            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/jpeg"
            
            storageRef.putData(uploadData, metadata: uploadMetadata, completion: {(metadata, error) in
                if(error != nil){
                    print(error!)
                    return
                }
                
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    attendanceRef.child("qrcode_path").setValue(imageURL)
                    UIViewController.removeSpinner(spinner: loadingScreen)
                    // After creating.. Display it
                    let displayViewController : DisplayQRCodeViewController = DisplayQRCodeViewController()
                    displayViewController.QRCodeLink = imageURL

                    self.tabBarController?.navigationController?.pushViewController(displayViewController, animated: true)
                }
            })
        
        }
        
        else{
            print("Upload failed")
        }
            
    }




    // Generate QRCode image
    func generateQRCodeFor(dataString : String) -> UIImage{
        let data = dataString.data(using: .ascii, allowLossyConversion: false)
        let filter : CIFilter = CIFilter(name : "CIQRCodeGenerator")!
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let output = filter.outputImage?.transformed(by: transform)
        let QRCodeImage : UIImage = convert(cmage: output!)
        return QRCodeImage
    }
    
    // Converting CIImage to UIImage
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    
    ////////////////////////////   Action Handlers  ///////////////////////////////
    
    @objc func generateTapped(){

        if(longitude_String == "" || latitude_String == "" || longitude_String == "0.0" || latitude_String == "0.0" ){
            self.showAlert(AlertTitle: "Location Service Error", Message: "There is some error with the location services. Please make sure to allow location permissions for this app")
        }
            
        else{
            addAttendanceToDB()
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    ////////////////////////////   Picker View functions  ///////////////////////////////
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of row based on pickerView
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == classSizePicker){
            return classSizes.count
        }
        else {
            return validityTimes.count
        }
    }
    
    // To handle textLabel in each PickerView row
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view as? UILabel { label = v }
        label.font = UIFont (name: "Helvetica Neue", size: 15)

        if pickerView == classSizePicker{
            label.text =  classSizes[row]
        }
        else{
            label.text = validityTimes[row]
        }

        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor.lightWhite

        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        
        return label
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
    
    // View heading
    let tabHeadingLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = true
        label.text = "Generate Attendance QR"
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()
    
    
    // Info label
    let infoLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = true
        label.text = "Please provide the following details to create the QR code for today's attendance."
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // Class size picker holder
    let classSizePickerHolder : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
        // Class Size heading label
        let classSizePickerLabel : UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Classroom size : "
            label.textColor = UIColor.white
            label.adjustsFontSizeToFitWidth = true
            label.font = .boldSystemFont(ofSize: 16)
            return label
        }()
    
    
        // Class size picker
        let classSizePicker : UIPickerView = {
            let picker = UIPickerView()
            picker.translatesAutoresizingMaskIntoConstraints = false
            picker.tintColor = UIColor.white
            return picker
        }()
    
    
    
    // Class size picker holder
    let validityPickerHolder : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
        // Validity Picker Label
        let validityPickerLabel : UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Validity Period : "
            label.textColor = UIColor.white
            label.adjustsFontSizeToFitWidth = true
            label.font = .boldSystemFont(ofSize: 16)
            return label
        }()
    
        // Time picker
        let validityPicker : UIPickerView = {
            let picker = UIPickerView()
            picker.translatesAutoresizingMaskIntoConstraints = false
            picker.tintColor = UIColor.white
            return picker
        }()
    
    
    
    // generate button
    var generateButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Generate", for: .normal)
        button.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
        
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.green.cgColor
        button.setTitleColor(UIColor.green, for: .normal)

        
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
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -32).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8).isActive = true
        stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9).isActive = true
        
        // Adding header labels to stackView
        stackView.addArrangedSubview(tabHeadingLabel)
        stackView.addArrangedSubview(infoLabel)
        
        // Arranging Pickers
        arrangeGivenPickerView(baseView: classSizePickerHolder, textlabel: classSizePickerLabel, pickerView: classSizePicker)
        stackView.addArrangedSubview(classSizePickerHolder)
        
        arrangeGivenPickerView(baseView: validityPickerHolder, textlabel: validityPickerLabel, pickerView: validityPicker)
        stackView.addArrangedSubview(validityPickerHolder)
        
        // Generate Button
        let generateButtonView = generateButton.getMyButtonView()
        stackView.addArrangedSubview(generateButtonView)
    }
    
    
    func arrangeGivenPickerView(baseView : UIView, textlabel : UILabel, pickerView : UIPickerView){
        baseView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // Setting up the label
        baseView.addSubview(textlabel)
        textlabel.rightAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        textlabel.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
        
        // Setting up the picker View
        pickerView.dataSource = self
        pickerView.delegate = self
        baseView.addSubview(pickerView)
        pickerView.leftAnchor.constraint(equalTo: baseView.centerXAnchor, constant: 8).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
        pickerView.widthAnchor.constraint(equalTo: baseView.widthAnchor, multiplier: 0.4).isActive = true
        pickerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        pickerView.selectRow(1, inComponent: 0, animated: true)

    }

}
