//
//  PracticeSpeekingViewController.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 24/04/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import UIKit
import Speech

class PracticeSpeekingViewController: UIViewController,SFSpeechRecognizerDelegate,AVSpeechSynthesizerDelegate {

    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var confidenceScore: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var practiceText: UILabel!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    var synthesizer = AVSpeechSynthesizer()
    var totalUtterance : Int = 0
    
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultText: UILabel!
    var pracText = ""
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "es-ES"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var confidenceForText = Array<Double>()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        darkView.layer.cornerRadius = 10
        darkView.layer.masksToBounds = true
        
        practiceText.text = pracText
        microphoneButton.isEnabled = false
        
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                
            case .restricted:
                isButtonEnabled = false
            case .notDetermined:
                isButtonEnabled = false
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
        let transform : CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 3.0)
        confidenceScore.transform = transform
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func record(_ sender: Any) {
        self.microphoneButtonTapped(sender)
    }
    @IBAction func microphoneButtonTapped(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            self.blink(sender: self.microphoneButton,flashing: true)
            confidenceForText.removeAll()
                        //microphoneButton.setTitle("Start Recording", for: .normal)
        } else {
            if Reachability.isConnectedToNetwork() {
                startRecording()
                self.blink(sender: self.microphoneButton,flashing: false)
            }else{
                let alert = UIAlertController(title: "My Spanish Amigo", message: "Please check your internet connection.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            //microphoneButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            //print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textview.text = result?.bestTranscription.formattedString
                
                isFinal = (result?.isFinal)!
                
                                if isFinal  {
                                for item in (result?.transcriptions)!{
                                    for seg in item.segments{
                                        //print(seg.substring)
                                        //print(seg.confidence)
                                        self.confidenceForText.append(Double(seg.confidence).roundTo(places: 2))
                                        }
                 
                                    }
                                    var confidence = 0.0
                                    if self.confidenceForText.count > 0 {
                                        for confidenceScore in self.confidenceForText{
                                            //print(confidence)
                                            confidence += confidenceScore
                                        }
                                    }
                                    confidence = Double(confidence) / Double (self.confidenceForText.count)
                                    self.confidenceScore.progress = Float(confidence)
                                    self.resultImage.isHidden = false
                                    self.resultText.isHidden = false
                                    //print(confidence)
                                    let resultStr = (result?.bestTranscription.formattedString)!
                                    let spanishText = self.pracText.components(separatedBy: ":")
                                    let textList = spanishText[1].trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
                                    var correctTextDict = [String:Bool]()
                                    //print(textList)
                                    var textIsCorrect: Bool = false
                                    var numberOfCorrectWord = 0
                                    if (textList.count > 1){
                                        for item in textList{
                                             //print(item)
                                            if(self.removeSpecialCharsFromString(text: resultStr).localizedCaseInsensitiveContains(self.removeSpecialCharsFromString(text: item))){
                                                numberOfCorrectWord = numberOfCorrectWord + 1
                                            }
                                            
                                        }
                                        if numberOfCorrectWord == textList.count{
                                            textIsCorrect = true
                                        }else{
                                            textIsCorrect = false
                                        }
                                        
                                       
                                    }else if (textList.count == 1){
                                        if self.removeSpecialCharsFromString(text: resultStr).localizedCaseInsensitiveContains(self.removeSpecialCharsFromString(text: textList[0])) {
                                            textIsCorrect = true
                                        }
                                    }
                                  
                                    if (textIsCorrect){
                                        if confidence > 0.8 {
                                            self.resultImage.image = UIImage(named: "thumbs_up")!
                                            self.confidenceScore.progressTintColor  = UIColor.green
                                            self.resultText.text = "Sounds Great!!"
                                            self.resultText.textColor = UIColor.green
                                        }else if ((confidence > 0.5) && (confidence < 0.8)){
                                            self.resultImage.image = UIImage(named: "thumbs_down")!
                                            self.confidenceScore.progressTintColor  = UIColor.magenta
                                            self.resultText.text = "Sounds ok!"
                                            self.resultText.textColor = UIColor.magenta
                                        }else if(confidence < 0.5){
                                            self.resultImage.image = UIImage(named: "thumbs_up")!
                                            self.confidenceScore.progressTintColor  = UIColor.red
                                            self.resultText.text = "That didn't sound very confident, Try again!"
                                            self.resultText.textColor = UIColor.red
                                            self.resultText.font = UIFont.systemFont(ofSize: 12.0)
                                        }
                                    }else{
                                        
                                        if confidence > 0.8 {
                                            self.resultImage.image = UIImage(named: "thumbs_up")!
                                            self.confidenceScore.progressTintColor  = UIColor.green
                                        }else if ((confidence > 0.5) && (confidence < 0.8)){
                                            self.resultImage.image = UIImage(named: "thumbs_down")!
                                            self.confidenceScore.progressTintColor  = UIColor.magenta
                                        }else if(confidence < 0.5){
                                            self.resultImage.image = UIImage(named: "thumbs_up")!
                                            self.confidenceScore.progressTintColor  = UIColor.red
                                        }
                                        if (textList.count == 1){
                                            self.resultImage.image = UIImage(named: "thumbs_down")!
                                            self.resultText.text = "Thats not correct, Why dont you try again!"
                                            self.resultText.textColor = UIColor.red
                                            self.resultText.font = UIFont.systemFont(ofSize: 12.0)

                                        }else{
                                        if (numberOfCorrectWord == (textList.count - 1)){
                                            self.resultImage.image = UIImage(named: "thumbs_up")!
                                            self.resultText.text = "That is almost correct!"
                                            self.resultText.textColor = UIColor.green
                                            self.resultText.font = UIFont.systemFont(ofSize: 12.0)
                                        }
                                        else{
                                            self.resultImage.image = UIImage(named: "thumbs_down")!
                                            self.resultText.text = "Thats not correct, Why dont you try again!"
                                            self.resultText.textColor = UIColor.red
                                            self.resultText.font = UIFont.systemFont(ofSize: 12.0)
                                        }
                                        }
                                    }
                            
                }
            
            
            
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            //print("audioEngine couldn't start because of an error.")
        }
        
        
    }
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }

    @IBAction func play(_ sender: Any) {
        self.playAction(sender)
    }
    @IBAction func playAction(_ sender: Any) {
        var str = pracText.components(separatedBy: ":")
        self.PlaySpanish(str[1])
    }
    
    func blink(sender: UIButton, flashing:Bool) {
        var flashing = flashing
        if !flashing{
            sender.imageView?.alpha = 1.0
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction], animations: {() -> Void in
                sender.alpha = 0.1
            }, completion: {(finished: Bool) -> Void in
            })
            
            flashing = true
        }
        else{
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {() -> Void in
                sender.alpha = 1.0
            }, completion: {(finished: Bool) -> Void in
            })
        }
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
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890".characters)
        //print(String(text.characters.filter {okayChars.contains($0) }))
        return String(text.characters.filter {okayChars.contains($0) })
    }
}

