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
    
    init( from : AppDelegate) {
        app = from;
    }
    
    func load() {
        self.initializeDatabase()
    }
    
    func save(story: StoryModel) {
        
    }
    
    
    func loadTestDatabase() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Story", in: managedObjectContext)
        
        let newStory = NSManagedObject(entity: entityDescription!, insertInto: managedObjectContext)
        newStory.setValue("Test daten", forKey: "Title");
        newStory.setValue("Ich heisse Yannick", forKey: "Text");
        
        do {
            try newStory.managedObjectContext?.save()
        } catch {
            print(error)
        }
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
