//
//  ViewController.swift
//  ALL the Beers
//
//  Created by Jason Affourtit on 2/03/21.
//

import UIKit

class ViewController: UITableViewController {
    
    var beers = [Beer]()
    var ratings = [String: Double]()
    var reviews = [String: String]()
    var badges = [String: Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBeers()
        title = "ALL the Beer! 🍻"
        
        let defaults = UserDefaults.standard
        let savedRatings = defaults.object(forKey: "savedRatings") as? [String: Double] ?? [String: Double]()
        ratings = savedRatings
        //print("loaded rating = \(ratings[beerID!] ?? 0.00)")
        
        let savedReviews = defaults.object(forKey: "savedReviews") as? [String: String] ?? [String: String]()
        reviews = savedReviews
        //print("loaded review = \(reviews[beerID!] ?? "no review")")
        
        let savedBadges = defaults.object(forKey: "savedBadges") as? [String: Bool] ?? [String: Bool]()
        badges = savedBadges
    }
    override func viewDidAppear(_ animated: Bool) {
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
        // cell.textLabel?.text = "\(theBeer.beerID): \(theBeer.beerName)"
        //print("\(ratings.keys)")
        
        
        if ratings.keys.contains(theBeer.beerID) {
            cell.accessoryType = .checkmark
        }
        else { cell.accessoryType = .none }
        return cell
    }
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        let subtitleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedString.Key.foregroundColor: UIColor.systemIndigo]

        let titleString = NSMutableAttributedString(string: "\(title):  ", attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)

        titleString.append(subtitleString)

        return titleString
    }
    
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
    
    func deleteReviews() {
        //        print("before:")
        //        print(ratings, reviews)
        
        ratings.removeAll()
        reviews.removeAll()
        badges.removeAll()
        save()
        //        print("after:")
        //        print(ratings, reviews)
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(ratings, forKey: "savedRatings")
        defaults.set(reviews, forKey: "savedReviews")
        defaults.set(badges, forKey: "savedBadges")
        //checkStats()
//        print ("savedRatings: \(ratings)")
//        print ("savedReviews: \(reviews)")
//        print ("savedBadges: \(badges)")
        self.tableView.reloadData()
        //self.navigationController?.popViewController(animated: true)
    }
    
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
        
        
        
        
        reportText[5] = "\n*Dealer's choice in case of a tie"
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Reports") as? ReportsViewController {
            //send over the variables
            vc.myReportText = reportText
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
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
        //print(beers)
    }
    
}
extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}



//
