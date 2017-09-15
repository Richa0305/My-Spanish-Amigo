//
//  PlayVideoViewController.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 03/06/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import UIKit
import MediaPlayer
import GoogleMobileAds

class PlayVideoViewController: UIViewController {
    var moviePlayer:MPMoviePlayerController!
    var startAppBanner: STABannerView?
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var errorMsg: UILabel!
    var videoType:String!
    var videoStr:String!
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        if videoType == "Bailando" {
            videoStr = "ma81bJxaNCI"
        }else if videoType == "la-tortura" {
            videoStr = "TUImny4b4Mc"
        }
        else if videoType == "El-Perdon" {
            videoStr = "mpmfbLSQRZw"
        }
        else if videoType == "Loca" {
            videoStr = "Z6beIbokq9A"
        }
        else if videoType == "Subeme" {
            videoStr = "d7tstZjRuxQ"
        }
        else if videoType == "Despacito" {
            videoStr = "bWgNF3Ya-JU"
        }else if videoType == "Travesuras"{
            videoStr = "z3hTTGooahs"
        }else if videoType == "Duele"{
            videoStr = "6d8qQsBmAOQ"
        }
        
        getVideo(videoStr: videoStr)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.shouldRotate = true
        let request = GADRequest()
        //request.testDevices = [kGADSimulatorID,"2647d057df287953ed6704ab091288ac"]
        bannerView.adUnitID = "ca-app-pub-1382562788361552/9061607824"
        bannerView.rootViewController = self
        bannerView.backgroundColor = UIColor.black
        bannerView.load(request)
        
      
        
    }
  
    func getVideo(videoStr:String){
        let youtubeURL = NSURL(string: "https://www.youtube.com/embed/\(videoStr)")
        let youtubeRequest = NSMutableURLRequest(url: youtubeURL! as URL)
        youtubeRequest.setValue("https://www.youtube.com", forHTTPHeaderField: "Referer")
        webView.loadRequest(youtubeRequest as URLRequest)
   }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
             errorMsg.isHidden = false
            self.navigationItem.setHidesBackButton(true, animated: false)
        }else{
             errorMsg.isHidden = true
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
    }
  
    

}
