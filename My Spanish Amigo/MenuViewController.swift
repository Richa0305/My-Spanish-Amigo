//
//  MenuViewController.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 29/05/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import GoogleMobileAds
import UIKit

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var menuTableView: UITableView!
     var menu = ["Home","Favorite","Very Basic Words","Introduction","Ask Question","Greetings","Asking Direction","Counting","Restaurant","Pronunciation Albhabets","Rate us","Share","Ads and Videos"]
     var images = ["Home","Fav","general","intro","askquestion","Greetings","askdirection","counting2","restaurant","alphabets","Rate","Share",
                   "video"]
    var selectedMenu = ""
    var interstital : GADInterstitial!
    let appID = "1242105563"
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.delegate = self
        menuTableView.dataSource = self
        // Do any additional setup after loading the view.
       
        
        interstital = GADInterstitial(adUnitID: "ca-app-pub-1382562788361552/6840158229")
        let requestInterstital = GADRequest()
        //requestInterstital.testDevices = [kGADSimulatorID,"2647d057df287953ed6704ab091288ac"]
        interstital.load(requestInterstital)
    }
    override func viewDidAppear(_ animated: Bool) {
        
        
        
        let bannerView = GADBannerView()
        bannerView.frame  = CGRect(x: 0, y: 0, width: 320, height: 50)
        let request = GADRequest()
        //request.testDevices = [kGADSimulatorID,"2647d057df287953ed6704ab091288ac"]
        bannerView.adUnitID = "ca-app-pub-1382562788361552/9793624621"
        bannerView.rootViewController = self
        bannerView.backgroundColor = UIColor.black
        bannerView.load(request)
        menuTableView.tableFooterView = bannerView
        
      
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MenuTableViewCell
        cell.menuLabel.text = menu[indexPath.row]
        cell.menuImage.image = UIImage(named: images[indexPath.row])
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMenu = menu[indexPath.row]
        if selectedMenu == "Home" {
            if interstital.isReady {
                interstital.present(fromRootViewController: self)
                interstital = createAd()
            }else if Chartboost.hasInterstitial(CBLocationMainMenu) {
                Chartboost.showInterstitial(CBLocationMainMenu)
                Chartboost.cacheInterstitial(CBLocationMainMenu)
            }
            
            self.performSegue(withIdentifier: "showMainVC", sender: self)
        }else if(selectedMenu == "Rate us"){
            rateApp(appId: appID, completion: { (success) in
                //print("Rate app success")
            })
        }else if (selectedMenu == "Share"){
            ShareApp()
        }else if (selectedMenu == "Ads and Videos"){
            if interstital.isReady {
                interstital.present(fromRootViewController: self)
                interstital = createAd()
            }else if Chartboost.hasInterstitial(CBLocationMainMenu) {
                Chartboost.showInterstitial(CBLocationMainMenu)
                Chartboost.cacheInterstitial(CBLocationMainMenu)
            }

        }else{
            if interstital.isReady {
            interstital.present(fromRootViewController: self)
            interstital = createAd()
        }else if Chartboost.hasInterstitial(CBLocationMainMenu) {
            Chartboost.showInterstitial(CBLocationMainMenu)
            Chartboost.cacheInterstitial(CBLocationMainMenu)
            }
            self.performSegue(withIdentifier: "showLessons", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLessons" {
            if selectedMenu == "Favorite"{
                let vc = segue.destination as! LessonsViewController
                vc.menuTitle = "fav"
            }
            else
            {
                let vc = segue.destination as! LessonsViewController
                vc.menuTitle = selectedMenu
            }
        }
    }
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "https://itunes.apple.com/in/app/my-spanish-amigo/id\(appID)") else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    func ShareApp(){
        let textToShare = "My Spanish Amigo"
        let urlToShare = NSURL(string: "https://itunes.apple.com/in/app/my-spanish-amigo/id\(appID)")
        let objectsToShare:NSArray = [textToShare,urlToShare!]
        let activityVC = UIActivityViewController(activityItems: objectsToShare as! [Any], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    func createAd() -> GADInterstitial{
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-1382562788361552/6840158229")
        interstitial.load(GADRequest())
        return interstitial
        
    }
}
