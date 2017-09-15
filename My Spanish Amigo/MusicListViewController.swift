//
//  MusicListViewController.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 03/06/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MusicListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var musicTableViewController: UITableView!
    var startAppBanner: STABannerView?
    @IBOutlet weak var bannerView: GADBannerView!
    var musicVideoTitles = ["Enrique Iglesias - Bailando(dancing)","Shakira - La tortura(torture)","Enrique El Perdon(Forgiveness)","Shakira - Loca(Crazy)","Enrique Iglesias - Subeme la radio(Turn up the radio)","Luis Fonsi - Despacito(Slowly) Daddy Yankee Justin Bieber - YouTube","Travesuras - Nicky Jam (Lyrics Spanish & English) (HD)","Duele El Corazón - Enrique Iglesias - Lyrics Translated [English + Spanish]"]
    var selectedRow:String!
    var imagesOfMusicVideos = ["Bailando","la-tortura","El-Perdon","Loca","Subeme","Despacito","Travesuras","Duele"]
    //var musicImages = [""]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        musicTableViewController.dataSource = self
        musicTableViewController.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
             super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.shouldRotate = false
        let request = GADRequest()
        //request.testDevices = [kGADSimulatorID,"2647d057df287953ed6704ab091288ac"]
        bannerView.adUnitID = "ca-app-pub-1382562788361552/9061607824"
        bannerView.rootViewController = self
        bannerView.backgroundColor = UIColor.black
        bannerView.load(request)

      

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicVideoTitles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MucisTableViewCell
        
        cell.movieTitle.text = musicVideoTitles[indexPath.row]
        cell.musicImage.image = UIImage(named: imagesOfMusicVideos[indexPath.row])
        return cell
    }
    func navigationControllerSupportedInterfaceOrientations(navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = imagesOfMusicVideos[indexPath.row]
        performSegue(withIdentifier: "showVideos", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideos" {
            let destVC = segue.destination as! PlayVideoViewController
            destVC.videoType = selectedRow
        }
    }
 

}
