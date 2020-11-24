//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 23.11.2020.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    func savePlace(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    func deletePlace(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
