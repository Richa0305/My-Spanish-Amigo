//
//  WelcomeViewController.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 05/06/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        //let v = TranslationService()
        //let token:String = v.getToken(apiKey: "8a7da268c9a74793a989812efe41f244")
        //v.TranslateText(token: "", text: <#T##String#>)
        //print(token)
        // Do any additional setup after loading the view.
      
    }
    
    @IBAction func btnAction(_ sender: Any) {
        if Chartboost.hasInterstitial(CBLocationHomeScreen) {
            print("Has Interstitial")
            Chartboost.showInterstitial(CBLocationHomeScreen)
        } else {
             Chartboost.cacheInterstitial(CBLocationHomeScreen)
        }
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
