//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 20.11.2020.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filtredPlaces: Results<Place>!
    private var isAscOrder = true
    private var isSearchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else {
            return false
        }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var orderBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.places = realm.objects(Place.self)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getPlacesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
        guard let placeCell = cell as? PlaceTVC else {
            return cell
        }
        let place = getPlace(by: indexPath)
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "Delete") {  [weak self] (contextualAction, view, boolValue)  in
            let storageManager = StorageManager()
            guard let place = self?.places[indexPath.row] else { return }
            storageManager.deletePlace(place)
            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    private func getPlacesCount() -> Int {
        if (isFiltering) {
            return filtredPlaces.isEmpty ? 0 : filtredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }
    
    private func getPlace(by indexPath: IndexPath) -> Place {
        if (isFiltering) {
            return filtredPlaces[indexPath.row]
        }
        return places[indexPath.row]
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "placeDetail" {
            guard let newPlaceTVC = segue.destination as? NewPlaceTVC,
                  let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let place = getPlace(by: indexPath)
            newPlaceTVC.currentPlace = place
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceTVC = segue.source as? NewPlaceTVC else {
            return
        }
        newPlaceTVC.savePlace()
        self.tableView.reloadData()
    }

    @IBAction func changeOrder(_ sender: UIBarButtonItem) {
        isAscOrder.toggle()
        if isAscOrder {
            orderBtn.image = #imageLiteral(resourceName: "AZ")
        } else {
            orderBtn.image = #imageLiteral(resourceName: "ZA")
        }
        sort()
    }
    
    @IBAction func changeSort(_ sender: Any) {
        sort()
    }
    
    private func sort() {
        if sortSegmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: isAscOrder)
        } else if sortSegmentedControl.selectedSegmentIndex == 1 {
            places = places.sorted(byKeyPath: "name", ascending: isAscOrder)
        }
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContentForSearchText(searchText)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filtredPlaces = places.filter(
            "name CONTAINS[c] %s OR location CONTAINS[c] %s OR type CONTAINS[c] %s",
            searchText, searchText, searchText)
        tableView.reloadData()
    }
}

