//
//  ReportsViewController.swift
//  ALL the Beers
//
//  Created by Jason Affourtit on 2/7/21.
//

import UIKit

class ReportsViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    @IBOutlet var imageView: UIImageView!
    
    var myReportText = [Int: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Super cool reports! 🕵️‍♀️"
        
        //let reports = myReportText
        //        print(reports)
        
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.black.cgColor
        
        for i in 1...myReportText.keys.count {
            textView.insertText("\(String(myReportText[i]!))\n\n")
        }
    }
}
