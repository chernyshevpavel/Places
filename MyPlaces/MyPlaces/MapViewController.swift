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
    let regionInMeters = 5_000.00
    var incomeSegueIdentifier = ""
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        setUpMapView()
        checkLocationServices()
    }
    
    @IBAction func closeMap(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonPressed() {
    }
    
    @IBAction func centerViewInUserLocation() {
        showUserLocation()
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkLocationAuthorization()
        } else {
            showAlertAsync(title: "Location services are disabled",
                           message: "To enable it go: Settings -> Privacy -> Location services and turn on",
                           deadline: .now() + 1)
        }
    }
    
    private func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setUpMapView() {
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            adressLabel.isHidden = true
            doneButton.isHidden = true
        }
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
            case .authorizedWhenInUse:
                map.showsUserLocation = true
                if incomeSegueIdentifier == "getAdress" { showUserLocation() }
                break
            case .denied:
                showAlertAsync(title: "Your Location is not awaileble",
                               message: "To give permission go to: Settings -> My Places -> Location",
                               deadline: .now() + 1)
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
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
    
    private func showAlertAsync(title: String, message: String, deadline: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            self?.showAlert(title: title, message: message)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertCtrl, animated: true)
    }
    
    private func showUserLocation() {
        if let locationCoordinate = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: locationCoordinate,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            map.setRegion(region, animated: true)
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
