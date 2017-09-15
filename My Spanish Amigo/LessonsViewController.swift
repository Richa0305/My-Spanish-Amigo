//
//  LessonsViewController.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 16/04/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//


import UIKit
import AVFoundation
import Speech
import CoreData
import GoogleMobileAds

enum SpeechStatus {
    case ready
    case recognizing
    case unavailable
}
class LessonsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,AVSpeechSynthesizerDelegate,UICollectionViewDelegateFlowLayout {
    var english = ["Introduction","Greetings","Generally Used words","Generally Used sentences","Airport","Hotel","Counting","Restaurant"]
    var menu_vc: MenuViewController!
    @IBOutlet weak var quiz:UIButton!
    var synthesizer = AVSpeechSynthesizer()
    var interstital : GADInterstitial!
    var totalUtterance : Int = 0
    @IBOutlet weak var lessonsCollectionView: UICollectionView!
    var menuTitle = ""
    var selectedPracticeText = ""
    var menuDictionary : NSMutableDictionary?
    var menuKeys : NSArray?
    var favMenu: [NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.shouldRotate = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "MarkerFelt-Wide", size: 20)!,NSForegroundColorAttributeName: UIColor.white]
        self.lessonsCollectionView.delegate = self
        self.lessonsCollectionView.dataSource = self
        if menuTitle == "fav" {
            fetchData()
                 quiz.isHidden = true
        }
        else{
            
            quiz.setTitle("\(menuTitle) Quiz", for: UIControlState.normal)
        if let path = Bundle.main.path(forResource: "EnglishSpanishList", ofType: "plist") {
            
            //If your plist contain root as Array
            if let array = NSArray(contentsOfFile: path) as? [[String: Any]] {
                //print("Array \(array)")
            }
            
            ////If your plist contain root as Dictionary
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                //print(menuTitle)
                //print("dic \(dic[menuTitle]!)")
                menuDictionary = dic[menuTitle] as? NSMutableDictionary
                menuKeys = menuDictionary?.allKeys.sorted(by: { (key1, key2) -> Bool in
                    return ((key1 as! String) < (key2 as! String))
                }) as NSArray?
            }
        }
        }
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
        if menuTitle == "fav" {
            return favMenu.count
        }
        return menuDictionary!.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "lessonsCell", for: indexPath) as! LessonsCollectionViewCell
        if menuTitle == "fav" {
            let favourite = favMenu[indexPath.row]
            var englishTitle = favourite.value(forKeyPath: "english") as! String
            let index = englishTitle.index(englishTitle.startIndex, offsetBy: 2)
            englishTitle = englishTitle.substring(from: index)
            let spanishTitle = favourite.value(forKeyPath: "spanish") as! String
            cell.englishTextButton.setTitle("English : \(englishTitle)", for: .normal)
            cell.spanishTextButton.setTitle("Spanish : \(spanishTitle)", for: .normal)
        }else{
        let title = ((menuKeys?[indexPath.row])! as! String)
        let index = title.index(title.startIndex, offsetBy: 2)
        cell.englishTextButton.setTitle( "English : \(title.substring(from: index))", for: UIControlState.normal)
        cell.spanishTextButton.setTitle( "Spanish : \((menuDictionary?.value(forKey: title))!)", for: UIControlState.normal)
        }
        cell.nextButton.tag = indexPath.row
        cell.nextButton.titleLabel?.tag = indexPath.section
        cell.nextButton.addTarget(self, action: #selector(nextButtonAction(button:)), for: .touchUpInside)
        cell.englishTextButton.tag = indexPath.row
        cell.englishTextButton.titleLabel?.tag = indexPath.section
        cell.englishTextButton.addTarget(self, action: #selector(nextButtonAction(button:)), for: .touchUpInside)
        cell.spanishTextButton.tag = indexPath.row
        cell.spanishTextButton.titleLabel?.tag = indexPath.section
        cell.spanishTextButton.addTarget(self, action: #selector(nextButtonAction(button:)), for: .touchUpInside)
        if menuTitle == "fav" {
            cell.favButton.isHidden = true
        }else{
            fetchData()
            var flag  = false
            let engtitle = ((menuKeys?[indexPath.row])! as! String)
            for val in favMenu as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                //print("english \(val.value(forKey: "english"))")
                let favEngTitle = val.value(forKey: "english") as! String
                if engtitle == favEngTitle {
                    flag = true
                }
            }
            if flag{
                cell.favButton.setImage(UIImage(named: "fav_selected"), for: UIControlState.selected)
                cell.favButton.isSelected = true
            }
        cell.favButton.tag = indexPath.row
        cell.favButton.titleLabel?.tag = indexPath.section
        cell.favButton.addTarget(self, action: #selector(favButtonAction(button:)), for: .touchUpInside)
        }
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }
    func playButtonAction(button: UIButton) {
        NSLog("pressed!")
        NSLog("\((menuDictionary?.allKeys[button.tag])!)")
        NSLog("\((menuDictionary?.allValues[button.tag])!)")
        PlaySpanish((menuDictionary?.allValues[button.tag])! as! String)
    }
    func nextButtonAction(button: UIButton) {
        NSLog("pressed!")
        let cell = lessonsCollectionView.cellForItem(at: IndexPath(row: button.tag, section: (button.titleLabel?.tag)!)) as! LessonsCollectionViewCell
        selectedPracticeText = (cell.spanishTextButton.titleLabel?.text)!;
        performSegue(withIdentifier: "practicePageSegue", sender: nil)
    }
    func favButtonAction(button: UIButton) {
        if !button.isSelected {
            button.setImage(UIImage(named: "fav_selected"), for: UIControlState.selected)
            button.isSelected = true
        }else{
            button.setImage(UIImage(named: "fav_unselected"), for: UIControlState.normal)
            button.isSelected = false
        }
        
        let englishTitle = ((menuKeys?[button.tag])! as! String)
        let spanishTitle = (menuDictionary?.value(forKey: englishTitle))!
        
        NSLog("pressed! \(button.isSelected)")
        if button.isSelected {
            self.save(english: englishTitle, spanish: spanishTitle as! String)
        }else{
            self.deleteRow(english: englishTitle)
        }
    }
    
    func PlaySpanish(_ sender: String) {
        if !self.synthesizer.isSpeaking {
            let textPara = sender.components(separatedBy: "\n")
            self.totalUtterance = (textPara.count)
            for pieceOfText in textPara{
                let speechUtterance = AVSpeechUtterance(string: pieceOfText)
                let voice = AVSpeechSynthesisVoice(language: "es-ES");
                speechUtterance.voice = voice
                speechUtterance.rate = 1
                self.synthesizer.speak(speechUtterance)
            }
            
        }else{
            self.synthesizer.continueSpeaking()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LessonsCollectionViewCell
        selectedPracticeText = (cell.spanishTextButton.titleLabel?.text)!;
        performSegue(withIdentifier: "practicePageSegue", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "practicePageSegue" {
            
            if interstital.isReady {
                interstital.present(fromRootViewController: self)
                interstital = createAd()
            }else if Chartboost.hasInterstitial(CBLocationMainMenu) {
                Chartboost.showInterstitial(CBLocationMainMenu)
                Chartboost.cacheInterstitial(CBLocationMainMenu)
            }
            
            let destVC = segue.destination as! PracticeSpeekingViewController
            destVC.pracText = selectedPracticeText
            
        }else if segue.identifier == "showQuiz"{
           
            if interstital.isReady {
                interstital.present(fromRootViewController: self)
                interstital = createAd()
            }else if Chartboost.hasInterstitial(CBLocationMainMenu) {
                Chartboost.showInterstitial(CBLocationMainMenu)
                Chartboost.cacheInterstitial(CBLocationMainMenu)
            }
            
            let destVC = segue.destination as! MainQuizViewController
            destVC.quizTitle = menuTitle
        }
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = ((bounds.size.width) - 20)
        let cellSize = CGSize(width:width , height:103)
        return cellSize
    }
    @IBAction func show_menu_action(_ sender: UIBarButtonItem) {
        if AppDelegate.menu_bool_second {
            show_menu()
        }else{
            close_menu()
        }
    }
    func show_menu(){
        UIView.animate(withDuration: 0.3) {
            self.menu_vc.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.menu_vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.addChildViewController(self.menu_vc)
            self.view.addSubview(self.menu_vc.view)
            AppDelegate.menu_bool_second = false
        }
    }
    func close_menu(){
        UIView.animate(withDuration: 0.3, animations: {
            self.menu_vc.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        }) { (finished) in
            self.menu_vc.view.removeFromSuperview()
        }
        AppDelegate.menu_bool_second = true
        
    }
   
    
    func save(english: String,spanish:String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Favourites",
                                       in: managedContext)!
        
        let person = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        
        person.setValue(english, forKeyPath: "english")
        person.setValue(spanish, forKeyPath: "spanish")
        
        
        do {
            try managedContext.save()
        } catch let error as NSError {
           // print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func deleteRow(english: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Favourites")
        
        if let result = try? managedContext.fetch(fetchRequest) {
            for object in result {
                if (object.value(forKey: "english") as! String) == english{
                    managedContext.delete(object)
                }
            }
        }
      
    }
    func fetchData()  {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Favourites")
        
        
        do {
            favMenu = try managedContext.fetch(fetchRequest)
         
        } catch let error as NSError {
            //print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func createAd() -> GADInterstitial{
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-1382562788361552/6840158229")
        interstitial.load(GADRequest())
        return interstitial
        
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


