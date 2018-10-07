//
//  ViewController.swift
//  BuildingSurveyor
//
//  Created by Salvatore Lentini on 10/5/18.
//  Copyright © 2018 Salvatore Lentini. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate
{

    @IBAction func btnDown_Action(_ sender: UIButton) {
    }
    
    let locationManager = CLLocationManager()
    var myLocation:CLLocationCoordinate2D?
    @IBOutlet weak var btnMyLocation: UIButton!
    @IBOutlet weak var Map: MKMapView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Steven Howe Center Coordinates
        let location = CLLocationCoordinate2DMake(40.744786, -74.023916)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Stevens Institute"
        annotation.subtitle = "Howe Center"
        
        Map.addAnnotation(annotation)
        
        btnMyLocation.setTitle("My Location", for: .normal)
        
        // current location
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        /*
        Map.delegate = self
        Map.mapType = .standard
        Map.isZoomEnabled = true
        Map.isScrollEnabled = true

        if let coor = Map.userLocation.location?.coordinate{
            Map.setCenter(coor, animated: true)
        }
         */
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Map.showsUserLocation = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Map.showsUserLocation = false
    }
    
    func addLongPressGesture(){
        let longPressRecogniser:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target:self , action:#selector(ViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0 //user needs to press for 2 seconds
        self.Map.addGestureRecognizer(longPressRecogniser)
    }
    
    @objc func handleLongPress(_ gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state != .began{
            return
        }
        
        let touchPoint:CGPoint = gestureRecognizer.location(in: self.Map)
        let touchMapCoordinate:CLLocationCoordinate2D =
            self.Map.convert(touchPoint, toCoordinateFrom: self.Map)
        
        let annot:MKPointAnnotation = MKPointAnnotation()
        annot.coordinate = touchMapCoordinate
        
        self.resetTracking()
        self.Map.addAnnotation(annot)
        self.centerMap(touchMapCoordinate)
    }
    
    func resetTracking(){
        if (Map.showsUserLocation){
            Map.showsUserLocation = false
            self.Map.removeAnnotations(Map.annotations)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func centerMap(_ center:CLLocationCoordinate2D){
        self.saveCurrentLocation(center)
        
        let spanX = 0.007
        let spanY = 0.007
        
        let newRegion = MKCoordinateRegion(center:center , span: MKCoordinateSpan(latitudeDelta: spanX, longitudeDelta: spanY))
        Map.setRegion(newRegion, animated: true)
    }
    
    func saveCurrentLocation(_ center:CLLocationCoordinate2D){
        let message = "\(center.latitude) , \(center.longitude)"
        print(message)
      //  self.lable.text = message
        myLocation = center
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
            
            let location = locations.last! as CLLocation
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.Map.setRegion(region, animated: true)
    
            //centerMap(center)
    }
    
    static var enable:Bool = true
    @IBAction func getMyLocation(_ sender: UIButton) {
        
        if CLLocationManager.locationServicesEnabled() {
            if ViewController.enable {
                locationManager.stopUpdatingHeading()
                sender.titleLabel?.text = "Enable"
            }else{
                locationManager.startUpdatingLocation()
                sender.titleLabel?.text = "Disable"
            }
            ViewController.enable = !ViewController.enable
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        let identifier = "pin"
        var view : MKPinAnnotationView
        if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView{
            dequeueView.annotation = annotation
            view = dequeueView
        }else{
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        //view.pinColor =  .red
        return view
    }
    
}

