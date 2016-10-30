//
//  CreatorViewController.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 27.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import UIKit

class CreatorViewController: UIViewController {

    var appDelegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func add(_ sender: Any) {
        DataContainer.sharedInstance.createNewStory(name: self.titleField.text!, text: self.textView.text, points: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

