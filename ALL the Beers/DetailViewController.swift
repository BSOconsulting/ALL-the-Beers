//
//  DetailViewController.swift
//  ALL the Beers
//
//  Created by Jason Affourtit on 2/03/21.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var flightLabel: UILabel!
    @IBOutlet var orderLabel: UILabel!
    @IBOutlet var breweryLabel: UILabel!
    @IBOutlet var beerStyleLabel: UILabel!
    @IBOutlet var abvLabel: UILabel!
    @IBOutlet var ibuLabel: UILabel!
    @IBOutlet var regionLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var commentBox: UITextView!
    @IBOutlet var ratingSlider: UISlider!
    @IBOutlet var commentView: UIView!
    
    var beerID: String?
    var flight: Int?
    var order: Int?
    var beerName: String?
    var brewery: String?
    var beerStyle: String?
    var abv: String?
    var ibu: String?
    var region: String?
    var rating = Double()
    let step = 0.25
    var ratings = [String: Double]()
    var reviews = [String: String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let savedRatings = defaults.object(forKey: "savedRatings") as? [String: Double] ?? [String: Double]()
        ratings = savedRatings
        //print("loaded rating = \(ratings[beerID!] ?? 0.00)")
        
        let savedReviews = defaults.object(forKey: "savedReviews") as? [String: String] ?? [String: String]()
        reviews = savedReviews
        //print("loaded review = \(reviews[beerID!] ?? "no review")")
        
        title = "\(beerID ?? "NA"): \(beerName ?? "NA") "
        flightLabel.text = flight.map(String.init) ?? "NA"
        orderLabel.text = order.map(String.init) ?? "NA"
        breweryLabel.text = brewery ?? "NA"
        beerStyleLabel.text = beerStyle ?? "NA"
        abvLabel.text = abv ?? "NA"
        ibuLabel.text = ibu ?? "NA"
        regionLabel.text = region ?? "NA"
        ratingLabel.text = String(Float(ratings[beerID!] ?? 0.00))
        ratingSlider.value = Float(ratings[beerID!] ?? 0.00)
        commentBox.text = reviews[beerID!] ?? ""
        
        commentBox.delegate = self // Setting delegate of your UITextField to self
//        initializeHideKeyboard()
        

    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//            commentBox.resignFirstResponder()
//        }
//
//
//        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//            textField.resignFirstResponder()
//            return true
//        }
//
//    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
//            NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
//        }
//
//        func unsubscribeFromAllNotifications() {
//            NotificationCenter.default.removeObserver(self)
//        }
//
//    func initializeHideKeyboard(){
//        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
//            target: self,
//            action: #selector(dismissMyKeyboard))
//
//        //Add this tap gesture recognizer to the parent view
//        view.addGestureRecognizer(tap)
//    }
//
//    @objc func dismissMyKeyboard(){
//        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
//        //In short- Dismiss the active keyboard.
//        view.endEditing(true)
//    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        
        let sliderStep = round(Double(ratingSlider.value) / step) * step
        rating = sliderStep
        ratingLabel.text = String(rating)
        save()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        save()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        print("I'm saving!")
//        save()
////        unsubscribeFromAllNotifications()
//    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        print("I'm saving!")
//        save()
////        unsubscribeFromAllNotifications()
//    }

    func save() {
        let defaults = UserDefaults.standard
        let comments = commentBox.text ?? ""
        
        if beerID != nil {
            ratings[beerID!] = rating
            reviews[beerID!] = comments
        }
        
        
        defaults.set(ratings, forKey: "savedRatings")
        defaults.set(reviews, forKey: "savedReviews")
        print ("savedRatings: \(ratings[beerID!]!)")
        print ("savedReviews: \(reviews[beerID!]!)")
    }
}
