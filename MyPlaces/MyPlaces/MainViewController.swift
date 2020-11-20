//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 20.11.2020.
//

import UIKit

class MainViewController: UITableViewController {

    let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
        let restorantName = restaurantNames[indexPath.row]
        cell.textLabel?.text = restorantName
        cell.imageView?.image = UIImage(named: "Restaurants/\(restorantName).jpg")
        return cell
    }

    // MARK: - Navigation
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
