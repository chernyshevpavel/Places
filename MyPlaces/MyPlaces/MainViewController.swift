//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 20.11.2020.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {

    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.places = realm.objects(Place.self)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
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
        if let imageData = place.imageData {
            placeCell.imageOfPlace.image = UIImage(data: imageData)
        }
        placeCell.imageOfPlace.layer.cornerRadius =  placeCell.imageOfPlace.frame.size.height / 2
        placeCell.imageOfPlace.clipsToBounds = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    // MARK: - Navigation
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceTVC = segue.source as? NewPlaceTVC else {
            return
        }
        newPlaceTVC.savePlace()
        self.tableView.reloadData()
    }

}

