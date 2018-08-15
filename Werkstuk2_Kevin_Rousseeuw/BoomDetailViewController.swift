//
//  BoomDetailViewController.swift
//  Werkstuk2_Kevin_Rousseeuw
//
//  Created by student on 12/08/2018.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class BoomDetailViewController: UIViewController {

    @IBOutlet weak var soortNaamLbl: UILabel!
    @IBOutlet weak var beplandingLbl: UILabel!
    @IBOutlet weak var omtrekLbl: UILabel!
    @IBOutlet weak var hoogteLbl: UILabel!
    @IBOutlet weak var diameterLbl: UILabel!
    @IBOutlet weak var straatLbl: UILabel!
    @IBOutlet weak var gemeenteLbl: UILabel!
    @IBOutlet weak var landschapLbl: UILabel!
    
    var boom: Boom?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        maakSchermLeeg()
        vulSchermMetData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func maakSchermLeeg() {
        let leeg = ""
        soortNaamLbl.text = leeg
        beplandingLbl.text = leeg
        omtrekLbl.text = leeg
        hoogteLbl.text = leeg
        diameterLbl.text = leeg
        straatLbl.text = leeg
        gemeenteLbl.text = leeg
        landschapLbl.text = leeg
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
            beplandingLbl.text = boom?.beplanting
        }
        
        if boom?.omtrek != nil {
            omtrekLbl.text = (boom?.omtrek.description)!
        }
        
        if boom?.hoogte != nil {
            hoogteLbl.text = (boom?.hoogte?.description)!
        }
        
        if boom?.diameter_van_de_kroon != nil {
            diameterLbl.text = (boom?.diameter_van_de_kroon.description)!
        }
        
        if boom?.straat != nil {
            straatLbl.text = boom?.straat
        }
        
        if boom?.gemeente != nil {
            gemeenteLbl.text = boom?.gemeente
        }    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
