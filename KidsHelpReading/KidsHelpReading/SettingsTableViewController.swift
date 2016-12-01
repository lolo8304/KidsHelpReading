//
//  SettingsTableViewController.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 27.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import UIKit
class SettingsTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var settingsType0: GameModeTableViewCell!
    @IBOutlet weak var settingsType1: GameModeTableViewCell!
    @IBOutlet weak var settingsType2: GameModeTableViewCell!
    @IBOutlet weak var settingsType3: GameModeTableViewCell!
    @IBOutlet weak var settingsType4: GameModeTableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMode(DataContainer.sharedInstance.mode.mode())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.registerTapEvent(cell: self.settingsType0)
        self.registerTapEvent(cell: self.settingsType1)
        self.registerTapEvent(cell: self.settingsType2)
        self.registerTapEvent(cell: self.settingsType3)
        self.registerTapEvent(cell: self.settingsType4)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func registerTapEvent(cell: GameModeTableViewCell) {
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer()
        let aSelector : Selector = #selector(SettingsTableViewController.press(_:))
        gesture.addTarget(self, action: aSelector)
        gesture.delegate = self;
        gesture.delaysTouchesBegan = true;
        cell.addGestureRecognizer(gesture)

    }
    
    func setModeCells(cell: UITableViewCell) {
        self.settingsType0.accessoryType = .none
        self.settingsType1.accessoryType = .none
        self.settingsType2.accessoryType = .none
        self.settingsType3.accessoryType = .none
        self.settingsType4.accessoryType = .none
        cell.accessoryType = .checkmark
        DataContainer.sharedInstance.resetGameMode(to: cell.tag)
    }
    
    func setMode(_ mode: Int) {
        if (mode == 0) { self.setModeCells(cell: self.settingsType0) }
        if (mode == 1) { self.setModeCells(cell: self.settingsType1) }
        if (mode == 2) { self.setModeCells(cell: self.settingsType2) }
        if (mode == 3) { self.setModeCells(cell: self.settingsType3) }
        if (mode == 4) { self.setModeCells(cell: self.settingsType4) }
    }
    
    // MARK: navigation
    @IBAction func press(_ sender: UITapGestureRecognizer) {
            let cell: GameModeTableViewCell = sender.view as! GameModeTableViewCell
            self.setModeCells(cell: cell)
    }

    
    @IBAction func reset(_ sender: Any) {
        let alert = UIAlertController(title: "Achtung", message: "Wollen Sie alle Geschichten vollständig löschen?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ja", style: UIAlertActionStyle.destructive, handler: { action in
            DataContainer.sharedInstance.reloadTestDatabase()
        }))
        alert.addAction(UIAlertAction(title: "Nein", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func resetTime(_ sender: UIButton) {
        let alert = UIAlertController(title: "Achtung", message: "Wollen Sie alle Statistiken zurücksetzen?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ja", style: UIAlertActionStyle.destructive, handler: { action in
            DataContainer.sharedInstance.reloadTestDatabase()
        }))
        alert.addAction(UIAlertAction(title: "Nein", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func export(_ sender: UIBarButtonItem) {
        DataContainer.sharedInstance.exportVia(controller: self)
    }
}


class GameModeTableViewCell: UITableViewCell {
}
