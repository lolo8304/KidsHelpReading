//
//  SettingsViewController.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 27.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var modeSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMode(mode: DataContainer.sharedInstance.mode.mode())
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: navigation
    
    func setMode(mode: Int) {
        self.modeSegment.selectedSegmentIndex = mode
        self.modeChanged(self.modeSegment)
    }
    
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        DataContainer.sharedInstance.resetGameMode(to: sender.selectedSegmentIndex)
    }
    
    @IBAction func reset(_ sender: Any) {
        DataContainer.sharedInstance.reloadTestDatabase()
    }
    @IBAction func resetTime(_ sender: UIButton) {
        DataContainer.sharedInstance.resetTimes()
    }
        
    @IBAction func export(_ sender: UIBarButtonItem) {
        let fileName = "kids-help-reading.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        let stories: [StoryModel] = DataContainer.sharedInstance.getStories()
        var csvText: String = ""
        var csvHeader: String = ""
        for story: StoryModel in stories {
            let export = story.addTimesTo(export: [])
            for time: TimeModel in export {
                csvText.append(time.csvRow(story: story))
                csvHeader = time.csvHeaderRow()
            }
        }
        if (!csvText.isEmpty) {
            csvHeader.append(csvText)
            csvText = csvHeader;
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                
                let vc = UIActivityViewController(activityItems: [path!], applicationActivities: nil)
                vc.excludedActivityTypes = [
                    UIActivityType.assignToContact,
                    UIActivityType.saveToCameraRoll,
                    UIActivityType.postToFlickr,
                    UIActivityType.postToVimeo,
                    UIActivityType.postToTencentWeibo,
                    UIActivityType.postToTwitter,
                    UIActivityType.postToFacebook,
                    UIActivityType.openInIBooks
                ]
                vc.popoverPresentationController?.sourceView = self.view
                self.present(vc, animated: true, completion: nil)
                
            } catch {
                
                print("Failed to create file")
                print("\(error)")
            }
                /*
                 let dateFormatter = DateFormatter()
                 dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                 let convertedDate = dateFormatter.stringFromDate(...date...)
                 */
        }
    }
}

