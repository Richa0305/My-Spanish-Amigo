//
//  PlayQuizViewController.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 30/05/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import GoogleMobileAds

class PlayQuizViewController: UIViewController,GADRewardBasedVideoAdDelegate {
    var titleMenu: String?
    
    @IBOutlet weak var addPointsBarButton: UIBarButtonItem!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var thumbsImage: UIButton!
    @IBOutlet weak var ansOption4Btn: RadioButton!
    @IBOutlet weak var ansOption3Btn: RadioButton!
    @IBOutlet weak var ansOption2Btn: RadioButton!
    @IBOutlet weak var ansOption1Btn: RadioButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    var menuDictionary : NSMutableDictionary?
    var interstital : GADInterstitial!
    var score: [NSManagedObject] = []
    var menuKeys : NSArray?
    var menuVals : NSArray?
    var delegate : GADAdDelegate!
    var rewardedVideo : GADRewardBasedVideoAd!
    var adRequestInProgress = false
    @IBOutlet var answerOptionsLabels: [RadioButton]!
    var answerSet  = Array<String>()
    var questionSet = Array<String>()
    var numberOfQuestions :Int = 0
    static var questionCounter : Int = 0
    var totalScore = 100
    
    var addPointSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "AddPoints", ofType: "wav")!)
    var lostPointSound = NSURL(fileURLWithPath: Bundle.main.path(forResource:"LostPoint", ofType: "mp3")!)
    var addPointSoundaudioPlayer = AVAudioPlayer()
    var lostPointSoundaudioPlayer = AVAudioPlayer()
    let progressInd = ProgressIndicator(text: "Please Wait")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        appDelegate.shouldRotate = false
        nextBtn.isEnabled = false
        progressInd.hide()
        self.view.addSubview(progressInd)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "MarkerFelt-Wide", size: 20)!,NSForegroundColorAttributeName: UIColor.white]
        
        
        do {
            addPointSoundaudioPlayer = try AVAudioPlayer(contentsOf: addPointSound as URL)
            lostPointSoundaudioPlayer = try AVAudioPlayer(contentsOf: lostPointSound as URL)
            addPointSoundaudioPlayer.prepareToPlay()
            lostPointSoundaudioPlayer.prepareToPlay()
        } catch {
            
        }
        
        PlayQuizViewController.questionCounter  = 0
        if let path = Bundle.main.path(forResource: "EnglishSpanishList", ofType: "plist") {
            
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                menuDictionary = dic[titleMenu!] as? NSMutableDictionary
                menuKeys = menuDictionary?.allKeys.sorted(by: { (key1, key2) -> Bool in
                    return ((key1 as! String) < (key2 as! String))
                }) as NSArray?
                menuVals = menuDictionary?.allValues as NSArray?
            }
            
        }
        
        //print("menukeys count \(menuKeys?.count)")
        var keys = Array<Int>()
        keys = uniqueRandoms(numberOfRandoms: (menuKeys?.count)!, minNum: 0, maxNum: UInt32(((menuKeys?.count)! - 1)))
        for item in keys {
            //print("item \(item)")
            questionSet.append(menuKeys?.object(at: (item)) as! String)
        }
        numberOfQuestions = questionSet.count
        
        ansOption1Btn.alternateButton = [ansOption2Btn,ansOption3Btn,ansOption4Btn]
        ansOption2Btn.alternateButton = [ansOption3Btn,ansOption4Btn,ansOption1Btn]
        ansOption3Btn.alternateButton = [ansOption2Btn,ansOption1Btn,ansOption4Btn]
        ansOption4Btn.alternateButton = [ansOption2Btn,ansOption3Btn,ansOption1Btn]
        
        var anskeys = Array<Int>()
        anskeys = anskeys.unique()
        anskeys = uniqueRandoms(numberOfRandoms: (menuVals?.count)!, minNum: 0, maxNum: UInt32(((menuVals?.count)! - 1)))
        for item in anskeys {
            answerSet.append(menuVals?.object(at: (item)) as! String)
        }
        createRewardedVideo()
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchScore()
        UpdateUI()
        
       
    }
    
   
    @IBAction func answersOptionAction(_ sender: RadioButton) {
        nextBtn.isEnabled = true
        let questionStr = questionSet[PlayQuizViewController.questionCounter]
        let index = questionStr.index(questionStr.startIndex, offsetBy: 2)
        questionLabel.text = questionStr.substring(from: index)
        let ansOfQuestion = menuDictionary?.object(forKey:questionStr) as! String
        let selectedAns = sender.titleLabel?.text
        thumbsImage.isHidden = false
        if selectedAns ==  ansOfQuestion{
            totalScore = totalScore + 10
            scoreLabel.text = "Points: \(totalScore)"
            updateScore(updatedScore: totalScore)
            addPointSoundaudioPlayer.play()
            sender.layer.borderColor = UIColor.green.cgColor
            thumbsImage.setImage(UIImage(named: "thumbs_up"), for: UIControlState.normal)
        }else{
            totalScore = totalScore - 10
            scoreLabel.text = "Points: \(totalScore)"
            updateScore(updatedScore: totalScore)
            lostPointSoundaudioPlayer.play()
            sender.layer.borderColor = UIColor.red.cgColor
            thumbsImage.setImage(UIImage(named: "thumbs_down"), for: UIControlState.normal)
            
        }
        
        ansOption1Btn.isEnabled = false
        ansOption2Btn.isEnabled = false
        ansOption3Btn.isEnabled = false
        ansOption4Btn.isEnabled = false
        PlayQuizViewController.questionCounter = PlayQuizViewController.questionCounter + 1
        //print(PlayQuizViewController.questionCounter)
       
    }
    @IBAction func nextAction(_ sender: UIButton) {
        if totalScore < 100 {
            watchVideoToEarnMorePoint()
        }else{
            if PlayQuizViewController.questionCounter < numberOfQuestions {
                resetAnsUI()
                nextQuestion()
            }else{
                //print("Game finished")
                self.navigationController?.popViewController(animated: true)
            }
        }
        nextBtn.isEnabled = false
        

    }
    func nextQuestion(){
            fetchScore()
            UpdateUI()
        
    }
    func watchVideoToEarnMorePoint(){
        let alertView = UIAlertController(title: "My Spanish Amigo", message: "You need minimum 100 point to play the Game.Your Score is too low to continue. Watch and click on this short Video/ad to earn 10 points!!", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Quit Game", style: .default, handler: { (alert) in
            self.dismissView()
        })

        let action = UIAlertAction(title: "Watch", style: .default, handler: { (alert) in
            
            if Chartboost.hasInterstitial(CBLocationMainMenu) {
                print("Has Interstitial")
                Chartboost.showInterstitial(CBLocationMainMenu)
                self.earnCoins(reward: 10)
            } else {
                Chartboost.cacheInterstitial(CBLocationMainMenu)
                if GADRewardBasedVideoAd.sharedInstance().isReady  {
                    GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
                }
            }
           
        })
        
        alertView.addAction(action1)
        alertView.addAction(action)
        self.present(alertView, animated: true, completion: nil)
    
    }
 
    func resetAnsUI(){
        thumbsImage.isHidden = true
        ansOption1Btn.isSelected = false
        ansOption2Btn.isSelected = false
        ansOption3Btn.isSelected = false
        ansOption4Btn.isSelected = false
        
        ansOption1Btn.isEnabled = true
        ansOption2Btn.isEnabled = true
        ansOption3Btn.isEnabled = true
        ansOption4Btn.isEnabled = true
    }
    func UpdateUI(){
        //print("print PlayQuizViewController.questionCounter \(PlayQuizViewController.questionCounter)")
        let questionStr = questionSet[PlayQuizViewController.questionCounter]
        let index = questionStr.index(questionStr.startIndex, offsetBy: 2)
        questionLabel.text = questionStr.substring(from: index)
        let ansOfQuestion = menuDictionary?.object(forKey:questionStr) as! String
        print("Answer \(ansOfQuestion)")
        let answerSetOfFour = answerOfFour(answer: ansOfQuestion)
        let uniqueRandomNumbers = uniqueRandoms(numberOfRandoms: 4, minNum: 0, maxNum: 3)
        
        var c = 0
        for item in uniqueRandomNumbers {
            answerOptionsLabels[c].setTitle(answerSetOfFour[item], for: UIControlState.normal)
                c = c + 1
            
        }
    }
    func answerOfFour(answer:String) -> Array<String>{
        var ansofFour = [answer,answerSet[0],answerSet[1],answerSet[2]]
        ansofFour = ansofFour.unique()
        if ansofFour.count < 4 {
            ansofFour.append(answerSet[3])
        }
        return ansofFour
    }
    func uniqueRandoms(numberOfRandoms: Int, minNum: Int, maxNum: UInt32) -> [Int] {
        var uniqueNumbers = Set<Int>()
        while uniqueNumbers.count < numberOfRandoms {
            uniqueNumbers.insert(Int(arc4random_uniform(maxNum + 1)) + minNum)
        }
        return Array(uniqueNumbers).shuffle
    }

    @IBAction func quitAction(_ sender: UIBarButtonItem) {
        
        let alertView = UIAlertController(title: "My Spanish Amigo", message: "Are you sure you want to quit the Game?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
            self.dismissView()
        })
        let action2 = UIAlertAction(title: "No", style: .default, handler: { (alert) in
        
            
        })
        alertView.addAction(action1)
        alertView.addAction(action2)
        self.present(alertView, animated: true, completion: nil)
        
    }
    func dismissView(){
        self.navigationController?.popViewController(animated: true)
    }
    func fetchScore()  {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Score")
        
        
        do {
            score = try managedContext.fetch(fetchRequest)
            if score.count == 1 {
                totalScore = score[0].value(forKey: "score") as! Int
                scoreLabel.text = "Points:\(totalScore)"
                
                if totalScore <= 90 {
                    watchVideoToEarnMorePoint()
                }

            }
            
        } catch let _ as NSError {
            //print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func updateScore(updatedScore:Int){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Score")
        
        do {
            let fetchResult = try managedContext.fetch(fetchRequest)
            
            if fetchResult.count != 0{
                
                let managedObject = fetchResult[0]
                managedObject.setValue(updatedScore, forKey: "score")
                
                try managedContext.save()
            }
        } catch let _ as NSError {
            //print("Could not fetch. \(error), \(error.userInfo)")
        }

    }

    func earnCoins(reward:Int){
        totalScore = totalScore + 10
        addPointSoundaudioPlayer.play()
        scoreLabel.text = "Points:\(totalScore)"
        
        updateScore(updatedScore: totalScore)
        resetAnsUI()
        nextQuestion()
    }
    @IBAction func addPoints(_ sender: UIBarButtonItem) {
        if Reachability.isConnectedToNetwork() {
            if Chartboost.hasInterstitial(CBLocationMainMenu) {
                print("Has Interstitial")
                Chartboost.showInterstitial(CBLocationMainMenu)
                self.earnCoins(reward: 10)
            } else {
                if GADRewardBasedVideoAd.sharedInstance().isReady  {
                    GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
                }
                Chartboost.cacheInterstitial(CBLocationMainMenu)
            }
            
        }else{
            let alertView = UIAlertController(title: "My Spanish Amigo", message: "You do not have proper internet connection to earn points through videos.Please check your internet connect.", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Quit Game", style: .default, handler: { (alert) in
                self.dismissView()
            })
            let action2 = UIAlertAction(title: "Ok", style: .default, handler: { (alert) in
                
            })
            alertView.addAction(action1)
            alertView.addAction(action2)
            self.present(alertView, animated: true, completion: nil)
        }


    }
    func createRewardedVideo() {
        if !adRequestInProgress && GADRewardBasedVideoAd.sharedInstance().isReady == false {
        
        let request = GADRequest()
        // Requests test ads on test devices.
        //request.testDevices = [kGADSimulatorID]
        GADRewardBasedVideoAd.sharedInstance().load(request, withAdUnitID: "ca-app-pub-1382562788361552/7571528229")
            adRequestInProgress = true
            
        }
    }
    // MARK: GADRewardBasedVideoAdDelegate
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        adRequestInProgress = false
        progressInd.hide()
               print("Reward based video ad failed to load: \(error.localizedDescription)")
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        adRequestInProgress = false
        print("Reward based video ad is received.")
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
        
        if Reachability.isConnectedToNetwork() {
            
            createRewardedVideo()
        }else{
                let alertView = UIAlertController(title: "My Spanish Amigo", message: "You do not have proper internet connection to earn points through videos.Please check your internet connect.", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Quit Game", style: .default, handler: { (alert) in
                    self.dismissView()
                })
                let action2 = UIAlertAction(title: "Ok", style: .default, handler: { (alert) in
                    
                })
                alertView.addAction(action1)
                alertView.addAction(action2)
                self.present(alertView, animated: true, completion: nil)
            }
        
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        // earnCoins(NSInteger(reward.amount))
        self.earnCoins(reward: 10)
    }
 
    

}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var alreadyAdded = Set<Iterator.Element>()
        return self.filter { alreadyAdded.insert($0).inserted }
    }
}
extension Array {
    var shuffle:[Element] {
        var elements = self
        for index in 0..<elements.count {
            let anotherIndex = Int(arc4random_uniform(UInt32(elements.count-index)))+index
            if anotherIndex != index {
                swap(&elements[index], &elements[anotherIndex])
            }
        }
        return elements
    }
}

