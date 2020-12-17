//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 13.12.2020.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    let place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        checkLocationServices()
        setupPlacemark()
    }
    
    @IBAction func closeMap(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkLocationAuthorization()
        } else {
            //MARK: show alert
        }
    }
    
    private func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
            case .authorizedWhenInUse:
                map.showsUserLocation = true
                break
            case .denied:
                //MARK: show alert
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                //MARK: show alert
                break
            case .authorizedAlways:
                break
            @unknown default:
                print("Availible new location status")
                break
        }
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

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = map.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
}
