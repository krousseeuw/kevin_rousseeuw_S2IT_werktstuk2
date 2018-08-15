//
//  BomenLijstViewController.swift
//  Werkstuk2_Kevin_Rousseeuw
//
//  Created by Kevin Rousseeuw on 12/08/2018.
//  Copyright © 2018 Kevin Rousseeuw. All rights reserved.
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
    
    var apiUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // voeg localisatie toe op eind
        setLocalizedText()
        let url = NSLocalizedString("apiUrl", comment: "")
        self.apiUrl = URL(string: url)!

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        refreshKaart()
    }
    
    @IBAction func refreshButtonClick(_ sender: Any) {
        
        refreshKaart()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLocalizedText() {
        refreshBtn.titleLabel?.text = NSLocalizedString("refresh", comment: "")
        self.title = NSLocalizedString("treelist", comment: "")
    }
    
    func refreshKaart(){
        
        lockKnop()
        mapLeegmaken()
        getBomenData()
        unlockKnop()
        
        laatsteRefresh = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let modifiedString = NSLocalizedString("lastModified", comment: "")
        laatsteRefreshLbl.text = modifiedString + " " + dateFormatter.string(from: laatsteRefresh!)
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
                                
                                let idField = NSLocalizedString("id", comment: "")
                                let soortField = NSLocalizedString("soort", comment: "")
                                let gemeenteField = NSLocalizedString("gemeente", comment: "")
                                let landschapField = NSLocalizedString("landschap", comment: "")
                                let straatField = NSLocalizedString("straat", comment: "")
                                let statusField = NSLocalizedString("status", comment: "")
                                let positieField = NSLocalizedString("postie", comment: "")
                                let beplantingField = NSLocalizedString("beplanting", comment: "")
                                let diameterField = NSLocalizedString("diameter_van_de_kroon", comment: "")
                                let hoogteField = NSLocalizedString("hoogte", comment: "")
                                let omtrekField = NSLocalizedString("omtrek", comment: "")
                                
                                boom.id = (fields[idField] as! Int32)
                                boom.soort = (fields[soortField] as? String)
                                boom.gemeente = (fields[gemeenteField] as? String)
                                boom.landschap = (fields[landschapField] as? String)
                                boom.straat = (fields[straatField] as? String)
                                boom.status = (fields[statusField] as? String)
                                boom.positie = (fields[positieField] as? String)
                                boom.beplanting = (fields[beplantingField] as? String)
                                boom.omtrek = (fields[omtrekField] as! Int16)
                                boom.hoogte = (fields[hoogteField] as? String)
                                
                                if fields[diameterField] != nil {
                                    boom.diameter_van_de_kroon = (fields[diameterField] as? Int16)!
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.geselecteerdeAnnotation = view.annotation as? BoomAnnotation
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let locatie = locations[0]
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        let huidigeLocatie: CLLocationCoordinate2D = CLLocationCoordinate2DMake(locatie.coordinate.latitude, locatie.coordinate.longitude)
        
        let regio: MKCoordinateRegion = MKCoordinateRegionMake(huidigeLocatie, span)
        
        self.bomenMapView.setRegion(regio, animated: true)
        
        self.bomenMapView.showsUserLocation = true
    }
}
