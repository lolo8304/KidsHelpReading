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
    var randomElementIndex: Int {
        return Int(arc4random_uniform(UInt32(count)))
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
    var allSentences: [String] {
        var sentences = [String]()
        if (self == "") { return sentences }
        let range = self.range(of: self)
        self.enumerateSubstrings(in: range!, options: .bySentences) {s,_,_,_ in
            guard let sentence = s else {return}
            sentences.append(sentence)
        }
        return sentences
    }
    var allWordsBySentences: [[String]] {
        var sentences = [[String]]()
        if (self == "") { return sentences }
        let range = self.range(of: self)
        self.enumerateSubstrings(in: range!, options: .bySentences) {s,_,_,_ in
            guard let sentence: String = s else {return}
            sentences.append(sentence.allWords)
        }
        return sentences
    }
    
}


extension StoryModel {
    
    var allWords: [String] {
        let words: [String] = (self.text?.allWords)!
        self.countWords = Int16(words.count)
        return words
    }
    var allSentences: [String] {
        let sentences: [String] = (self.text?.allSentences)!
        return sentences
    }
    var allWordsbySentences: [[String]] {
        let sentences: [[String]] = (self.text?.allWordsBySentences)!
        return sentences
    }
    
    func start() -> GameModel {
        self.newGame().start()
        self.points = 0
        DataContainer.sharedInstance.setModeWordBySentence().start(story: self)
        return self.lastGame()
    }
    func word() -> String {
        return self.lastGame().word()
    }
    func next() {
        self.lastGame().next()
        DataContainer.sharedInstance.mode.next(story: self)
    }
    func skip() {
        self.lastGame().skip().word = allWords.randomElement
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
        newGame.story = self
        return newGame
    }
    func lastGame() -> GameModel {
        return self.games?.lastObject as! GameModel
    }
    func updatePoints(point: Int16) {
        self.points = point
    }
    
    func resetTimes() {
        self.games?.enumerateObjects({ (elem, idx, stop) -> Void in
            (elem as! GameModel).delete()
            self.removeFromGames(elem as! GameModel)
        })
        self.points = 0
    }
    
    func addTimesTo( export: Array<TimeModel>) -> Array<TimeModel> {
        var export = export
        self.games?.enumerateObjects({ (elem, idx, stop) -> Void in
            export = (elem as! GameModel).addTimesTo(export: export)
            self.removeFromGames(elem as! GameModel)
        })
        return export
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
    func skip() -> TimeModel {
        self.lastTimer().skip()
        return self.lastTimer()
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
        timer.game = self
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

    func addTimesTo( export: Array<TimeModel>) -> Array<TimeModel> {
        var export = export
        self.times?.enumerateObjects({ (elem, idx, stop) -> Void in
            export.append(elem as! TimeModel)
        })
        return export
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
    func skip() {
        self.initStep()
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
    func cheated() {
        self.cheatmode = true
    }
    
    func csvHeaderRow() -> String {
        return "title, countWords, word, seconds, point, startTime\n"
    }
    func csvRow(story: StoryModel) -> String {
        return "\(story.title!), \(story.countWords), \(self.word!), \(self.seconds), \(self.point), \(self.startTime!)\n"
    }

}

class GameMode {
    var wordIndex: Int = 0;
    var sentenceIndex: Int = 0;

    func start(story: StoryModel) -> String {
        return "no-game-mode";
    }
    func next(story: StoryModel) -> String {
        return "no-game-mode";
    }
}



class GameModeWord: GameMode {
    
    
    override func start(story: StoryModel) -> String {
        self.wordIndex = story.allWords.randomElementIndex
        let word: String = story.allWords[self.wordIndex]
        story.lastGame().lastTimer().word = word
        return word
    }
    override func next(story: StoryModel) -> String {
        let old: String = story.lastGame().lastTimer().word!
        self.wordIndex = story.allWords.randomElementIndex
        let new: String = story.allWords[self.wordIndex]
        if (story.allWords.count > 1 && new == old) { return self.next(story: story) }
        story.lastGame().lastTimer().word = new
        return new
    }
}


class GameModeWordBySentence: GameMode {
    
    override func start(story: StoryModel) -> String {
        let wordsBySentences: [[String]] = story.allWordsbySentences
        self.sentenceIndex = wordsBySentences.randomElementIndex
        self.wordIndex = 0
        let word: String = wordsBySentences[self.sentenceIndex][self.wordIndex]
        story.lastGame().lastTimer().word = word
        return word
    }
    override func next(story: StoryModel) -> String {
        let wordsBySentences: [[String]] = story.allWordsbySentences
        var word: String = ""
        self.wordIndex += 1
        if (self.wordIndex == wordsBySentences[self.sentenceIndex].count) {
            self.sentenceIndex = wordsBySentences.randomElementIndex
            self.wordIndex = 0
            word = wordsBySentences[self.sentenceIndex][self.wordIndex]
        } else {
            if (self.wordIndex + 1 == wordsBySentences[self.sentenceIndex].count) {
                word = "\(wordsBySentences[self.sentenceIndex][self.wordIndex])."
            } else {
                word = wordsBySentences[self.sentenceIndex][self.wordIndex]
            }
        }
        story.lastGame().lastTimer().word = word
        return word
        
    }
}

class GameModeWordPrefixSuffixBySentence: GameModeWordBySentence {
    
    func buildWordPrefixSuffix(story: StoryModel, w: String) -> String {
        let wordsBySentences: [[String]] = story.allWordsbySentences
        var word: String = w
        if (self.wordIndex > 0) {
            let prefix = wordsBySentences[self.sentenceIndex][self.wordIndex-1]
            word = "(\(prefix))     \(word)"
        }
        if (self.wordIndex + 1 < story.allWords.count) {
            let suffix = wordsBySentences[self.sentenceIndex][self.wordIndex+1]
            word = "\(word)     (\(suffix))"
        }
        return word
    }
    override func start(story: StoryModel) -> String {
        var word: String = super.start(story: story)
        word = self.buildWordPrefixSuffix(story: story, w: word)
        story.lastGame().lastTimer().word = word
        return word
    }
    override func next(story: StoryModel) -> String {
        var word: String = super.next(story: story)
        word = self.buildWordPrefixSuffix(story: story, w: word)
        story.lastGame().lastTimer().word = word
        return word
    }
}

