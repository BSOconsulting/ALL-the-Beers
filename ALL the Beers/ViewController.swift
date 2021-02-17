//
//  ViewController.swift
//  ALL the Beers
//
//  Created by Jason Affourtit on 2/03/21.
//  Not for distribution
//
// Main ViewController for the app. This displays the list of beers to be / rated, where
// the checkmark is used to indicate those already entered. The title displays the current tally.
// There is a function to delete all in the database and another to show some basic stats via a report

import UIKit

class ViewController: UITableViewController {
    
    var beers = [Beer]() // struct that contains the loaded CSV file
    
    // ratings are the numerical, reviews the text. These shouldn't be separate arrays, silly.
    var ratings = [String: Double]() {
        // when we have new ratings, update the counter at the top of the screen
        didSet {
            title = "Ratings: [\(ratings.count) / 72] 🍻"
        }
    }
    var reviews = [String: String]()
    // another separate array, this time to store the badges earned
    var badges = [String: Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call loadBeers to import the CSV data from my original spreadsheet
        loadBeers()
        
        // load the saved ratings, results, and badges
        let defaults = UserDefaults.standard
        let savedRatings = defaults.object(forKey: "savedRatings") as? [String: Double] ?? [String: Double]()
        ratings = savedRatings
        //print("loaded rating = \(ratings[beerID!] ?? 0.00)")
        
        let savedReviews = defaults.object(forKey: "savedReviews") as? [String: String] ?? [String: String]()
        reviews = savedReviews
        //print("loaded review = \(reviews[beerID!] ?? "no review")")
        
        let savedBadges = defaults.object(forKey: "savedBadges") as? [String: Bool] ?? [String: Bool]()
        badges = savedBadges
        
        //title = "Ratings: [\(ratings.count) / 72] 🍻"
    }
    override func viewDidAppear(_ animated: Bool) {
        // reload the tableView after edits to update the checkmarks and menu bar counter
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaults = UserDefaults.standard
        let savedRatings = defaults.object(forKey: "savedRatings") as? [String: Double] ?? [String: Double]()
        ratings = savedRatings
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Beer", for: indexPath)
        let theBeer = beers[indexPath.row]
        cell.textLabel?.attributedText = makeAttributedString(title: "\(theBeer.beerID)", subtitle: "\(theBeer.beerName)")
        
        // use checkmarks to indicate that a beer has been rated
        if ratings.keys.contains(theBeer.beerID) {
            cell.accessoryType = .checkmark
        }
        else { cell.accessoryType = .none }
        return cell
    }
    
    // AttributedString formatting function found online. This will be used several places
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        let subtitleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedString.Key.foregroundColor: UIColor.systemIndigo]
        
        let titleString = NSMutableAttributedString(string: "\(title):  ", attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
        
        titleString.append(subtitleString)
        
        return titleString
    }
    
    // These are the variables we need to make available to the DetailViewController used for beer rating/review
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            //send over the variables
            vc.beerID = beers[indexPath.row].beerID
            vc.flight = beers[indexPath.row].flight
            vc.order = beers[indexPath.row].order
            vc.beerName = beers[indexPath.row].beerName
            vc.brewery = beers[indexPath.row].brewery
            vc.beerStyle = beers[indexPath.row].beerStyle
            vc.abv = beers[indexPath.row].abv
            vc.ibu = beers[indexPath.row].ibu
            vc.region = beers[indexPath.row].region
            vc.beers = beers
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // Calls function to allow deleting the entire database of ratings. Confirmation message to make certain!
    @IBAction func deleteTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Delete all ratings?", message: "Type DELETE and hit OK to delete all ratings", preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let password = ac?.textFields?[0].text else { return }
            if password == "DELETE" {
                //print("I am going to delete it all!")
                self?.deleteReviews()
            }
            else { print ("Nope.") }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    // function to allow deleting the entire database of ratings.
    func deleteReviews() {
        
        ratings.removeAll()
        reviews.removeAll()
        badges.removeAll()
        save()
    }
    
    // save function to update our saved objects in UserDefaults
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(ratings, forKey: "savedRatings")
        defaults.set(reviews, forKey: "savedReviews")
        defaults.set(badges, forKey: "savedBadges")

        self.tableView.reloadData()
        //self.navigationController?.popViewController(animated: true)
    
    }
    
    // function to call up the Reports page after populating the variables needed
    @IBAction func reportsTapped(_ sender: Any) {
        let defaults = UserDefaults.standard
        let savedRatings = defaults.object(forKey: "savedRatings") as? [String: Double] ?? [String: Double]()
        ratings = savedRatings
        //print("loaded rating = \(ratings[beerID!] ?? 0.00)")
        
        let savedReviews = defaults.object(forKey: "savedReviews") as? [String: String] ?? [String: String]()
        reviews = savedReviews
        //print("loaded review = \(reviews[beerID!] ?? "no review")")
        
        let savedBadges = defaults.object(forKey: "savedBadges") as? [String: Bool] ?? [String: Bool]()
        badges = savedBadges
        
        var reportText = [Int: String]()
        var sumRatings = 0.0
        for value in ratings.values {
            sumRatings += value
        }
        let numRatings = ratings.values.count
        
        if numRatings == 0 {
            let ac = UIAlertController(title: "Error", message: "Reports are not available if \nyou haven't rated any beers!", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
            return
        }
        // below are the calculations for the report
        let avgRatings = (sumRatings / Double(numRatings)).truncate(places:2)    
        let beersRated = ("You have rated \(ratings.keys.count) of 72 beers! [Avg: \(avgRatings)]")
        //        print(beersRated)
        reportText[1] = beersRated
        
        let favorite = ratings.values.max()
        let keyBest = (ratings.filter { $0.value == favorite }).first?.key
        let i = beers.firstIndex(where: { $0.beerID == keyBest }) ?? 0
        let favoriteBeer = beers[i].beerName
        let favoriteBrewery = beers[i].brewery
        let myFavoriteBeer = ("Best rating:    \(Double(favorite ?? 0.00))\n [\(String(keyBest ?? "NA"))] \(favoriteBeer) - \(favoriteBrewery)")
        //        print (myFavoriteBeer)
        reportText[2] = myFavoriteBeer
        
        let worst = ratings.values.min()
        let keyWorst = (ratings.filter { $0.value == worst }).first?.key
        let j = beers.firstIndex(where: { $0.beerID == keyWorst }) ?? 0
        let worstBeer = beers[j].beerName
        let worstBrewery = beers[j].brewery
        let myWorstBeer = ("Worst rating: \(Double(worst ?? 0.00))\n [\(String(keyWorst ?? "NA"))] \(worstBeer) - \(worstBrewery)")
        //        print (myWorstBeer)
        reportText[3] = myWorstBeer
        
        let myBadges = ("You have earned \(badges.keys.count) of 17 badges!")
        //        print (myBadges)
        reportText[4] = myBadges
        
        // message to let them know I'm not dealing with ties; unordered array
        reportText[5] = "\n*Dealer's choice in case of a tie"
        
        // launch the ReportsViewController
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Reports") as? ReportsViewController {
            //send over the variables
            vc.myReportText = reportText
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // function to parse the CSV and create the objects needed; heavily based off online code
    func loadBeers() {
        guard let filepath = Bundle.main.path(forResource: "allTheBeer", ofType: "csv") else {
            return
        }
        
        var data = ""
        do {
            data = try String(contentsOfFile: filepath)
        } catch {
            print(error)
            return
        }
        
        //now split that string into an array of "rows" of data.  Each row is a string.
        var rows = data.components(separatedBy: "\n")
        
        //now loop around each row, and split it into each of its columns
        for row in rows {
            let columns = row.components(separatedBy: ",")
            //print("columns==== \(columns)")
            //check that we have enough columns
            if columns.count == 9 {
                let beerID = columns[0]
                let flight = Int(columns[1]) ?? 0
                let order = Int(columns[2]) ?? 0
                let beerName = columns[3]
                let brewery = columns[4]
                let beerStyle = columns[5]
                let abv = columns[6]
                let ibu = columns[7]
                let region = columns[8]
                
                let thisBeer = Beer(beerID: beerID, flight: flight, order: order, beerName: beerName, brewery: brewery, beerStyle: beerStyle, abv: abv, ibu: ibu, region: region)
                
                beers.append(thisBeer)
            }
        }
    }
}

// Extension to enable clean truncation to desired # of digits
extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}



//
