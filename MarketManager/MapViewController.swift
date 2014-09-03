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
import QuartzCore

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locations: [CLLocation] = []
    var polyline: MKPolyline?
    var date: NSDate!
    
    lazy var locationManager: CLLocationManager = {
        let aLocationManager = CLLocationManager()
        aLocationManager.delegate = self
        aLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        aLocationManager.distanceFilter = 10
        aLocationManager.headingFilter = 5
        aLocationManager.requestAlwaysAuthorization()
        return aLocationManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.startUpdatingLocation()
        self.date = NSDate()
        
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
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error.description)
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
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer: MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
        renderer.lineWidth = 5.0
        return renderer
    }
    
    // MARK: private
    private func polylineWithLocations(locations: [CLLocation]) -> MKPolyline {
        var coordinates: [CLLocationCoordinate2D] = []
        for location in self.locations {
            coordinates += [location.coordinate]
        }
        
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        return polyline
    }

    private func captureScreen() -> UIImage? {
        if let window = AppDelegate().window {
            let screenSize = window.bounds.size
            UIGraphicsBeginImageContext(screenSize)
            let context = UIGraphicsGetCurrentContext()
            self.view.layer.renderInContext(context)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        
        return nil
    }
    
    
}
