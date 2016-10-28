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
    
    init(story: StoryModel) {
        self.story = story
        self.game = GameModel()
        self.story.addToGames(self.game)
    }
    
    init(story: StoryModel, game: GameModel) {
        self.story = story
        self.game = game;
    }
    
    func startGame(mode: GameMode) {
        if (self.game.startTime ==  nil) {
            self.game.startTime = NSDate()
        }
    }
    
    func stopGame() {
        self.game.endTime = NSDate()
    }
    
}

class GameMode {
    func start(gamePlay: GamePlayerModel) {
        var timer: TimeModel = TimeModel()
        timer.timermode = false
        timer.cheatmode = false
    }
}



class GameModeWord: GameMode {
    
}
