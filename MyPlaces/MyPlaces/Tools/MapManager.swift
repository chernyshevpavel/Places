//
//  MapManager.swift
//  MyPlaces
//
//  Created by Павел Чернышев on 19.01.2021.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionInMeters = 1000.00
    private var directionsList: [MKDirections] = []
    
    
    public func setupPlacemark(place: Place, map: MKMapView) {
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
            annotation.title = place.name
            annotation.subtitle = place.type
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            map.showAnnotations([annotation], animated: true)
             map.selectAnnotation(annotation, animated: true)
        }
    }
    
    public func checkLocationServices(map: MKMapView, incomeSegueIdentifier : String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(map: map, incomeSegueIdentifier: incomeSegueIdentifier)
            closure()
        } else {
            showAlertAsync(title: "Location services are disabled",
                           message: "To enable it go: Settings -> Privacy -> Location services and turn on",
                           deadline: .now() + 1)
        }
    }
    
    public func checkLocationAuthorization(map: MKMapView, incomeSegueIdentifier: String) {
        switch locationManager.authorizationStatus {
            case .authorizedWhenInUse:
                map.showsUserLocation = true
                if incomeSegueIdentifier == "getAddress" { showUserLocation(map: map) }
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
    
    public func showUserLocation(map: MKMapView) {
        if let locationCoordinate = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: locationCoordinate,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            map.setRegion(region, animated: true)
        }
    }
    
    public func getDirections(for map: MKMapView, previousLocation: (CLLocation) -> (), routeClosure: @escaping (_ route: MKRoute) -> ())
    {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found");
            return;
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination location is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, map: map)
        
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
                map.addOverlay(route.polyline)
                map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                routeClosure(route)
            }
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
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
    
    public func startTrackingUserLocation(for map: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        guard let previousLocation = location else {
            return
        }
        let center = getCenterLocation(for: map)
        guard center.distance(from: previousLocation) > 50 else {
            return
        }
        closure(center)
    }
    
    // Сброс ранее построенных маршрутов перед построением нового маршрута
    private func resetMapView(withNew directions: MKDirections, map: MKMapView) {
        map.removeOverlays(map.overlays)
        directionsList.append(directions)
        let _ = directionsList.map { $0.cancel() }
        directionsList.removeAll()
    }
    
    // Определение центра отображаемой области карта
    public func getCenterLocation(for map: MKMapView) -> CLLocation {
        let latitude = map.centerCoordinate.latitude
        let longitude = map.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    
    private func showAlertAsync(title: String, message: String, deadline: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            self?.showAlert(title: title, message: message)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "Ok", style: .default))
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertCtrl, animated: true)
    }
}
