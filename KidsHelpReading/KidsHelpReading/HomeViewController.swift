//
//  HomeViewController.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 01.12.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import Foundation

class HomeViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var timer = Timer()
    var lastNo: Int = 1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.switchImage()
        let aSelector : Selector = #selector(HomeViewController.switchImage)
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: aSelector, userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }


    @objc func switchImage() {
        var no: Int = lastNo
        repeat {
            no = Int(arc4random_uniform(UInt32(5)))+1
        } while (no == lastNo)
        self.imageView.image = UIImage(named: "kids-reading-\(no)")!
        lastNo = no
    }
    
}
