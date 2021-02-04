//
//  ViewController.swift
//  ALL the Beers
//
//  Created by Jason Affourtit on 2/03/21.
//

import UIKit

class ViewController: UITableViewController {
    
    var beers = [Beer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBeers()
        //print ("cities==== \(cities)")
        title = "ALL the Beers! 🍻"
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Beer", for: indexPath)
        let theBeer = beers[indexPath.row]
        cell.textLabel?.text = "\(theBeer.beerID): \(theBeer.beerName)"
        return cell
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



