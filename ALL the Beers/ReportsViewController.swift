//
//  ReportsViewController.swift
//  ALL the Beers
//
//  Created by Jason Affourtit on 2/7/21.
//
//  This is a very basic view that shares some statistics about all the beers rated so far

import UIKit

class ReportsViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    @IBOutlet var imageView: UIImageView!
    
    // a bit of a kludge, where myReportText is just a dictionary of the individual stats
    // populated in the main ViewController. I did this for simplicity in case other stats
    // were added at a later date.
    var myReportText = [Int: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Super cool reports! 🕵️‍♀️"
        
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.black.cgColor
        
        // append each row in the text object to the UITextView that makes up the report
        for i in 1...myReportText.keys.count {
            textView.insertText("\(String(myReportText[i]!))\n\n")
        }
    }
}
