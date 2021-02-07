//
//  DetailViewController.swift
//  ALL the Beers
//
//  Created by Jason Affourtit on 2/03/21.
//

import UIKit
import AVFoundation

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
        // Handle the case where there is no saved rating for the beer
        if ratingLabel.text == "0.0" {
            ratingLabel.text = ""
        }
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
        ratingSlider.value = 0.0
        
        ratings.removeAll()
        reviews.removeAll()
        badges.removeAll()
        save()
        print("after:")
        print(ratings, reviews)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //print("saving comments!")
        let comments = commentBox.text ?? ""
        reviews[beerID!] = comments
        save()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        if ratingLabel.text == "" {
            let ac = UIAlertController(title: "Error", message: "You haven't rated this beer.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
            return
        }
        checkBadges()
        save()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func displayBadge(label: String, name: String) {

            if let vc = storyboard?.instantiateViewController(withIdentifier: "Badge") as? BadgeViewController {
                //send over the variables
                vc.label = label
                vc.imageName = name
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    
    func checkStyleBadges(style: [String]) -> Bool {

            var yes = 0
            for i in 0...(style.count - 1) {
                if ratings.keys.contains(style[i]) {
                    yes += 1
                }
                //else { print ("\(style[i]): no"); return false }
            }
            if yes == style.count {
                //print("\(yes): you get a badge!")
                return true
            }
        return false
    }
    
    
    func checkBadges() {
        let numReviews = ratings.count
        print("you have \(numReviews) ratings")
        
        let hazyIPA = ["1-5", "1-6", "1-7", "1-8", "2-7", "2-8", "2-9", "2-10", "3-5", "3-6", "3-7", "4-6", "4-7", "4-8"]
        
        let IPA = ["1-9", "1-10", "1-11", "1-12", "1-13", "1-14", "2-11", "2-12", "2-13", "2-14", "2-15", "3-8", "3-9", "3-10", "3-11", "3-12", "3-13", "3-14", "4-9", "4-10", "4-11", "4-12", "4-13", "4-14", "4-15"]
        
        let strong = ["2-17", "3-17", "4-17", "4-18"]
        
        let light = ["1-1", "1-5", "2-1", "2-2", "2-5", "3-1", "3-2", "4-1"]
        
        let flight1 = ["1-1", "1-2", "1-3", "1-4", "1-5", "1-6", "1-7", "1-8", "1-9", "1-10", "1-11", "1-12", "1-13", "1-14", "1-15", "1-16", "1-17", "1-18"]
        
        let flight2 = ["2-1", "2-2", "2-3", "2-4", "2-5", "2-6", "2-7", "2-8", "2-9", "2-10", "2-11", "2-12", "2-13", "2-14", "2-15", "2-16", "2-17", "2-18"]
        
        let flight3 = ["3-1", "3-2", "3-3", "3-4", "3-5", "3-6", "3-7", "3-8", "3-9", "3-10", "3-11", "3-12", "3-13", "3-14", "3-15", "3-16", "3-17", "3-18"]
        
        let flight4 = ["4-1", "4-2", "4-3", "4-4", "4-5", "4-6", "4-7", "4-8", "4-9", "4-10", "4-11", "4-12", "4-13", "4-14", "4-15", "4-16", "4-17", "4-18"]

        
        if hazyIPA.contains(beerID!) && badges["hazy"] != true {
            let earnedBadge = checkStyleBadges(style: hazyIPA)
            if earnedBadge == true {
                let badgeLabel = "ALL the Hazy IPAs rated!\nSUCH a hipster 🧔🏻"
                let imageName = "hazy.jpg"
                badges["hazy"] = true
                displayBadge(label: badgeLabel, name: imageName)
            }
        }
        
        if IPA.contains(beerID!) && badges["IPA"] != true {
            let earnedBadge = checkStyleBadges(style: IPA)
            if earnedBadge == true {
                let badgeLabel = "ALL the single IPAs rated!\nHip HOP Hooray!"
                let imageName = "IPA.jpg"
                badges["IPA"] = true
                displayBadge(label: badgeLabel, name: imageName)
            }
        }
        
        if light.contains(beerID!) && badges["light"] != true {
            let earnedBadge = checkStyleBadges(style: light)
            if earnedBadge == true {
                let badgeLabel = "All ≦5% ABV beers rated!\nThere's only BOOZE now"
                let imageName = "light.jpg"
                badges["light"] = true
                displayBadge(label: badgeLabel, name: imageName)
            }
        }
        
        if strong.contains(beerID!) && badges["strong"] != true {
            let badgeLabel = "You rated a beer >9% ABV!\nBOOZE all day! 🥃"
            let imageName = "strong.jpg"
            badges["strong"] = true
            displayBadge(label: badgeLabel, name: imageName)
        }
        
        if beerID! == "1-16" && badges["belgian"] != true {
            let badgeLabel = "You drank a Belgian beer! 🇧🇪\nWTF it's the only one?"
            let imageName = "belgian.jpg"
            badges["belgian"] = true
            displayBadge(label: badgeLabel, name: imageName)
        }
        
        if rating == 5.0 && badges["perfect5"] != true {
            let badgeLabel = "You rated a beer 5.0!\nThat IS a tasty beverage!"
            let imageName = "perfect5.jpeg"
            badges["perfect5"] = true
            displayBadge(label: badgeLabel, name: imageName)
            //return
        }
        
        if rating == 2.5 && badges["twopointfive"] != true {
            let badgeLabel = "You rated a beer 2.5.\nNot great, not terrible..."
            let imageName = "twopointfive.jpg"
            badges["twopointfive"] = true
            displayBadge(label: badgeLabel, name: imageName)
            //return
        }
        
        if reviews.keys.count == 5 && badges["fivereviews"] != true {
            let badgeLabel = "You wrote five comments!\nYour effort is impressive."
            let imageName = "fivereviews.jpg"
            badges["fivereviews"] = true
            displayBadge(label: badgeLabel, name: imageName)
            //return
        }
        
        if (rating > 0.0 && rating < 1.0) && badges["stinker"] != true {
            let badgeLabel = "You rated a beer < 1.0!\nYeah, that's nasty!"
            let imageName = "nasty.jpeg"
            badges["stinker"] = true
            displayBadge(label: badgeLabel, name: imageName)
            //return
        }
        
        if flight1.contains(beerID!) && badges["flight1"] != true {
            let earnedBadge = checkStyleBadges(style: flight1)
            if earnedBadge == true {
                let badgeLabel = "ALL of Flight 1 rated!\nOnly 75% more to go..."
                let imageName = "flight1.jpeg"
                badges["flight1"] = true
                displayBadge(label: badgeLabel, name: imageName)
            }
        }
        
        if flight2.contains(beerID!) && badges["flight2"] != true {
            let earnedBadge = checkStyleBadges(style: flight2)
            if earnedBadge == true {
                let badgeLabel = "ALL of Flight 2 rated!\n50% down, 50% to go..."
                let imageName = "flight2.jpeg"
                badges["flight2"] = true
                displayBadge(label: badgeLabel, name: imageName)
            }
        }
        
        if flight3.contains(beerID!) && badges["flight3"] != true {
            let earnedBadge = checkStyleBadges(style: flight3)
            if earnedBadge == true {
                let badgeLabel = "ALL of Flight 3 rated!\nSo close and yet so far."
                let imageName = "flight3.jpg"
                badges["flight3"] = true
                displayBadge(label: badgeLabel, name: imageName)
            }
        }
        
        if flight4.contains(beerID!) && badges["flight4"] != true {
            let earnedBadge = checkStyleBadges(style: flight4)
            if earnedBadge == true {
                let badgeLabel = "ALL of Flight 4 rated!\nBAM! Got 'er done."
                let imageName = "flight4.jpeg"
                badges["flight4"] = true
                displayBadge(label: badgeLabel, name: imageName)
            }
        }
        
        if numReviews == 10 && badges["10beers"] != true {

            let badgeLabel = "You've rated 10 beers.\nUmmm...a decent start."
            let imageName = "10beers.png"
            badges["10beers"] = true
            displayBadge(label: badgeLabel, name: imageName)
            //return
        }
        
        if numReviews == 25 && badges["25beers"] != true {

            let badgeLabel = "You've rated 25 beers.\nI like where this is headed!"
            let imageName = "25beers.png"
            badges["25beers"] = true
            displayBadge(label: badgeLabel, name: imageName)
            //return
        }
        
        if numReviews == 50 && badges["50beers"] != true {

            let badgeLabel = "You've rated 50 beers!\nYou ain't messing around!"
            let imageName = "50beers.jpg"
            badges["50beers"] = true
            displayBadge(label: badgeLabel, name: imageName)
            //return
        }
        
        if numReviews == 72 && badges["72beers"] != true {

            let badgeLabel = "You've rated all 72 beers!\nWILDCARD!!! ☠️☠️☠️"
            let imageName = "72beers.jpg"
            badges["72beers"] = true
            displayBadge(label: badgeLabel, name: imageName)
            //return
        }
        
        
        
//        else {
//            self.navigationController?.popViewController(animated: true)
//        }
         
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
        //print ("savedRatings: \(ratings)")
        //print ("savedReviews: \(reviews)")
        //print ("savedBadges: \(badges)")
        //self.navigationController?.popViewController(animated: true)
    }
}

