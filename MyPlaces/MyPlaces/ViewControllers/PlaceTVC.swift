//
//  RestaurantTVC.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 21.11.2020.
//

import UIKit

class PlaceTVC: UITableViewCell {

    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius =  imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var placeLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var ratingControl: RatingControl!
}
