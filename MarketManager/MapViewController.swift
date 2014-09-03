//
//  MapViewController.swift
//  MarketManager
//
//  Created by Wesley Sui on 14-9-3.
//  Copyright (c) 2014年 Jing Yun Sui. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locations: [CLLocation] = []
    var polyline: MKPolyline?
    
    lazy var locationManager: CLLocationManager = {
        let aLocationManager = CLLocationManager()
        aLocationManager.delegate = self
        aLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        aLocationManager.distanceFilter = 10
        aLocationManager.headingFilter = 5
        return aLocationManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location: CLLocation = locations[locations.count-1] as CLLocation
        
        let timeInterval = -location.timestamp.timeIntervalSinceNow
        if timeInterval > 120 { //ignore old (cached) update
            println("timeInterval:\(timeInterval) > 120, ignored...")
            return
        }
        
        if location.horizontalAccuracy < 0 { //ignore invalid update
            println("horizontalAccuracy:\(location.horizontalAccuracy) < 0, ignored...")
            return
        }
        
        if !self.mapView!.showsUserLocation {
            self.mapView!.showsUserLocation = true
            let region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1.0/111, 1.0/111))
            self.mapView!.setRegion(region, animated: true)
        }
    }
    
    func polylineWithLocations(locations: [CLLocation]) -> MKPolyline {
        var coordinates: [CLLocationCoordinate2D] = []
        for location in self.locations {
            coordinates += [location.coordinate]
        }
        
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        return polyline
    }
    
    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        println( __FUNCTION__)
        if let polyline = self.polyline {
            self.mapView!.removeOverlay(polyline)
        }
        self.polyline = self.polylineWithLocations(self.locations)
        self.mapView!.addOverlay(self.polyline!)
    }
    
}
