//
//  StudentMyAttendanceViewController.swift
//  QR Attendance
//
//  Created by Ram Sri Charan on 4/28/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit
import Firebase

class StudentMyAttendanceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    var CurrentDetails : UIViewController.BasicDetails?
    var ViewTitle : String = "My Attendance"
    var isTutor : Bool = false
    
    var timer = Timer()
    var percentageValue : Double?
    var percentageCounter = 0.00
    
    let percentageProgressLayer = CAShapeLayer()

    
    
    struct attendanceObject {
        var isPresent : Bool?
        var date : Date?
        var attendanceId : String?
    }
    
    var attendanceList = [attendanceObject]()
    
    
    var totalClasses = 0
    var totalPresent = 0

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        self.edgesForExtendedLayout = []
        self.navigationController?.navigationBar.barStyle = .blackTranslucent

        
        // Set userType
        if CurrentDetails?.UserType == "tutors" {
            isTutor = true
        }
        
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.tabBarController?.title = ViewTitle
        self.navigationItem.title = ViewTitle
        
        populateAttendanceDetails()
    }
    
    
    
    
    
    
    
    
    
    
    
    ////////////////////////////   Helper Methods  ///////////////////////////////
    func populateAttendanceDetails(){
        attendanceList.removeAll()
        totalClasses = 0
        totalPresent = 0
        
        let classId = CurrentDetails?.ClassID!
        let userId = CurrentDetails?.UserID!
        
        let ref : DatabaseReference = Database.database().reference()
        
        
        
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            
            let attendanceSnapshot : DataSnapshot = snapshot.childSnapshot(forPath: "classes").childSnapshot(forPath: classId!).childSnapshot(forPath: "attendance")
            
            self.totalClasses = Int(attendanceSnapshot.childrenCount) - 1
            
            if(self.totalClasses > 0){
                
                for attendance in (attendanceSnapshot.children.allObjects as? [DataSnapshot])! {
            
                    let attendanceId = attendance.key
                    if( attendanceId != "default"){
                        let validityDate = attendance.childSnapshot(forPath: "validity_till").value as? String
                        let day = validityDate?.toMyDate()
                        var isPresent : Bool = false
                        
                        if attendance.childSnapshot(forPath: "students_present").hasChild(userId!){
                            // Student is present in this class
                            self.totalPresent = self.totalPresent + 1
                            isPresent = true
                        }
                        
                        let attndItem = attendanceObject(isPresent: isPresent, date: day, attendanceId: attendanceId)
                        self.attendanceList.append(attndItem)
                    }
                }
            }
            
            else{
                self.totalClasses = 0
                self.totalPresent = 0
            }
            self.setAttendancePercentage()

        })
    }
    
    
    
    // Set the percentage meter
    func setAttendancePercentage(){
        var attendancePercentage : Double = 0.0
        if (totalClasses > 0){
            attendancePercentage = ( Double (totalPresent) / Double (totalClasses) ) * 100
        }
        
        print("Total Classes: \(totalClasses) \nTotal Attended: \(totalPresent) \nAverage: \(attendancePercentage)")
        
        self.percentageValue = attendancePercentage
        self.percentageCounter = 0.00
        animatePercentage(percentage: attendancePercentage)
        
        totalClassesLabel.text = "Total Classes : \(totalClasses)"
        totalAttendedLabel.text = "Total Attended : \(totalPresent)"
        totalUnAttendedLabel.text = "Total UnAttended : \(totalClasses - totalPresent)"
        
        attendanceList = attendanceList.sorted(by: {
            $0.date?.compare($1.date!) == .orderedDescending
        })
        
        scheduleTableView.reloadData()
        
    }
    
    
    // Changes attendance
    func changeAttendance(atIndex : Int, isPresent : Bool){
        
        let currentAttendance = (attendanceList[atIndex].isPresent)!
        let attendanceId = (attendanceList[atIndex].attendanceId)!
        let classId = (CurrentDetails?.ClassID)!
        let studentId = (CurrentDetails?.UserID)!
        
        let ref : DatabaseReference = Database.database().reference()
        let attendanceRef = ref.child("classes").child(classId).child("attendance").child(attendanceId)
        
        if currentAttendance != isPresent {
            if isPresent{
                attendanceRef.child("students_present").child(studentId).setValue("0")
            }
                
            else{
                attendanceRef.child("students_present").child(studentId).removeValue()
            }
            populateAttendanceDetails()
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    ////////////////////////////   TableView Methods  ///////////////////////////////

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendanceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! MyAttendanceCell
        
        cell.selectionStyle = .none
        
        let attndDate = attendanceList[indexPath.row].date
        cell.dayLabel.text = attndDate?.toMyString().toMyDateString()
        
        if (attendanceList[indexPath.row].isPresent)!{
            cell.attendanceLabel.text = "Present"
            cell.attendanceLabel.textColor = UIColor.MyGreen
        }
        else{
            cell.attendanceLabel.text = "Absent"
            cell.attendanceLabel.textColor = UIColor.red

        }

        return cell
        
    }
    
    
    // Swipe actions methods

    // This methods get implemented by default when UISwipeActionsConfiguration in below two functions
    // returns 'nil'
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isTutor {
        return true
        }
        else{
            return false
        }
    }
    
    
    // Left swipe
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        if isTutor {
            let markAbsentAction = UIContextualAction(style: .normal, title:  "Mark Absent", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("OK, marked as Absent")
                self.changeAttendance(atIndex: indexPath.row, isPresent: false)
                success(true)
            })
            markAbsentAction.backgroundColor = .red
            return UISwipeActionsConfiguration(actions: [markAbsentAction])
        }
        else{
            return nil
        }
    }
    
    
    // Right swipe
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        if isTutor {
            let markPresentAction = UIContextualAction(style: .normal, title:  "Mark Present", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("OK, marked as Present")
                self.changeAttendance(atIndex: indexPath.row, isPresent: true)
                success(true)
            })
            markPresentAction.backgroundColor = UIColor.MyGreen
            return UISwipeActionsConfiguration(actions: [markPresentAction])
        }
        else{
            return nil
        }
    }
    
    

    
    
    
    
    
    
    
    // TableView Custom cell
    class MyAttendanceCell : UITableViewCell {
        // BaseView
        let baseView : UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 5
            view.layer.masksToBounds = true
            view.backgroundColor = UIColor.lightWhite
            return view
        }()
        
        // date label
        var dayLabel : UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .left
            label.font = UIFont.boldSystemFont(ofSize: 20)
            return label
        }()
        
         var attendanceLabel : UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .left
            label.font = UIFont.systemFont(ofSize: 18)
            return label
        }()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            addSubview(baseView)
            baseView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            baseView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
            baseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
            baseView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
            baseView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true

            
            
            baseView.addSubview(dayLabel)
            dayLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 6).isActive = true
            dayLabel.widthAnchor.constraint(equalTo: baseView.widthAnchor, multiplier: 0.95).isActive = true
            dayLabel.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
            
            baseView.addSubview(attendanceLabel)
            attendanceLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 6).isActive = true
            attendanceLabel.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -6).isActive = true

            attendanceLabel.widthAnchor.constraint(equalTo: baseView.widthAnchor, multiplier: 0.95).isActive = true
            attendanceLabel.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    ////////////////////////////   My Views  ///////////////////////////////

    
    // base ScrollView
    let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // Base stackView
    let stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    // Attendance percentage holder view
    let percentageHolderView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black
        return view
    }()
    
    
    // Attendance percentage View
    let percentageView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var percentageDisplayLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 60)
        label.textColor = UIColor.white
        return label
    }()
    
    
    
    // Attendance details baseView
    let attendanceDetailsHolder : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Round corners
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        // Border
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1.5
        
        return view
    }()
    
    
    
    // Attendance stackView
    let attendanceStack : UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    
    
    // Attendance details labels
    var totalClassesLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    // Present label
    var totalAttendedLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.MyGreen
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    // Absent label
    var totalUnAttendedLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.red
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    // TableView Heading
    let tableViewHeading : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.text = "Class Schedule"
        label.textAlignment = .center
        return label
    }()
    
    
    // Attendace TableView
    var scheduleTableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    
    func setupViews(){
        
        // Base Scroll View
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        // Adding StackView to the scrollView
        scrollView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 4).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8).isActive = true
        stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.95).isActive = true
        

        // Add percentage related view
        stackView.addArrangedSubview(percentageHolderView)
        percentageHolderView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        percentageHolderView.addSubview(percentageView)
        percentageView.centerXAnchor.constraint(equalTo: percentageHolderView.centerXAnchor).isActive = true
        percentageView.centerYAnchor.constraint(equalTo: percentageHolderView.centerYAnchor).isActive = true
        percentageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        percentageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        setupPercentageMeter()
        

        stackView.addArrangedSubview(attendanceDetailsHolder)
        attendanceDetailsHolder.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.9).isActive = true
        
        // Attendance details views
        attendanceDetailsHolder.addSubview(totalClassesLabel)
        totalClassesLabel.topAnchor.constraint(equalTo: attendanceDetailsHolder.topAnchor, constant: 12).isActive =  true
        totalClassesLabel.centerXAnchor.constraint(equalTo: attendanceDetailsHolder.centerXAnchor).isActive = true
        
        attendanceDetailsHolder.addSubview(totalAttendedLabel)
        totalAttendedLabel.topAnchor.constraint(equalTo: totalClassesLabel.bottomAnchor, constant: 8).isActive =  true
        totalAttendedLabel.centerXAnchor.constraint(equalTo: attendanceDetailsHolder.centerXAnchor).isActive = true
        
        attendanceDetailsHolder.addSubview(totalUnAttendedLabel)
        totalUnAttendedLabel.topAnchor.constraint(equalTo: totalAttendedLabel.bottomAnchor, constant: 8).isActive =  true
        totalUnAttendedLabel.centerXAnchor.constraint(equalTo: attendanceDetailsHolder.centerXAnchor).isActive = true
        
        attendanceDetailsHolder.addSubview(tableViewHeading)
        tableViewHeading.topAnchor.constraint(equalTo: totalUnAttendedLabel.bottomAnchor, constant: 24).isActive =  true
        tableViewHeading.centerXAnchor.constraint(equalTo: attendanceDetailsHolder.centerXAnchor).isActive = true
        

        // TableView
        scheduleTableView.register(MyAttendanceCell.self, forCellReuseIdentifier: "CustomTableViewCell")
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        scheduleTableView.rowHeight = UITableViewAutomaticDimension
        scheduleTableView.estimatedRowHeight = 600.0
        scheduleTableView.backgroundColor = UIColor.white
        
        attendanceDetailsHolder.addSubview(scheduleTableView)
        scheduleTableView.topAnchor.constraint(equalTo: tableViewHeading.bottomAnchor, constant: 10).isActive = true
        scheduleTableView.centerXAnchor.constraint(equalTo: attendanceDetailsHolder.centerXAnchor).isActive = true

        scheduleTableView.widthAnchor.constraint(equalTo: attendanceDetailsHolder.widthAnchor, constant: 0.9).isActive = true
        scheduleTableView.bottomAnchor.constraint(equalTo: attendanceDetailsHolder.bottomAnchor, constant: -8).isActive = true
    }
    
    
    
    
    func setupPercentageMeter(){
        
        let MidX = 150.0
        let MidY = 180.0
        let center = CGPoint(x: MidX, y: MidY)
        let circularPath = UIBezierPath(arcCenter: center, radius: 140, startAngle: CGFloat.pi, endAngle: 0, clockwise: true)

        // background layer
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        backgroundLayer.lineWidth = 10
        backgroundLayer.lineCap = kCALineCapRound
        backgroundLayer.fillColor = UIColor.clear.cgColor
        percentageView.layer.addSublayer(backgroundLayer)
        
        // percentage progress layer
        percentageProgressLayer.path = circularPath.cgPath
        percentageProgressLayer.strokeColor = UIColor.green.cgColor
        percentageProgressLayer.lineWidth = 10
        percentageProgressLayer.lineCap = kCALineCapRound
        percentageProgressLayer.strokeEnd = 0
        percentageProgressLayer.fillColor = UIColor.clear.cgColor
        percentageView.layer.addSublayer(percentageProgressLayer)
        
        // Add TextView to display percentage
        
        percentageView.addSubview(percentageDisplayLabel)
        percentageDisplayLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        percentageDisplayLabel.widthAnchor.constraint(equalToConstant: 170).isActive = true
        percentageDisplayLabel.centerXAnchor.constraint(equalTo: percentageView.centerXAnchor).isActive = true
        percentageDisplayLabel.centerYAnchor.constraint(equalTo: percentageView.centerYAnchor, constant: 20).isActive = true
        
        
    }
    
    
    
    func animatePercentage(percentage : Double){
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = percentage/100
        basicAnimation.duration = 2
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        
        percentageProgressLayer.add(basicAnimation, forKey: "basicAnim")
        
        
                
        // Set textField
        percentageDisplayLabel.fadeTransition(0)
        percentageDisplayLabel.text = "0.00%"
        
        if(percentage >= 1.00){
        percentageDisplayLabel.fadeTransition(1)
        timer = Timer.scheduledTimer(timeInterval: 0.025, target:self, selector: #selector(changeText), userInfo: nil, repeats: true)
        }
        else{
            let percentage_string = String(format: "%.2f", percentageCounter)
            percentageDisplayLabel.text = "\(percentage_string)%"
        }
    }
    
    

    
    
    @objc func changeText(){
        
        let percentageStep = percentageValue!/80
        percentageCounter = percentageCounter + percentageStep
        
        var percentage_string = String(format: "%.2f", percentageCounter)

        if percentageCounter >= percentageValue!{
            print("Stop Looping")
            percentage_string = String(format: "%.2f", percentageValue!)
            timer.invalidate()
        }
        percentageDisplayLabel.text = "\(percentage_string)%"
    }
    
    
    
    
    
    
    

}
