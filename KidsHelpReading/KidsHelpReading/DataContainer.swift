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
    
    var app: AppDelegate;
    var data: [StoryModel]?;
    var selectedStory: StoryModel?;
    
    init( from : AppDelegate) {
        app = from;
    }
    
    func load() {
        self.initializeDatabase()
        if (data?.count == 0) {
            self.loadTestDatabase()
            self.initializeDatabase()
        }
    }
    
    func save(story: StoryModel) {
        
    }
    
    
    func createNewStory( name: String, text: String, points: Int16) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Story", in: managedObjectContext)
        
        let newStory = NSManagedObject(entity: entityDescription!, insertInto: managedObjectContext)
        newStory.setValue(name, forKey: "Title");
        newStory.setValue(text, forKey: "Text");
        newStory.setValue(points, forKey: "points")
        
        do {
            try newStory.managedObjectContext?.save()
        } catch {
            print(error)
        }
        
    }
    
    func loadTestDatabase() {
        self.createNewStory(name: "Kleine Hexe", text: "Das ist die kleine Hexe und das ist eine schöne Geschichte", points: 7)
        self.createNewStory(name: "Das schwarze Gespenst", text: "Ich bin das schwarze Gespenst und niemand hat vor mir Angst", points: 22)
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
        return self.data!
    }
        
}
