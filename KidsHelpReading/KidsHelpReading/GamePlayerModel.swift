//
//  GamePlayerModel.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 29.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import Foundation


private extension Array {
    var randomElement: Element {
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
}

class GamePlayerModel {

    var story: StoryModel;
    var game: GameModel;
    var timer: TimeModel?;
    var text: String?;
    
    init(story: StoryModel) {
        self.story = story
        self.game = story.newGame()
    }
    
    init(story: StoryModel, game: GameModel) {
        self.story = story
        self.game = game;
    }
    
    func startGame(mode: GameMode) {
        self.game.start()
        self.text = mode.start(gamePlay: self);
    }
    
    func stopGame() {
        self.game.endTime = NSDate()
    }
    
}

extension StoryModel {
    
    var allWords: [String] {
        let words: [String] = (self.text?.allWords)!
        self.countWords = Int16(words.count)
        return words
    }
    
    func start() -> GameModel {
        self.newGame().start()
        self.points = 0
        self.lastGame().lastTimer().word = allWords.randomElement
        return self.lastGame()
    }
    func word() -> String {
        return self.lastGame().word()
    }
    func next() {
        self.lastGame().next().word = allWords.randomElement
    }
    func stop() {
        self.lastGame().stop()
    }
    
    func save() {
        do {
            try self.managedObjectContext?.save()
            self.games?.enumerateObjects({ (elem, idx, stop) -> Void in
                (elem as! GameModel).save()
            })
        } catch {
            print(error)
        }

    }
    func delete() {
        do {
            self.games?.enumerateObjects({ (elem, idx, stop) -> Void in
                (elem as! GameModel).delete()
            })
            managedObjectContext?.delete(self)
        } catch {
            print(error)
        }

    }
    
    
    func newGame() -> GameModel {
        let newGame: GameModel = GameModel(context: managedObjectContext!)
        self.addToGames(newGame)
        return newGame
    }
    func lastGame() -> GameModel {
        return self.games?.lastObject as! GameModel
    }
    func updatePoints(point: Int16) {
        self.points = point
    }
    
}

extension GameModel {
    func start() {
        self.startTime = self.startStep().startTime
        self.points = 0
    }
    func next() -> TimeModel {
        self.lastTimer().doneStep()
        return self.newStep()
    }
    func stop() {
        self.doneStep()
        self.endTime = NSDate()
    }
    func word() -> String {
        return self.lastTimer().word!
    }
    
    func save() {
        do {
            try self.managedObjectContext?.save()
            self.times?.enumerateObjects({ (elem, idx, stop) -> Void in
                (elem as! TimeModel).save()
            })
        } catch {
            print(error)
        }
        
    }
    func delete() {
        do {
            self.times?.enumerateObjects({ (elem, idx, stop) -> Void in
                (elem as! TimeModel).delete()
            })
            managedObjectContext?.delete(self)
        } catch {
            print(error)
        }
        
    }


    
    func currentSeconds() ->Int16 {
        return Int16(NSDate().timeIntervalSince(self.startTime as! Date))
    }
    
    func startStep() -> TimeModel{
        return self.newStep()
    }
    func doneStep() {
        self.lastTimer().doneStep()
    }
    func newStep() -> TimeModel {
        let timer: TimeModel = TimeModel(context: managedObjectContext!)
        timer.initStep()
        self.addToTimes(timer)
        return timer
    }
    func updatePoints(point: Int16) {
        self.points = max(self.points + point, 0)
        self.story!.updatePoints(point: self.points)
    }
    func lastTimer() -> TimeModel {
        return self.times!.lastObject as! TimeModel
    }
    func isDone() -> Bool {
        return self.isStopped() || self.points >= 30
    }
    func isStarted() -> Bool {
        return self.endTime == nil
    }
    func isStopped() -> Bool {
        return !self.isStarted()
    }
}

extension TimeModel {
    func doneStep() {
        if (self.cheatmode) {
            self.point = -1
        } else {
            self.point = 1
        }
        self.seconds = Int16(NSDate().timeIntervalSince(self.startTime as! Date))
        self.game!.updatePoints(point: self.point)
    }
    func initStep() {
        self.timermode = false
        self.cheatmode = false
        self.startTime = NSDate()
        self.seconds = 0
        self.point = 0
    }
    
    func save() {
        do {
            try self.managedObjectContext?.save()
        } catch {
            print(error)
        }
        
    }
    func delete() {
        do {
            managedObjectContext?.delete(self)
        } catch {
            print(error)
        }
        
    }

}

class GameMode {
    func start(gamePlay: GamePlayerModel) -> String {
        return "no-game-mode";
    }
}



class GameModeWord: GameMode {
 
    override func start(gamePlay: GamePlayerModel) -> String {
        return (gamePlay.story.text?.allWords[0])!
    }
}

extension String {
    
    var allWords: [String] {
        var words = [String]()
        if (self == "") { return words }
        let range = self.range(of: self)
        self.enumerateSubstrings(in: range!, options: .byWords) {w,_,_,_ in
            guard let word = w else {return}
            words.append(word)
        }
        return words
        
    }
    
}
