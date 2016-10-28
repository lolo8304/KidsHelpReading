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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let data: DataContainer? = appDelegate.container
        print("Container: @s", data)

        print(data?.data?[0])
        self.textView.text = appDelegate.container?.data?[0].text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var textView: UITextView!

}

