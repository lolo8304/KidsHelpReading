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
    
    
    private func storyProgress() -> Float {
        if (self.story.points == 0) { return 0.0 };
        return Float(self.story.points) / 30.0;
    }
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    func updateProgressBar() {
        self.progressBar.setProgress(self.storyProgress(), animated: true)
        self.progressLabel.text = "\(self.story.points)"
    }
    
    func next() {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateProgressBar()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let data: DataContainer? = appDelegate.container
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Navigation
    
    @IBAction func unwindToReadView(sender: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
}

