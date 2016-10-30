//
//  GameViewController.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 28.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

// navigation controller: https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Lesson8.html

import UIKit

class GameViewController: UIViewController, UINavigationControllerDelegate {
    
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
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var displayTimeLabel: UILabel!
    @IBOutlet weak var weiterButton: UIButton!
    
    var timer = Timer()
    
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
    func updateWord() {
        self.textToReadLabel.text = "\(self.story.word())"
    }

    @IBAction func stop(_ sender: UIButton) {
        timer.invalidate()
        timer == nil
        self.story.stop()
        self.updateProgressBar()
        self.weiterButton.isEnabled = false
        self.stopButton.isEnabled = false
    }
    @IBAction func next(_ sender: UIButton) {
        self.story.next()
        self.updateProgressBar()
        if (self.story.lastGame().isDone()) {
            self.stop(sender)
        }
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
        self.updateProgressBar()
        let aSelector : Selector = "updateTime"
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let data: DataContainer? = appDelegate.container
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent == nil{
            self.stop(self.stopButton)
            self.story.save()
        }
        
    }
    
}

