//
//  MainViewController.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 15/04/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MainViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var mainMenuCollectionViewController:  UICollectionView!
    var menu_vc: MenuViewController!
    var menu = ["Very Basic Words","Introduction","Ask Question","Greetings","Asking Direction","Counting","Restaurant","Pronunciation Albhabets"]
    var images = ["general","intro","askquestion","Greetings","askdirection","counting2","restaurant","alphabets"]
    var selectedMenu = ""
    var interstital : GADInterstitial!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainMenuCollectionViewController.delegate = self
        self.mainMenuCollectionViewController.dataSource = self
        
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "MarkerFelt-Wide", size: 20)!,NSForegroundColorAttributeName: UIColor.white]
        
        menu_vc = self.storyboard?.instantiateViewController(withIdentifier: "menuVC") as! MenuViewController
        
        let swipe_right = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToGesture))
        swipe_right.direction = UISwipeGestureRecognizerDirection.right
        let swipe_left = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToGesture))
        swipe_left.direction = UISwipeGestureRecognizerDirection.left
        
        self.view.addGestureRecognizer(swipe_right)
        self.view.addGestureRecognizer(swipe_left)
        
        interstital = GADInterstitial(adUnitID: "ca-app-pub-1382562788361552/6840158229")
        let requestInterstital = GADRequest()
        //requestInterstital.testDevices = [kGADSimulatorID,"2647d057df287953ed6704ab091288ac"]
        interstital.load(requestInterstital)
    }
    func respondToGesture(gesture:UISwipeGestureRecognizer){
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.right:
            show_menu()
        case UISwipeGestureRecognizerDirection.left:
            close_menu()
        default:
            break
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menu.count;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mycell", for: indexPath) as! MyCollectionViewCell
        cell.cellLabel.text = menu[indexPath.row]
        cell.cellImage.image = UIImage(named: images[indexPath.row])
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = ((bounds.size.width/2) - 23)
        let cellSize = CGSize(width:width , height:width)
        return cellSize
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMenu = menu[indexPath.row]
        self.performSegue(withIdentifier: "showLessons", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLessons" {
            if interstital.isReady {
                interstital.present(fromRootViewController: self)
                interstital = createAd()
            }else if Chartboost.hasInterstitial(CBLocationMainMenu) {
                Chartboost.showInterstitial(CBLocationMainMenu)
                Chartboost.cacheInterstitial(CBLocationMainMenu)
            }
            let vc = segue.destination as! LessonsViewController
            vc.menuTitle = selectedMenu
        }
      
    }

    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        if AppDelegate.menu_bool {
            show_menu()
        }else{
            close_menu()
        }
    
    }
    func show_menu(){
        UIView.animate(withDuration: 0) {
            self.menu_vc.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.menu_vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.addChildViewController(self.menu_vc)
            self.view.addSubview(self.menu_vc.view)
            AppDelegate.menu_bool = false
        }
    }
    func close_menu(){
        UIView.animate(withDuration: 0.3, animations: { 
            self.menu_vc.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        }) { (finished) in
            self.menu_vc.view.removeFromSuperview()
        }
            AppDelegate.menu_bool = true
        }
    func createAd() -> GADInterstitial{
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-1382562788361552/6840158229")
        interstitial.load(GADRequest())
        return interstitial
        
    }
}

