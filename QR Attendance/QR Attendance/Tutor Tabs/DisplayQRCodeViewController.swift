//
//  DisplayQRCodeViewController.swift
//  QR Attendance
//
//  Created by Ram Sri Charan on 4/27/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit

class DisplayQRCodeViewController: UIViewController {

    var QRCodeLink = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadDataIntoViews()
    }

    
    
    ////////////////////////////   Action Handlers  ///////////////////////////////
    
    @objc func handleLinkTapped(){
        print("Opening the URL in browser")
        let url = URL(string : QRCodeLink)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    ////////////////////////////   Helper Methods  ///////////////////////////////

    func loadDataIntoViews(){
        self.downloadImageIntoView(imagePath: QRCodeLink, imageView: qrCodeImageView)
        qrCodeLinkLabel.text = QRCodeLink
    }
    
    
    
    
    
    
    
    ////////////////////////////   My views  ///////////////////////////////

    //Base Scroll View
    let scrollView : UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    // StackView
    let stackView : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
    
    
    // View heading
    let tabHeadingLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = true
        label.text = "Current Lectures QR Code"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()
    
    
    
    // qrCode ImageView holder
    let qrCodeImageViewHolder : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    
    // QRCode imageView
    var qrCodeImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    
    // QRCode link heading label
    let qrCodeLinkHeadingLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You can also use the following link to display the QR Code in web browser"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    // QRCode link label
    lazy var qrCodeLinkLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.blue
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 5
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLinkTapped))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    
    
    // Setup Views
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
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8).isActive = true
        stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9).isActive = true
        
        // Adding other Views to the stackView
        stackView.addArrangedSubview(tabHeadingLabel)
        
        // Adding the qrCode imageView
        stackView.addArrangedSubview(qrCodeImageViewHolder)
        qrCodeImageViewHolder.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45).isActive = true
        
        qrCodeImageViewHolder.addSubview(qrCodeImageView)
        qrCodeImageView.centerYAnchor.constraint(equalTo: qrCodeImageViewHolder.centerYAnchor).isActive = true
        qrCodeImageView.centerXAnchor.constraint(equalTo: qrCodeImageViewHolder.centerXAnchor).isActive = true
        qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageViewHolder.heightAnchor).isActive = true
        qrCodeImageView.widthAnchor.constraint(equalTo: qrCodeImageViewHolder.heightAnchor).isActive = true

        
        // Adding the link related views
        stackView.addArrangedSubview(qrCodeLinkHeadingLabel)
        stackView.addArrangedSubview(qrCodeLinkLabel)
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
