//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 20.11.2020.
//

import UIKit

class MainViewController: UITableViewController {

    let places = Place.getPlaces()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
        guard let placeCell = cell as? PlaceTVC else {
            return cell
        }
        let place = places[indexPath.row]
        placeCell.placeLabel.text = place.name
        placeCell.locationLabel.text = place.location
        placeCell.typeLabel.text = place.type
        placeCell.imageOfPlace.image = UIImage(named: place.image)
        placeCell.imageOfPlace.layer.cornerRadius =  placeCell.imageOfPlace.frame.size.height / 2
        placeCell.imageOfPlace.clipsToBounds = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    // MARK: - Navigation
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func cancel(_ segue: UIStoryboardSegue, sender: Any?) {}

}
