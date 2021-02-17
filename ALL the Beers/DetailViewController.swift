//
//  DetailViewController.swift
//  ALL the Beers
//
//  Created by Jason Affourtit on 2/03/21.
//
//  this VC is the main interface for rating each beer as well as for sharing the same and doing bulk data export

import UIKit
import AVFoundation

class DetailViewController: UIViewController, UITextViewDelegate {
    
    // all the many IBOutlets for the labels and other UI elements
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
    
    // global variables; probably too many but definitely got lazy
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
    // step allows for the UISlider to use 0.25 increments
    let step = 0.25
    var ratings = [String: Double]()
    var reviews = [String: String]()
    var badges = [String: Bool]()
    var beers: [Beer] = []
    var alert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the saved ratings/reviews/badges
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
    
    
    // rating Slider code; uses a 0.25 step to increment
    @IBAction func sliderChanged(_ sender: Any) {
        
        let sliderStep = round(Double(ratingSlider.value) / step) * step
        rating = sliderStep
        ratingLabel.text = String(rating)
        ratings[beerID!] = rating
        //save()
    }
    
    // function to allow for sharing of a given beer's rating page
    @IBAction func shareTapped(_ sender: Any) {
        //Create the UIImage - this way didn't capture the title (beer name)
        //        let renderer = UIGraphicsImageRenderer(size: view.frame.size)
        //        let image = renderer.image(actions: { context in
        //            view.layer.render(in: context.cgContext)
        //        })
        
        var image :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return}
        layer.render(in:context)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Share the results
        let vc = UIActivityViewController(activityItems: [image!], applicationActivities: [])
        present(vc, animated: true)
    }
    
    // allows for saving of the text field in case the user accidentally navigates away
    // this probably isn't the cleanest but the app is so lightweight it seemed OK
    func textViewDidChange(_ textView: UITextView) {
        //print("saving comments!")
        let comments = commentBox.text ?? ""
        reviews[beerID!] = comments
        save()
    }
    
    // calls the function to save a given review; checks to ensure the beer has been rated first
    @IBAction func saveTapped(_ sender: Any) {
        if ratingLabel.text == "" {
            let ac = UIAlertController(title: "Error", message: "You haven't rated this beer.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
            return
        }

        // calls the function to see if any badges were earned, saves the results, and notifies the user
        checkBadges()
        save()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        notifyUser()
    }
    
    // clean up everything in case the user wants to delete an individual beer rating
    @IBAction func deleteTapped(_ sender: Any) {
        ratingLabel.text = ""
        commentBox.text = ""
        ratingSlider.value = 0.0
        
        print ("before Ratings: \(ratings)")
        print ("before Reviews: \(reviews)")
        
        if ratings.keys.contains(beerID!) {
            ratings.removeValue(forKey: beerID!)
        }
        
        if reviews.keys.contains(beerID!) {
            reviews.removeValue(forKey: beerID!)
        }
        
        save()
        vibrateTwice()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // this function should be renamed as I changed to a haptic alert
    func vibrateTwice() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.impactOccurred()
    }
    
    // a function I found in efforts to avoid alerts that don't auto-dismiss. I don't think it's working
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController

        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }

        return topMostViewController
    }
    
    // if a badge has been earned, pass the information to the BadgeViewController and launch it
    func displayBadge(label: String, name: String) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Badge") as? BadgeViewController {
            //send over the variables
            vc.label = label
            vc.imageName = name
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // check if the user has earned any badges
    func checkStyleBadges(style: [String]) -> Bool {
        var yes = 0
        for i in 0...(style.count - 1) {
            if ratings.keys.contains(style[i]) {
                yes += 1
            }
        }
        if yes == style.count {
            return true
        }
        return false
    }
    
    // this section contains all the logic for currently employed badges
    // it is out of place in this file and should be separated out from it
    func checkBadges() {
        let numReviews = ratings.count
        //print("you have \(numReviews) ratings")
        
        let hazyIPA = ["1-05", "1-06", "1-07", "1-08", "2-07", "2-08", "2-09", "2-10", "3-05", "3-06", "3-07", "4-06", "4-07", "4-08"]
        
        let IPA = ["1-09", "1-10", "1-11", "1-12", "1-13", "1-14", "2-11", "2-12", "2-13", "2-14", "2-15", "3-08", "3-09", "3-10", "3-11", "3-12", "3-13", "3-14", "4-09", "4-10", "4-11", "4-12", "4-13", "4-14", "4-15"]
        
        let strong = ["2-17", "3-17", "4-17", "4-18"]
        
        let light = ["1-01", "1-05", "2-01", "2-02", "2-05", "3-01", "3-02", "4-01"]
        
        let flight1 = ["1-01", "1-02", "1-03", "1-04", "1-05", "1-06", "1-07", "1-08", "1-09", "1-10", "1-11", "1-12", "1-13", "1-14", "1-15", "1-16", "1-17", "1-18"]
        
        let flight2 = ["2-01", "2-02", "2-03", "2-04", "2-05", "2-06", "2-07", "2-08", "2-09", "2-10", "2-11", "2-12", "2-13", "2-14", "2-15", "2-16", "2-17", "2-18"]
        
        let flight3 = ["3-01", "3-02", "3-03", "3-04", "3-05", "3-06", "3-07", "3-08", "3-09", "3-10", "3-11", "3-12", "3-13", "3-14", "3-15", "3-16", "3-17", "3-18"]
        
        let flight4 = ["4-01", "4-02", "4-03", "4-04", "4-05", "4-06", "4-07", "4-08", "4-09", "4-10", "4-11", "4-12", "4-13", "4-14", "4-15", "4-16", "4-17", "4-18"]
        
        
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
            let badgeLabel = "You wrote five comments!\nTURKEY TIME!!! 🦃"
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
            
            let badgeLabel = "You've rated 10 beers.\nYOUR MOVE."
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
    }
    
    // function to save the results
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(ratings, forKey: "savedRatings")
        defaults.set(reviews, forKey: "savedReviews")
        defaults.set(badges, forKey: "savedBadges")
        //checkStats()
//        print ("savedRatings: \(ratings)")
//        print ("savedReviews: \(reviews)")
//        print ("savedBadges: \(badges)")
        //self.navigationController?.popViewController(animated: true)
    }
    
    // function to bulk export the ratings. This is a bit of a kludge
    // and was added in solely as a user request. Would rewrite and place elsewhere
    // in an actual release of this or a related app
    @IBAction func exportTapped(_ sender: Any) {
        
        var output = String()
        
        let sortRatings = ratings.sorted(by: <)

        for (key, value) in sortRatings {
            let i = beers.firstIndex(where: { $0.beerID == key }) ?? 0
            let myBeer = beers[i].beerName
            let myBrewery = beers[i].brewery

            output += ("\(key): \(myBeer) (\(myBrewery)) - \(value): \(reviews[key] ?? "")\n")
        
        }
        var myOutput = [output]
        let vc = UIActivityViewController(activityItems: myOutput.sorted(), applicationActivities: [])
        present(vc, animated: true)
    }
    
    // notify the user that the input was saved
    func notifyUser()
    {
        
        let alert = UIAlertController(title: "", message: "Saved!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))

        DispatchQueue.main.async {
            self.getTopMostViewController()?.present(alert, animated: true, completion: nil)
        }
        
        // this function is intended to auto-dismiss the alert. It works ~90% of the time, and in the remainder,
        // the alert persists. I suspect a race condition but do not intend to address in this test release.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            alert.dismiss(animated: true, completion: nil)
            //adding function call below as we seem to have a race condition where alert doesn't always auto-dismiss...
            self.dismissAnyAlertControllerIfPresent()
        }
    }
    
    // per above, this attempts to ensure the alert is dismissed. Not working as intended
    func dismissAnyAlertControllerIfPresent() {
        guard let window :UIWindow = UIApplication.shared.keyWindow , var topVC = window.rootViewController?.presentedViewController else {return}
        while topVC.presentedViewController != nil  {
            topVC = topVC.presentedViewController!
        }
        if topVC.isKind(of: UIAlertController.self) {
            topVC.dismiss(animated: false, completion: nil)
        }
    }
    
}

