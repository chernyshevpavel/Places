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

    let place = Place()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 5_000.00
    var incomeSegueIdentifier = ""
    var placeCoordinate: CLLocationCoordinate2D?
    
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
        checkLocationServices()
    }
    
    @IBAction func closeMap(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func centerViewInUserLocation() {
        showUserLocation()
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        getDirections()
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
        goButton.isHidden = true
        distanceLabel.isHidden = true
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
            case .authorizedWhenInUse:
                map.showsUserLocation = true
                if incomeSegueIdentifier == "getAddress" { showUserLocation() }
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
            self.placeCoordinate = placemarkLocation.coordinate
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
    
    private func getCenterLocation(for map: MKMapView) -> CLLocation {
        let latitude = map.centerCoordinate.latitude
        let longitude = map.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let centerLocation = getCenterLocation(for: map)
        let geocoder = CLGeocoder()
        
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
    
    private func getDirections()
    {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found");
            return;
        }
        
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination location is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [weak self] (responce, error) in
            guard let self = self else { return }
            if let error = error {
                print(error)
                return
            }
            
            guard let responce = responce else {
                self.showAlert(title: "Error", message: "Directions is not awailable")
                return
            }
            
            for route in responce.routes {
                self.map.addOverlay(route.polyline)
                self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = Int(route.expectedTravelTime / 60)
                
                self.distanceLabel.text = "\(distance) km / \(timeInterval) min"
                self.distanceLabel.isHidden = false
            }
        }
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else {
            return nil
        }
        
        let startPlacemark = MKPlacemark(coordinate: coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startPlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline )
        renderer.strokeColor = .blue
        return renderer
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
