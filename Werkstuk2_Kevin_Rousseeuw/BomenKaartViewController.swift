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

    // UI vars
    @IBOutlet weak var bomenMapView: MKMapView!
    @IBOutlet weak var laatsteWijzigingLabel: UILabel!
    
    // other variables
    let manager = CLLocationManager()
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var recordLimiet = 20
    
    var apiUrl = = URL(string: "https://opendata.brussel.be/api/records/1.0/search/?dataset=opmerkelijke-bomen&rows=" + String(recordLimiet))
    
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
    
    func vulKaart(){
        let jsonGet = URLSession.shared.dataTask(with: apiUrl!) {data,response,error} in
        if error != nil {
            print('Error: ' + error)
            
        }
        else {
            if let objecten = data {
                do {
                    let bomenJson = try JSONSerialization.jsonObject(with: objecten, options: []) as?
                        // key: value
                        [String: Any]{
                        if let records = bomenJson["records"] as? [[String: Any]]{
                            if let fields = record["fields"] as? [String: Any]{
                                let boom = Boom(context: self.managedContext)
                                
                            }
                            
                            
                        }
                    }
                }
            }
        }
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
