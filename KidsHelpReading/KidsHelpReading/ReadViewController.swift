//
//  ReadViewController.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 27.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

// https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started

import UIKit

class ReadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var storyCollectionView: UICollectionView!
    
    var appDelegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var container:DataContainer {
        return self.appDelegate.container!
    }
    var stories: [StoryModel] {
        return (self.appDelegate.container?.data)!
    }
    
    // MARK: - Properties
    fileprivate let reuseIdentifier = "StoryCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate var standardColor: UIColor = UIColor.red;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.container.selectedStory = nil
        self.storyCollectionView.delegate = self
        self.storyCollectionView.dataSource = self
        self.storyCollectionView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return self.stories.count
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UIStoryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UIStoryCollectionViewCell
        //cell.backgroundColor = UIColor.black
        
        let titleLabel = cell.contentView.viewWithTag(10) as? UILabel
        let pointCountLabel = cell.contentView.viewWithTag(20) as? UILabel
        let countGamesLabels = cell.contentView.viewWithTag(30) as? UILabel
        let imageView = cell.contentView.viewWithTag(50) as? UIImageView
        
        let story: StoryModel = self.stories[indexPath.item]
        cell.story = story
        
        titleLabel?.text = story.title
        pointCountLabel?.text = "\(story.points) pts"
        countGamesLabels?.text = "# \(story.games!.count)"
        
        story.firstUIImage(view: imageView!)
        
        let gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        let aSelector : Selector = #selector(ReadViewController.longPress(_:))
        gesture.addTarget(self, action: aSelector)
        gesture.delegate = self;
        gesture.delaysTouchesBegan = true;
        cell.addGestureRecognizer(gesture)
        
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (sender as AnyObject? === addButton || sender as AnyObject? === settingsButton) {
            return true;
        } else {
            return false;
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _ = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        self.container.selectedStory = self.stories[indexPath.item]
        self.container.selectedStory?.start()
        performSegue(withIdentifier: "PlayGame", sender: nil)
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        self.standardColor = cell.backgroundColor!
        cell.backgroundColor = UIColor.red
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        _ = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        //cell.backgroundColor = self.standardColor
    }
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.began) {
            let cell: UIStoryCollectionViewCell = sender.view as! UIStoryCollectionViewCell
            self.container.selectedStory = cell.story
            performSegue(withIdentifier: "AddEditGame", sender: nil)
        }
    }
}

