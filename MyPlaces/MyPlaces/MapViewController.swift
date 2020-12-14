//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 13.12.2020.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var place: Place!
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlacemark()
    }
    
    @IBAction func closeMap(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func setupPlacemark() {
        guard let location = place.location else {
            return
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            guard let placemarkLocation = placemark?.location else { return }
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            annotation.coordinate = placemarkLocation.coordinate
            self.map.showAnnotations([annotation], animated: true)
            self.map.selectAnnotation(annotation, animated: true)
        }
    }
}
