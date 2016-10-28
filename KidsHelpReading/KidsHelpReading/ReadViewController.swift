//
//  ReadViewController.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 27.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

// https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started

import UIKit

class ReadViewController: UIViewController {

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
        self.storyCollectionView.delegate = self
        self.storyCollectionView.dataSource = self
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}

extension ReadViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) 
        //cell.backgroundColor = UIColor.black
        
        let titleLabel = cell.contentView.viewWithTag(10) as? UILabel
        let pointCountLabel = cell.contentView.viewWithTag(20) as? UILabel
        let countGamesLabels = cell.contentView.viewWithTag(30) as? UILabel
        
        let story: StoryModel = self.stories[indexPath.item]
        titleLabel?.text = story.title
        pointCountLabel?.text = "\(story.points) pts"
        countGamesLabels?.text = "# \(story.games!.count)"
        
        
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        self.container.selectedStory = self.stories[indexPath.item]
        performSegue(withIdentifier: "PlayGame", sender: nil)
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        self.standardColor = cell.backgroundColor!
        cell.backgroundColor = UIColor.red
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        //cell.backgroundColor = self.standardColor
    }
    
}

