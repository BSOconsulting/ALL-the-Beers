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
    var badges = [String: Bool]()
    var beers: [Beer] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let savedRatings = defaults.object(forKey: "savedRatings") as? [String: Double] ?? [String: Double]()
        ratings = savedRatings
        //print("loaded rating = \(ratings[beerID!] ?? 0.00)")
        
        let savedReviews = defaults.object(forKey: "savedReviews") as? [String: String] ?? [String: String]()
        reviews = savedReviews
        //print("loaded review = \(reviews[beerID!] ?? "no review")")
        
        let savedBadges = defaults.object(forKey: "savedBadges") as? [String: Bool] ?? [String: Bool]()
        badges = savedBadges
        
        title = "\(beerID ?? "NA"): \(beerName ?? "NA") "
        flightLabel.text = flight.map(String.init) ?? "NA"
        orderLabel.text = order.map(String.init) ?? "NA"
        breweryLabel.text = brewery ?? "NA"
        beerStyleLabel.text = beerStyle ?? "NA"
        abvLabel.text = abv ?? "NA"
        ibuLabel.text = ibu ?? "NA"
        regionLabel.text = region ?? "NA"
        ratingLabel.text = String(Float(ratings[beerID!] ?? 0.0))
        ratingSlider.value = Float(ratings[beerID!] ?? 0.00)
        commentBox.text = reviews[beerID!] ?? ""
        
        commentBox.delegate = self // Setting delegate of your UITextField to self
        //reports()
    }
    
//    func reports() {
//        let favorite = ratings.values.max()
//        let keyBest = (ratings.filter { $0.value == favorite }).first?.key
//        let i = beers.firstIndex(where: { $0.beerID == keyBest }) ?? 0
//        let favoriteBeer = beers[i].beerName
//        print ("favorite: \(String(keyBest ?? "NA")) - \(favoriteBeer) - \(Double(favorite ?? 0.00))")
//
//        let worst = ratings.values.min()
//        let keyWorst = (ratings.filter { $0.value == worst }).first?.key
//        let j = beers.firstIndex(where: { $0.beerID == keyWorst }) ?? 0
//        let worstBeer = beers[j].beerName
//        print ("worst: \(String(keyWorst ?? "NA")) - \(worstBeer) - \(Double(worst ?? 0.00))")
        
        
//    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        
        let sliderStep = round(Double(ratingSlider.value) / step) * step
        rating = sliderStep
        ratingLabel.text = String(rating)
        ratings[beerID!] = rating
        save()
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        //Create the UIImage
        let renderer = UIGraphicsImageRenderer(size: view.frame.size)
        let image = renderer.image(actions: { context in
            view.layer.render(in: context.cgContext)
        })
        
        //Share the results
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        present(vc, animated: true)
    }
    
   
    @IBAction func trashTapped(_ sender: Any) {
    
        let ac = UIAlertController(title: "Delete all ratings?", message: "Type DELETE and hit OK to delete all ratings", preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let password = ac?.textFields?[0].text else { return }
            if password == "DELETE" {
                print("I am going to delete it all!")
                self?.deleteReviews()
                
            }
            else { print ("Nope.") }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func deleteReviews() {
        print("before:")
        print(ratings, reviews)
        ratingLabel.text = ""
        commentBox.text = ""
        
        ratings.removeAll()
        reviews.removeAll()
        badges.removeAll()
        save()
        print("after:")
        print(ratings, reviews)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("saving comments!")
        let comments = commentBox.text ?? ""
        reviews[beerID!] = comments
        save()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        checkStats()
        save()
    }
    
    func checkStats() {
        let numReviews = ratings.count
        print("you have \(numReviews) ratings")
        
        if numReviews == 10 && badges["10beers"] != true {
            let ac = UIAlertController(title: "BADGE: 😎", message: "Nice! You have 10 ratings!", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
            badges["10beers"] = true
            //save()
        }
        
        if numReviews == 25 && badges["25beers"] != true {
            let ac = UIAlertController(title: "BADGE: 🤪🤪", message: "Well done! You have 25 ratings!", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
            badges["25beers"] = true
            //save()
        }
        
        if numReviews == 50 && badges["50beers"] != true {
            let ac = UIAlertController(title: "BADGE: 😵😵😵", message: "Damn, yo! You have 50 ratings!", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
            badges["50beers"] = true
            //save()
        }
        
        if numReviews == 72 && badges["72beers"] != true {
            let ac = UIAlertController(title: "BADGE: ☠️☠️☠️☠️☠️", message: "WTF DAWG! You have rated all 72 beers!", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
            badges["72beers"] = true
            //save()
        }
        
        if rating == 5.0 && badges["perfect5"] != true {
            let ac = UIAlertController(title: "BADGE: 🤩", message: "You rated a beer a perfect 5.0!", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
            badges["perfect5"] = true
        }
        
        if rating < 1.0 && badges["stinker"] != true {
            let ac = UIAlertController(title: "BADGE: 🤮", message: "You rated a beer < 1.0. Yuck!", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
            badges["stinker"] = true
        }
         
    }
    
    func save() {
        let defaults = UserDefaults.standard
        //let comments = commentBox.text ?? ""
        
//        if beerID != nil {
//            ratings[beerID!] = rating
            //reviews[beerID!] = comments
//        }
        
        defaults.set(ratings, forKey: "savedRatings")
        defaults.set(reviews, forKey: "savedReviews")
        defaults.set(badges, forKey: "savedBadges")
        //checkStats()
        print ("savedRatings: \(ratings)")
        print ("savedReviews: \(reviews)")
        print ("savedBadges: \(badges)")
        
    }
}
