//
//  RouteViewController.swift
//  MakeFoodie
//
//  Created by Chen Kang Ning on 2/8/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RouteViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var lm : CLLocationManager?
    
    // Store destination data
    var destLat: Double?
    var destLng: Double?
    var destName: String?
    var destAddr: String?
    
    // Store user location
    var userLoc:CLLocation?
    var userLocMapItem: MKMapItem?
    var destLocMapItem: MKMapItem?
    
    // For getting directions
    var directionRequest = MKDirections.Request()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        lm = CLLocationManager()
        lm?.delegate = self
        lm?.desiredAccuracy = kCLLocationAccuracyBest   // Best accuracy
        lm?.distanceFilter = 0
        lm?.requestWhenInUseAuthorization() // Location permission
        lm?.startUpdatingLocation()
        
        // Set starting transport type as walking
        directionRequest.transportType = .walking
        
        // Background to foreground check if permission changed
        NotificationCenter.default.addObserver(self, selector: #selector(changeSettingsPermission(notfication:)), name: NSNotification.Name(rawValue: "changeLocAuth"), object: nil)
    }
    
    // Check after changing permissions from settings
    @objc func changeSettingsPermission(notfication: NSNotification) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            lm?.startUpdatingLocation()
        case .denied, .restricted:
            permissionNotAllowed()
        case .notDetermined:
            lm?.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    // When user location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        
        // Set region
        let region = MKCoordinateRegion( center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        if destLat != nil && destLng != nil {
            let destCoords:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: destLat!, longitude: destLng!)
            getDirections(userCoordinate: location.coordinate, destCoordinate: destCoords)
            userLoc = location
        }
    }
    
    /* Runs if user doesnt allow location permission
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Create alertcontroller to tell user to enable permission
        let alertController = UIAlertController(title: "User location not found!", message: "Please go to Settings and enable permissions", preferredStyle: .alert)
        
        // Bring user to settings for location
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
             }
        }
        
        // If cancel go to prev controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
            (action:UIAlertAction!) in
            
            self.navigationController?.popViewController(animated: true)
        }
        
        // Add actions to alertcontroller
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }*/
    
    // Check if change status but still deny or not determined
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            permissionNotAllowed()
        }
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization() // Location permission
        }
    }
    
    // Function of didFailwithError to check if still denying
    func permissionNotAllowed() {
        // Create alertcontroller to tell user to enable permission
        let alertController = UIAlertController(title: "User location not found!", message: "Please go to Settings and enable permissions", preferredStyle: .alert)
        
        // Bring user to settings for location
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
             }
        }
        
        // If cancel go to prev controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
            (action:UIAlertAction!) in
            
            self.navigationController?.popViewController(animated: true)
        }
        
        // Add actions to alertcontroller
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // For getting directions from user location to destination
    func getDirections(userCoordinate: CLLocationCoordinate2D, destCoordinate: CLLocationCoordinate2D) {
        // Create placemark for mapItem (User and dest)
        let userPlacemark = MKPlacemark(coordinate: userCoordinate, addressDictionary: nil)
        let destPlacemark = MKPlacemark(coordinate: destCoordinate, addressDictionary: nil)

        let userMapItem = MKMapItem(placemark: userPlacemark)
        let destMapItem = MKMapItem(placemark: destPlacemark)

        userLocMapItem = userMapItem
        destLocMapItem = destMapItem
        
        // Create annotation for dest location
        if let location = destPlacemark.location {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = destName
            annotation.subtitle = destAddr
            mapView.addAnnotation(annotation)
        }
        
        // Get direction
        directionRequest.source = userMapItem   // Start at user location
        directionRequest.destination = destMapItem  // To dest location

        // Calculate the direction
        let directions = MKDirections(request: directionRequest)

        directions.calculate {
            (response, error) -> Void in

            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }

                return
            }
            
            // Get the route
            let route = response.routes[0]
            
            // Overlay the route
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)

            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }

    // Asks the delegate for a renderer object to use when drawing specified overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Renderer is used to draw contents of overlay
        let renderer = MKPolylineRenderer(overlay: overlay)

        // Color and width of line
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)    // Light blue color
        renderer.lineWidth = 5.0

        return renderer
    }
    
    // Change how annotations look
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // This behaves like the Table View's dequeue re-usable cell.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        
        // Do not override user location annotation
        if annotation is MKUserLocation {
            return nil
        }
        
        // If there aren't any reusable views to dequeue, we will have to create a new one.
        if annotationView == nil
        {
            let pinAnnotationView = MKPinAnnotationView(annotation: nil, reuseIdentifier: "pin")
            annotationView = pinAnnotationView
        }

        // Assign the annotation to the pin so that iOS knows where to position it in the map.
        annotationView?.annotation = annotation
        
        // Set button to right of annotation and pop up when clicked
        annotationView?.canShowCallout = true
        
        return annotationView
    }
    
    // MARK: - Button actions

    // When user click on different travel mode
    @IBAction func travelModePressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            directionRequest.transportType = .walking  // Mode of transport
        case 1:
            directionRequest.transportType = .transit
        case 2:
            directionRequest.transportType = .automobile
        default:
            directionRequest.transportType = .walking
        }
        
        // Remove existing overlay
        let currOverlay = mapView.overlays
        mapView.removeOverlays(currOverlay)
        
        // Set overlay again based on mode of transport
        if userLoc != nil {
            let destCoords:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: destLat!, longitude: destLng!)
            getDirections(userCoordinate: userLoc!.coordinate, destCoordinate: destCoords)
        }
    }

    // When user click on the button to go to Maps app
    @IBAction func mapsButtonPressed(_ sender: Any) {
        // Check if nil
        if userLocMapItem != nil && destLocMapItem != nil {
            var launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking]   // Mode of transport
            switch directionRequest.transportType {
            case .walking:
                launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking]   // Walk
            case .transit:
                launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeTransit]   // Transit
            case .automobile:
                launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]   // Drive
            default:
                launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking]   // Walk
            }
            userLocMapItem!.name = "My Location"    // Set user loc name
            destLocMapItem!.name = destName // Set dest name
            destLocMapItem!.openInMaps(launchOptions: launchOptions)    // Open Maps with directions to destination
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
