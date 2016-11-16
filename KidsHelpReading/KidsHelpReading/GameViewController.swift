//
//  GameViewController.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 28.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

// navigation controller: https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Lesson8.html

import UIKit
import AVFoundation

class GameViewController: UIViewController, AVSpeechSynthesizerDelegate, UINavigationControllerDelegate {
    
    var appDelegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var story: StoryModel {
        return appDelegate.container!.selectedStory!
    }
    
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var textToReadLabel: UILabel!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet var listenAll: UIButton!
    
    @IBOutlet weak var displayTimeLabel: UILabel!
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var weiterButton: UIButton!
        
    @IBOutlet var gestureTap: UITapGestureRecognizer!

    let speechSynthesizer = AVSpeechSynthesizer()
    var timer = Timer()
    var disableOKButtonTimer = Timer()
    var okButtonBackground: UIColor = UIColor.black
    var isReadingAll: Bool = false
    
    private func storyProgress() -> Float {
        if (self.story.points == 0) { return 0.0 };
        return Float(self.story.points) / 30.0;
    }
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    func updateProgressBar() {
        self.progressBar.setProgress(self.storyProgress(), animated: true)
        self.progressLabel.text = "\(self.story.points)"
        self.updateWord()
    }
    
    func extractBracketsFrom(sentence: String) -> String {
        let stringWord = sentence
        let word:NSString = NSString(string: stringWord)
        let lowerVariableRange = word.range(of: "{{")
        if (lowerVariableRange.length > 0) {
            /* remove {{ and }} */
            let lower = stringWord.range(of: "{{")
            let upper = stringWord.range(of: "}}")
            let middleIndex = stringWord.index((lower?.lowerBound)!, offsetBy: 2)
            let middle = stringWord.substring(with: middleIndex..<(upper?.lowerBound)!)
            return middle;
        } else {
            return stringWord;
        }
    }
    
    func extractRawFrom(sentence: String) -> String {
        return sentence.replacingOccurrences(of: "{{", with: "").replacingOccurrences(of: "}}", with: "")
    }
    
    
    func updateWord() {
        self.textToReadLabel.attributedText = self.story.word().fromBracketsToAttributes()
        self.listenAll.isEnabled = true
        self.listenButton.isEnabled = true

        /*
        if (self.story.points >= 5) {
            self.listenAll.isEnabled = true
        } else {
            self.listenAll.isEnabled = false
        }
        if (self.story.points >= 1) {
            self.listenButton.isEnabled = true
        } else {
            self.listenButton.isEnabled = false
        }
         */
    }

    
    func updateTime() {
        
        var elapsedTime = self.story.lastGame().currentSeconds()
        
        //calculate the minutes in elapsed time.
        let minutes = Int16(elapsedTime / 60)
        
        elapsedTime -= minutes * 60
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        self.displayTimeLabel.text = "\(strMinutes):\(strSeconds)"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechSynthesizer.delegate = self

        self.updateProgressBar()
        let aSelector : Selector = #selector(GameViewController.updateTime)
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
        
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameViewController.tapped(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.textToReadLabel.addGestureRecognizer(singleTap)
        self.textToReadLabel.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.stop(self.stopButton)
        self.story.save()
        timer.invalidate()
        disableOKButtonTimer.invalidate()
        
    }
    
    
    func enableOKButtonDelayed() {
        disableOKButtonTimer.invalidate()
        self.okButton.isEnabled = true
        self.okButton.backgroundColor = self.okButtonBackground
    }
    
    
    // MARK: speech
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.okButton.isEnabled = true
        self.stopButton.isEnabled = true
        self.weiterButton.isEnabled = true
        self.listenButton.isEnabled = true
        self.listenAll.isEnabled = true

        if (!self.isReadingAll) {
            self.story.lastGame().lastTimer().cheated()
            self.listenButton.alpha = 1.0
            //self.next(self.okButton)
        } else {
            self.isReadingAll = false
            self.listenAll.alpha = 1.0
            self.story.lastGame().lastTimer().cheated5()
            //self.next(self.okButton)
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
    }
    
    
    func isDone() -> Bool {
        return (self.story.lastGame().isDone() && DataContainer.sharedInstance.mode.isDone(story: self.story))
    }
    
    // MARK: navigation
    
    @IBAction func stop(_ sender: Any) {
        timer.invalidate()
        self.story.stop()
        self.updateProgressBar()
        self.weiterButton.isEnabled = false
        self.weiterButton.isHidden = true
        self.stopButton.isEnabled = false
        self.stopButton.isHidden = true
        self.okButton.isEnabled = false
        self.okButton.isHidden = true
    }
    @IBAction func next(_ sender: Any) {
        self.okButton.isEnabled = false
        self.okButtonBackground = self.okButton.backgroundColor!
        self.okButton.backgroundColor = self.stopButton.backgroundColor
        
        let aSelector : Selector = #selector(GameViewController.enableOKButtonDelayed)
        disableOKButtonTimer = Timer.scheduledTimer(timeInterval: 0.40, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
        self.story.next()
        self.updateProgressBar()
        if (self.isDone()) {
            self.stop(sender)
        }
    }
    
    @IBAction func skip(_ sender: UIButton) {
        self.story.skip()
        self.updateProgressBar()
    }

    @IBAction func listen(_ sender: UIButton) {
        self.isReadingAll = false
        self.listenButton.alpha = 0.2
        self.listenButton.isEnabled = false

        self.okButton.isEnabled = false
        self.stopButton.isEnabled = false
        self.weiterButton.isEnabled = false
        
        if !speechSynthesizer.isSpeaking {
            self.listenButton.isEnabled = false
            self.listenAll.isEnabled = false
            let speechUtterance = AVSpeechUtterance (string: self.extractBracketsFrom(sentence: self.story.word()))
            speechUtterance.rate = 0.4
            speechUtterance.pitchMultiplier = 1.0

            speechSynthesizer.speak(speechUtterance)
        } else {
            speechSynthesizer.continueSpeaking()
        }
    }
    @IBAction func listenAll(_ sender: UIButton) {
        self.isReadingAll = true
        self.listenAll.alpha = 0.2
        self.listenAll.isEnabled = false
        
        self.okButton.isEnabled = false
        self.stopButton.isEnabled = false
        self.weiterButton.isEnabled = false
        
        if !speechSynthesizer.isSpeaking {
            self.listenAll.isEnabled = false
            let speechUtterance = AVSpeechUtterance (string: self.extractRawFrom(sentence: self.story.word()))
            speechUtterance.rate = 0.4
            speechUtterance.pitchMultiplier = 1.0

            speechSynthesizer.speak(speechUtterance)
        } else {
            speechSynthesizer.continueSpeaking()
        }
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.ended){
            if (!self.isDone()) {
                    self.next(sender)
            }
        }
    }
    
}

