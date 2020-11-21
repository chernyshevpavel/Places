//
//  Place.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 21.11.2020.
//

import Foundation

struct Place {
    let name: String
    let location: String
    let type: String
    let image: String
    
    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    static func getPlaces() -> [Place] {
        var places: [Place] = []
        for placeName in restaurantNames {
            places.append(Place(name: placeName, location: "St-Petersburg", type: "Restaurant", image: "Restaurants/\(placeName).jpg"))
        }
        return places
    }
}
