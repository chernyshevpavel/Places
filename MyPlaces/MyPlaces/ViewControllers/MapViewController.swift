//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 13.12.2020.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {

    let mapManager = MapManager()
    let place = Place()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifier = ""
    private var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(
                for: map,
                and: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    guard let self = self else { return }
                    self.mapManager.showUserLocation(map: self.map)
                }
            }
        }
    }
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        map.delegate = self
        setUpMapView()
    }
    
    @IBAction func closeMap(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(map: map)
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        mapManager.getDirections(for: map,
        previousLocation: { (location) in
            self.previousLocation = location
        }, routeClosure: { [weak self] (route) in
            guard let self = self else { return }
            let distance = String(format: "%.1f", route.distance / 1000)
            let timeInterval = Int(route.expectedTravelTime / 60)
            self.distanceLabel.text = "\(distance) km / \(timeInterval) min"
            self.distanceLabel.isHidden = false
        })

    }

    
    private func setUpLocationManager() {
        mapManager.locationManager.delegate = self
        mapManager.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setUpMapView() {
        goButton.isHidden = true
        distanceLabel.isHidden = true
        
        mapManager.checkLocationServices(map: map, incomeSegueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, map: map)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let centerLocation = mapManager.getCenterLocation(for: map)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [weak self] in
                guard let self = self else { return }
                self.mapManager.showUserLocation(map: self.map)
            })
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(centerLocation) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let street = placemark?.thoroughfare
            let build = placemark?.subThoroughfare
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if street != nil && build != nil {
                    self.addressLabel.text = "\(street!), \(build!)"
                } else if street != nil {
                    self.addressLabel.text = "\(street!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline )
        renderer.strokeColor = .blue
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAuthorization(map: map, incomeSegueIdentifier: incomeSegueIdentifier)
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
