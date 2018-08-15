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
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var laatsteRefreshLbl: UILabel!
    
    // other variables
    let manager = CLLocationManager()
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var geselecteerdeAnnotation: BoomAnnotation?
    var laatsteRefresh: Date?
    
    // Om gemakkelijk records groter te maken
    var recordLimiet = 20
    var apiUrl: URL?
    //var apiUrl = URL(string: "https://opendata.brussel.be/api/records/1.0/search/?dataset=opmerkelijke-bomen&rows=20")
    
    @IBAction func refreshButtonClick(_ sender: Any) {
        laatsteRefresh = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        refreshKaart()
        laatsteRefreshLbl.text = dateFormatter.string(from: laatsteRefresh!)
    }
    
    func refreshKaart(){
        
        lockKnop()
        mapLeegmaken()
        getBomenData()
        unlockKnop()
    }
    
    func lockKnop() {
        // Alle 'locks' voor de form tijdens uitvoering
        refreshBtn.isEnabled = false
    }
    
    func unlockKnop() {
        // unlocks
        refreshBtn.isEnabled = true
    }
    
    func mapLeegmaken() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Boom")
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.managedContext.execute(batchDeleteRequest)
            try self.managedContext.save()
        } catch {
            print("error in refresh")
        }
        
        let allAnnotations = self.bomenMapView.annotations
        self.bomenMapView.removeAnnotations(allAnnotations)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // voeg localisatie toe op eind
        
        self.apiUrl = URL(string: "https://opendata.brussel.be/api/records/1.0/search/?dataset=opmerkelijke-bomen&rows=" + String(self.recordLimiet))!
        // Reference https://www.youtube.com/watch?v=UyiuX8jULF4
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        refreshKaart()
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
    
    func getBomenData(){
        let jsonGet = URLSession.shared.dataTask(with: apiUrl!) { (data, response, error) in
        if error != nil {
            print("Error: " + String(describing: error))
        }
        else {
            if let objecten = data {
                do {
                    let bomenJson = try JSONSerialization.jsonObject(with: objecten, options: []) as? [String: Any]
                    if let records = bomenJson!["records"] as? [[String: Any]] {
                            for record in records {
                            if let fields = record["fields"] as? [String: Any]{
                                let boom = Boom(context: self.managedContext)
                                
                                boom.id = (fields["id"] as! Int32)
                                boom.soort = (fields["soort"] as? String)
                                boom.gemeente = (fields["gemeente"] as? String)
                                boom.landschap = (fields["landschap"] as? String)
                                boom.straat = (fields["straat"] as? String)
                                boom.status = (fields["status"] as? String)
                                boom.positie = (fields["positie"] as? String)
                                boom.beplanting = (fields["omtrek"] as? String)
                                boom.omtrek = (fields["omtrek"] as! Int16)
                                boom.hoogte = (fields["hoogte"] as? String)
                                
                                if fields["diameter_van_de_kroon"] != nil {
                                    boom.diameter_van_de_kroon = (fields["diameter_van_de_kroon"] as? Int16)!
                                }
                                self.appDelegate.saveContext()
                            }
                        }
                    }
                    
                } catch {
                    print("Error in data retrieval")
                }
            }
        }
            
            DispatchQueue.main.async {
                self.vulKaart()
            }
            }
        jsonGet.resume()
    }
    
    func vulKaart() {
        var bomenVanDb: [Boom] = []
        do {
            bomenVanDb = try self.managedContext.fetch(Boom.fetchRequest())
            for boom in bomenVanDb {
                if boom.straat != nil && boom.gemeente != nil {
                    let geocoder = CLGeocoder()
                    let address = boom.straat! + boom.gemeente!
                    geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                        if((error) != nil) {
                            print("Locatie niet gevonden")
                            
                        }
                        if let placemark = placemarks?.first {
                            let boomAnno = BoomAnnotation()
                            boomAnno.coordinate = placemark.location!.coordinate
                            boomAnno.boom = boom
                            var soortDelen = boom.soort?.components(separatedBy: "\n")
                            boomAnno.title = soortDelen?[0]
                            if (soortDelen?.count)! > 1 { boomAnno.subtitle = soortDelen?[1] }
                            
                            DispatchQueue.main.async {
                                self.bomenMapView.addAnnotation(boomAnno)
                            }
                        }
                    })
                }
                
            }
        } catch {
            print("error in kaart vullen")
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {return nil}
        
        let reuseId = "pin"
        
        var pinView: MKAnnotationView?
        if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) {
            pinView = dequeueView
            pinView?.annotation = annotation
        }
        else {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let pinView = pinView {
            pinView.canShowCallout = true
            pinView.image = UIImage(named: "PixelBoom")
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "naarDetail", sender: view)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "naarDetail" {
            if let detailVC = segue.destination as? BoomDetailViewController {
                detailVC.boom = geselecteerdeAnnotation?.boom
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.geselecteerdeAnnotation = view.annotation as? BoomAnnotation
    }
    
    
}
