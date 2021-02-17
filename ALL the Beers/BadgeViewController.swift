//
//  BadgeViewController.swift
//  ALL the Beers
//
//  Created by Jason Affourtit on 2/6/21.
//
//  This VC is used to display any badge(s) that were earned upon rating a beer

import UIKit

class BadgeViewController: UIViewController {

    @IBOutlet var badgeName: UILabel!
    @IBOutlet var badgeImage: UIImageView!
    @IBOutlet var okButton: UIButton!
    
    var image = UIImage()
    var label = String()
    var imageName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = Bundle.main.path(forResource: imageName, ofType: nil)!
        badgeName.text = label
        badgeImage.image = UIImage(contentsOfFile: path)!
        
        okButton.layer.cornerRadius = 10.0
        okButton.contentEdgeInsets = UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 5)
        okButton.layer.borderWidth = 2
        okButton.layer.borderColor = UIColor.black.cgColor
        
        badgeImage.layer.borderWidth = 2
        badgeImage.layer.borderColor = UIColor.black.cgColor
    }
    
    // dismiss this view controller and return to the beer rating page
    // or go back to any other badge(s) earned if a given rating triggered multiple badges
    @IBAction func okTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "List") as? ViewController {
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
}
