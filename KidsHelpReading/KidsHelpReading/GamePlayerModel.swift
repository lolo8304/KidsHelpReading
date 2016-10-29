//
//  GamePlayerModel.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 29.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import Foundation


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
        return self.lastGame()
    }
    func stop() {
        self.lastGame().stop()
    }
    func newGame() -> GameModel {
        let newGame: GameModel = GameModel()
        self.addToGames(newGame)
        return newGame
    }
    func lastGame() -> GameModel {
        return self.games?.lastObject as! GameModel
    }

    
}

extension GameModel {
    func start() {
        self.startTime = self.startStep().startTime
        self.points = 0
    }
    func next() {
        self.lastTimer().doneStep()
        self.newStep()
    }
    func stop() {
        self.doneStep()
        self.endTime = NSDate()
    }
    
    func startStep() -> TimeModel{
        return self.newStep()
    }
    func doneStep() {
        self.lastTimer().doneStep()
    }
    func newStep() -> TimeModel {
        let timer: TimeModel = TimeModel()
        timer.initStep()
        self.addToTimes(timer)
        return timer
    }
    func updatePoints(point: Int16) {
        self.points = max(self.points + point, 0)
    }
    func lastTimer() -> TimeModel {
        return self.times!.lastObject as! TimeModel
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
        let range = self.range(of: self)
        self.enumerateSubstrings(in: range!, options: .byWords) {w,_,_,_ in
            guard let word = w else {return}
            words.append(word)
        }
        return words
        
    }
    
}
