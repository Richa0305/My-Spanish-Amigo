//
//  TranslatePopupViewController.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 06/06/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import UIKit
import CoreData
import Speech

class TranslatePopupViewController: UIViewController,AVSpeechSynthesizerDelegate {
    @IBOutlet weak var popup: DesignableView!
   
    @IBOutlet weak var checkInternetConnectionLabel: UILabel!
    @IBOutlet weak var spinnerActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var translateBtn: DesignableButton!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var transitionBtn: DesignableButton!
    @IBOutlet weak var addToFavBtn: DesignableButton!
    @IBOutlet weak var englishText: UITextField!
    var from = "en"
    var to = "es"
    var synthesizer = AVSpeechSynthesizer()
    var totalUtterance : Int = 0
    @IBOutlet weak var spanishText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.backgroundColor = UIColor.clear
        topView.isOpaque = false
    }
    @IBAction func translateAction(_ sender: DesignableButton) {
        guard (englishText.text?.characters.count)! > 0 else {
            return
        }
        englishText.resignFirstResponder()
        let text = englishText.text;
        let v = TranslationService()
        translateBtn.isEnabled = false
        if Reachability.isConnectedToNetwork() {
            
            checkInternetConnectionLabel.isHidden = true
            self.spinnerActivityIndicator.startAnimating()
            v.getTranslatedText(apiKey: "040470817c1d4536bd57f44950bbe093",text: text!,from:from, to:to) { (success,response) in
                
                if(success){
                    DispatchQueue.main.async {
                        self.spinnerActivityIndicator.stopAnimating()
                        
                        self.transitionBtn.isEnabled = false
                        self.translateBtn.setTitle("Translation Complete!", for: UIControlState.normal)
                        self.translateBtn.backgroundColor = UIColor.init(red: 59/255, green: 144/255, blue: 240/255, alpha: 1)
                        self.spanishText.text = self.getStringFromXMLResponse(response: response)
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.spinnerActivityIndicator.stopAnimating()
                        
                        self.transitionBtn.isEnabled = false
                        self.translateBtn.setTitle("Translation Failed", for: UIControlState.normal)
                        self.translateBtn.backgroundColor = UIColor.init(red: 59/255, green: 144/255, blue: 240/255, alpha: 1)
                    }
                    
                }
            }

        }else{
            checkInternetConnectionLabel.isHidden = false
        
        }
        
    }
    
    @IBAction func changeTransitionButtonAction(_ sender: Any) {
        if from == "en" {
            from = "es"
        }else{
            from = "en"
        }
        
        if to == "en" {
            to = "es"
        }else{
            to = "en"
        }
        
        if from == "en" {
            englishText.placeholder = "English text goes here"
            spanishText.placeholder = "Spanish"
        }else{
            englishText.placeholder = "Spanish text goes here"
            spanishText.placeholder = "English"
        }
        
        
    }
    func getStringFromXMLResponse(response:String) -> String{
        var text = ""
        
        text = response.slice(from: ">", to: "<")!
        return text
    }
 
    @IBAction func closePopup(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
 
    @IBAction func addToFavAction(_ sender: UIButton) {
        guard (englishText.text?.characters.count)! > 0 else {
            return
        }
        
        guard (spanishText.text?.characters.count)! > 0 else {
            return
        }
        self.addToFavBtn.isEnabled = false
        self.addToFavBtn.backgroundColor = UIColor.init(red: 59/255, green: 144/255, blue: 240/255, alpha: 1)
        self.save(english: englishText.text!, spanish: spanishText.text!)
        
        
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        
            from = "en"
            to = "es"
        self.transitionBtn.isEnabled = true
        
        self.spanishText.text = nil
        self.englishText.text = nil
        
        englishText.placeholder = "English text goes here"
        spanishText.placeholder = "Spanish"
        
        
        translateBtn.isEnabled = true
        self.translateBtn.setTitle("Translate", for: UIControlState.normal)
        self.translateBtn.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        
        if !self.addToFavBtn.isEnabled {
            
            self.addToFavBtn.backgroundColor = UIColor.white
            self.addToFavBtn.setTitle("Add to Favriote", for: UIControlState.normal)
            self.addToFavBtn.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            self.addToFavBtn.isEnabled = true
        }
        
    }
    
    @IBAction func playAction(_ sender: Any) {
      
        guard (spanishText.text?.characters.count)! > 0 else {
            return
        }
        self.PlaySpanish(spanishText.text!)
        
    }
    
    func PlaySpanish(_ sender: String) {
        if !self.synthesizer.isSpeaking {
            let textPara = sender.components(separatedBy: "\n")
            self.totalUtterance = (textPara.count)
            for pieceOfText in textPara{
                let speechUtterance = AVSpeechUtterance(string: pieceOfText)
                let voice = AVSpeechSynthesisVoice(language: "es-MX");
                speechUtterance.voice = voice
                speechUtterance.rate = 0.003
                self.synthesizer.speak(speechUtterance)
            }
            
        }else{
            self.synthesizer.continueSpeaking()
        }
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
        
        if from == "es" {
            person.setValue("a.\(spanish)", forKeyPath: "english")
            person.setValue(english, forKeyPath: "spanish")
        }else{
            person.setValue("a.\(english)", forKeyPath: "english")
            person.setValue(spanish, forKeyPath: "spanish")
        }
        
        
        do {
            try managedContext.save()
            self.addToFavBtn.setTitle("Added to Favriote", for: UIControlState.normal)
        } catch let error as NSError {
            // print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}
extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
}
