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

    
    func createNewStory( name: String, file: String, points: Int16) {
        self.createNewStory(name: name, text: readFromFile(name: file), points: points)
    }
    
    func createNewStory( name: String, text: String, points: Int16) {
        let newStory:StoryModel = StoryModel(context: managedObjectContext)
        newStory.title = name
        newStory.text = text
        newStory.points = points
        
        do {
            self.data.append(newStory)
            try newStory.managedObjectContext?.save()
        } catch {
            print(error)
        }
        
    }
    
    
    func loadTestDatabase() -> DataContainer {
        self.createNewStory(name: "Die kleine Hexe", file: "Text.Die Kleine Hexe", points: 0)
        self.createNewStory(name: "Das kleine Gespenst", file: "Text.Das kleine Gespenst", points: 0)
        self.createNewStory(name: "Yannicks Wörter", file: "Text.Yannicks Wörter", points: 0)
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
        
}
