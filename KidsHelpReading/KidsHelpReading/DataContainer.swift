//
//  DataContainer.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 28.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import Foundation
import UIKit
import CoreData


extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

class DataContainer {
    
    static let sharedInstance: DataContainer = {
        return DataContainer().load()
    }()
    static let testInstance: DataContainer = {
        let container = DataContainer()
        container.loadTestDatabase()
        return container
    }()
    
    var data: [StoryModel] = [];
    var selectedStory: StoryModel? {
        willSet(newStory) {
            if (newStory != nil && newStory != selectedStory) {
                self.mode = newStory!.getGameMode(self.mode.mode())
               // newStory?.resetTimes()
            }
        }
    }
    var mode: GameMode = GameModeWordFullSentenceAfterSentence()
    
    private init() {
    }
    
    public func load() -> DataContainer {
        self.initializeDatabase()
        if (data.count == 0) {
            self.loadTestDatabase()
        }
        return self
    }
    
    func readFromFile(name: String) -> String {
        let path = Bundle.main.path(forResource: name, ofType: "txt")
        do {
            return try String(contentsOfFile: path!)
        } catch {
            print(error)
            return "fehler"
        }
    }

    
    func createNewStory( name: String, file: String) {
        self.createNewStory(name: name, text: readFromFile(name: file))
    }
    
    func createNewStory( name: String, text: String) {
        let newStory:StoryModel = StoryModel(context: managedObjectContext)
        let trimmed = text.replacingOccurrences(of: "\n", with: " ")
        newStory.title = name
        newStory.text = trimmed
        newStory.points = 0
        
        do {
            self.data.append(newStory)
            try newStory.managedObjectContext?.save()
        } catch {
            print(error)
        }
        
    }
    func deleteStory(story: StoryModel) {
        story.delete()
        self.data.remove(object: story)
    }
    
    
    func loadTestDatabase() {
        self.createNewStory(name: "Die kleine Hexe", file: "Text.Die Kleine Hexe")
        self.createNewStory(name: "Das kleine Gespenst", file: "Text.Das kleine Gespenst")
        self.createNewStory(name: "Die 3 ? Kids - Panik im Paradies", file: "Text.DieDreiFrageZeichenKids.PanikImParadies")
        self.createNewStory(name: "Die Teufelskicker - Eine knallharte Saison", file: "Text.Die Teufelskicker Eine knallharte Saison")
        self.createNewStory(name: "Beast Quest - Arachnid, Meister der Spinnen", file: "Text.Beast Quest - Arachnid, Meister der Spinnen")
    }
    
    func reloadTestDatabase() {
        for story in self.data {
            story.delete()
        }
        self.data = []
        self.loadTestDatabase()
    }
    
    func initializeDatabase() {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest = NSFetchRequest<StoryModel>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Story", in: managedObjectContext)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            self.data = try managedObjectContext.fetch(fetchRequest)
             print(self.data)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func resetTimes() {
        for story: StoryModel in self.getStories() {
            story.resetTimes()
        }
    }
    
    func getStories() -> [StoryModel] {
        return self.data
    }
    
    func resetGameMode() {
        self.resetGameMode(to: self.mode.mode())
    }
    func resetGameMode(to: Int) {
        if (to == 0) {
            DataContainer.sharedInstance.setModeWord()
        }
        if (to == 1) {
            DataContainer.sharedInstance.setModeWordBySentence()
        }
        if (to == 2) {
            DataContainer.sharedInstance.setModeWordPrefixBySentence()
        }
        if (to == 3) {
            DataContainer.sharedInstance.setModeSentence()
        }
        if (to == 4) {
            DataContainer.sharedInstance.setModeSentenceAfterSentence()
        }
    }

    func getModes() -> [GameMode] {
        return [
            GameModeWord(),
            GameModeWordBySentence(),
            GameModeWordPrefixSuffixBySentence(),
            GameModeWordFullSentence(),
            GameModeWordFullSentenceAfterSentence()
        ]
    }
    func setModeWord(){
        self.mode = GameModeWord()
    }
    func setModeWordBySentence() {
        self.mode = GameModeWordBySentence()
    }
    func setModeWordPrefixBySentence() {
        self.mode = GameModeWordPrefixSuffixBySentence()
    }
    func setModeSentence() {
        self.mode = GameModeWordFullSentence()
    }
    func setModeSentenceAfterSentence() {
        self.mode = GameModeWordFullSentenceAfterSentence()
    }
    
    func exportVia(controller: UIViewController) {
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
                vc.popoverPresentationController?.sourceView = controller.view
                controller.present(vc, animated: true, completion: nil)
                
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
