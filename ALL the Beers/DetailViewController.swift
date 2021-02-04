//
//  DetailViewController.swift
//  ALL the Beers
//
//  Created by Jason Affourtit on 2/03/21.
//

import UIKit

class DetailViewController: UIViewController {
    
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
    var ratings = [Rating]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let savedResults = defaults.object(forKey: "savedResults") as? [Rating] ?? [Rating]()
        ratings = savedResults
        print("loaded ratings = \(ratings)")
    
        title = "\(beerID ?? "NA"): \(beerName ?? "NA") "
        flightLabel.text = flight.map(String.init) ?? "NA"
        orderLabel.text = order.map(String.init) ?? "NA"
        breweryLabel.text = brewery ?? "NA"
        beerStyleLabel.text = beerStyle ?? "NA"
        abvLabel.text = abv ?? "NA"
        ibuLabel.text = ibu ?? "NA"
        regionLabel.text = region ?? "NA"
        ratingLabel.text = String(rating)
        ratingSlider.value = 0.00

    }
    @IBAction func sliderChanged(_ sender: Any) {
        
        let sliderStep = round(Double(ratingSlider.value) / step) * step
        rating = sliderStep
        ratingLabel.text = String(rating)
        save()
    }
    
    func save() {
        let defaults = UserDefaults.standard
        let comments = commentBox.text ?? ""
        
        if let index = ratings.firstIndex(where: { $0.beerID == beerID }) {
            ratings[index].rating = rating
            ratings[index].review = commentBox.text
            print("edited rating = \(ratings[index])")
        }
        else {
            let myRating = Rating(beerID: beerID ?? "NA", rating: rating, review: comments)
            ratings.append(myRating)
            print("new save. myRating = \(myRating)")
        }
        defaults.set(ratings, forKey: "savedResults")
    }
}
