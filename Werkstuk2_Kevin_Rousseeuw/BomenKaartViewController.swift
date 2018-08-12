//
//  BomenLijstViewController.swift
//  Werkstuk2_Kevin_Rousseeuw
//
//  Created by student on 12/08/2018.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class BomenKaartViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var bomenMapView: MKMapView!
    @IBOutlet weak var laatsteWijzigingLabel: UILabel!
    
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // voeg localisatie toe op eind
        
        // Reference https://www.youtube.com/watch?v=UyiuX8jULF4
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let locatie = locations[0]
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        let huidigeLocatie: CLLocationCoordinate2D = CLLocationCoordinate2DMake(locatie.coordinate.latitude, locatie.coordinate.longitude)
        
        let regio: MKCoordinateRegion = MKCoordinateRegionMake(huidigeLocatie, span)
        // eventueel locatie change niet forceren
        self.bomenMapView.setRegion(regio, animated: true)
        
        self.bomenMapView.showsUserLocation = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
