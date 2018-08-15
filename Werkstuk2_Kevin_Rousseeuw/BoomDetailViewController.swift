//
//  BoomDetailViewController.swift
//  Werkstuk2_Kevin_Rousseeuw
//
//  Created by student on 12/08/2018.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class BoomDetailViewController: UIViewController {

    var boom: Boom?
    
    // Text labels
    @IBOutlet weak var beschrijvingLbl: UILabel!
    @IBOutlet weak var omtrekLbl: UILabel!
    @IBOutlet weak var hoogteLbl: UILabel!
    @IBOutlet weak var diameterLbl: UILabel!
    @IBOutlet weak var adresLbl: UILabel!

    // Value labels
    @IBOutlet weak var soortNaamLbl: UILabel!
    @IBOutlet weak var beplantingValueLbl: UILabel!
    @IBOutlet weak var omtrekValueLbl: UILabel!
    @IBOutlet weak var hoogteValueLbl: UILabel!
    @IBOutlet weak var diameterValueLbl: UILabel!
    @IBOutlet weak var straatValueLbl: UILabel!
    @IBOutlet weak var gemeenteValueLbl: UILabel!
    @IBOutlet weak var landschapValueLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setLocalizedText()
        maakSchermLeeg()
        vulSchermMetData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLocalizedText() {
        beschrijvingLbl.text = NSLocalizedString("description", comment: "")
        omtrekLbl.text = NSLocalizedString("circumference", comment: "")
        hoogteLbl.text = NSLocalizedString("height", comment: "")
        diameterLbl.text = NSLocalizedString("diameter", comment: "")
        adresLbl.text = NSLocalizedString("address", comment: "")
    }
    
    func maakSchermLeeg() {
        let leeg = ""
        soortNaamLbl.text = leeg
        beplantingValueLbl.text = leeg
        omtrekValueLbl.text = leeg
        hoogteValueLbl.text = leeg
        diameterValueLbl.text = leeg
        straatValueLbl.text = leeg
        gemeenteValueLbl.text = leeg
        landschapValueLbl.text = leeg
    }
    
    func vulSchermMetData() {
        if boom?.soort != nil {
            var soortDelen = boom?.soort?.components(separatedBy: "\n")
            let soortLatijn = soortDelen?[0]
            var soortNaam = ""
            if (soortDelen?.count)! > 1 {
                soortNaam = (soortDelen?[1])! + " "
            }
            
            soortNaamLbl.text = soortNaam + "(" + soortLatijn! + ")"
        }
        
        if boom?.beplanting != nil {
            beplantingValueLbl.text = boom?.beplanting
        }
        
        if boom?.omtrek != nil {
            omtrekValueLbl.text = (boom?.omtrek.description)!
        }
        
        if boom?.hoogte != nil {
            hoogteValueLbl.text = (boom?.hoogte?.description)!
        }
        
        if boom?.diameter_van_de_kroon != nil {
            diameterValueLbl.text = (boom?.diameter_van_de_kroon.description)!
        }
        
        if boom?.straat != nil {
            straatValueLbl.text = boom?.straat
        }
        
        if boom?.gemeente != nil {
            gemeenteValueLbl.text = boom?.gemeente
        }
    }
}
