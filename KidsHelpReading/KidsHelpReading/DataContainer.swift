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

class DataContainer {
    
    static let sharedInstance: DataContainer = {
        return DataContainer().load()
    }()
    static let testInstance: DataContainer = {
        return DataContainer().loadTestDatabase()
    }()
    
    var data: [StoryModel] = [];
    var selectedStory: StoryModel?;
    var mode: GameMode = GameModeWord();
    
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
    
    
    func loadTestDatabase() -> DataContainer {
        self.createNewStory(name: "Die kleine Hexe", file: "Text.Die Kleine Hexe")
        self.createNewStory(name: "Das kleine Gespenst", file: "Text.Das kleine Gespenst")
        self.createNewStory(name: "Beast quest", file: "Text.Beast Quest")
        
        self.createNewStory(name: "Yannicks Wörter", file: "Text.Yannicks Wörter")
        return self
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
    
    func getStories() -> [StoryModel] {
        return self.data
    }
    
    
    func setModeWord() -> GameMode {
        self.mode = GameModeWord()
        return self.mode
    }
    func setModeWordBySentence() -> GameMode {
        self.mode = GameModeWordBySentence()
        return self.mode
    }
    func setModeWordPrefixBySentence() -> GameMode {
        self.mode = GameModeWordPrefixSuffixBySentence()
        return self.mode
    }

}
