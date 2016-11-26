//
//  GamePlayerModel.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 29.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit


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
    
    func fromBracketsToAttributes() -> NSAttributedString {
        var ranges: [NSRange] = []
        
        var stringWord = self
        var lowerVariableRange = NSMakeRange(0, 0)
        repeat {
            let word:NSString = NSString(string: stringWord)
            lowerVariableRange = word.range(of: "{{")
            if (lowerVariableRange.length > 0) {
                /* remove {{ and }} */
                let lower = stringWord.range(of: "{{")
                let upperVariableRange = word.range(of: "}}")
                let upper = stringWord.range(of: "}}")
    
                let start = stringWord.substring(to: (lower?.lowerBound)!)
                let middleIndex = stringWord.index((lower?.lowerBound)!, offsetBy: 2)
                let middle = stringWord.substring(with: middleIndex..<(upper?.lowerBound)!)
                let end = stringWord.substring(from: (upper?.upperBound)!)
                let myRange = NSRange(location: lowerVariableRange.location, length: (upperVariableRange.location - lowerVariableRange.location - lowerVariableRange.length))
                ranges.append(myRange)
                stringWord = "\(start)\(middle)\(end)"
            }
        } while ( lowerVariableRange.length > 0)
        let myString = NSMutableAttributedString(string: stringWord)
        for range in ranges {
            myString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellow , range: range)
        }
        return myString
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
    
    func start() {
        self.newGame().start()
        self.points = 0
        DataContainer.sharedInstance.mode.start(story: self)
    }
    func word() -> String {
        return self.lastGame().word()
    }
    func lastWord() -> String {
        return self.lastGame().lastWord()
    }
    func next() {
        self.lastGame().next()
        DataContainer.sharedInstance.mode.next(story: self)
    }
    func skip() {
        DataContainer.sharedInstance.mode.next(story: self)
    }
    func stop() {
        self.lastGame().stop()
    }
    
    func save() {
        do {
            self.games?.enumerateObjects({ (elem, idx, stop) -> Void in
                (elem as! GameModel).save()
            })
            try self.managedObjectContext?.save()
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
            try managedObjectContext?.save()
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
    
    var google: GoogleImageSearch {
        return GoogleImageSearch(query: self.title!)
    }
    
    func randomUIImage(onCompletion: @escaping (String) -> Void) {
        self.google.getFirstImage(onCompletion: { (url: String, height: Int, width: Int, mimeType: String) in
                onCompletion(url)
        })
    }
    
    func firstUIImage(view: UIImageView) {
        let localImage: UIImage? = self.title!.loadImage()
        if (localImage != nil) {
            DispatchQueue.main.async() { () -> Void in
                view.image = localImage
            }
        } else {
            self.randomUIImage(onCompletion: { (url: String) in
                view.downloadedFrom(link: url, name: self.title!)
            })
        }

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
    func lastWord() -> String {
        let lastTimer : TimeModel? = self.beforeLastTimer()
        if (lastTimer != nil) {
            return (self.beforeLastTimer()?.word!)!
        } else {
            return ""
        }
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
        self.times?.enumerateObjects({ (elem, idx, stop) -> Void in
            (elem as! TimeModel).delete()
        })
        managedObjectContext?.delete(self)
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
    func beforeLastTimer() -> TimeModel? {
        if (self.times!.count > 1) {
            return (self.times![(self.times?.count)!-2] as! TimeModel)
        }
        return nil
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
            self.point = 0 - self.point
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
        self.point = 1
    }
    
    func save() {
        do {
            try self.managedObjectContext?.save()
        } catch {
            print(error)
        }
        
    }
    func delete() {
            managedObjectContext?.delete(self)

        
    }
    func cheated() {
        self.cheatmode = true
    }
    func cheated5() {
        self.cheatmode = true
        self.point = 5
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
    func mode() -> Int {
        return -1;
    }
    
    func isDone(story: StoryModel) -> Bool {
        return false
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
        let old: String = story.lastWord()
        self.wordIndex = story.allWords.randomElementIndex
        let new: String = story.allWords[self.wordIndex]
        if (story.allWords.count > 1 && new == old) { return self.next(story: story) }
        story.lastGame().lastTimer().word = new
        return new
    }
    override func mode() -> Int {
        return 0;
    }
    
    override func isDone(story: StoryModel) -> Bool {
        return false
    }


}


class GameModeWordBySentence: GameMode {
    
    public override init() {
        super.init()
        wordIndex = -1
    }
    
    func nextSentenceIndex(_ sentences: Array<Any>) -> Int {
        return sentences.randomElementIndex
    }
    override func start(story: StoryModel) -> String {
        let wordsBySentences: [[String]] = story.allWordsbySentences
        self.sentenceIndex = self.nextSentenceIndex(wordsBySentences)
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
            self.sentenceIndex = self.nextSentenceIndex(wordsBySentences)
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
    override func mode() -> Int {
        return 1;
    }
    
    override func isDone(story: StoryModel) -> Bool {
        return false
    }


}

class GameModeWordPrefixSuffixBySentence: GameModeWordBySentence {

    func buildWordPrefixSuffix(story: StoryModel, w: String) -> String {
        let wordsBySentences: [[String]] = story.allWordsbySentences
        var word: String = w
        let wordsThisSentence: [String] = wordsBySentences[self.sentenceIndex]
        if (self.wordIndex > 0 && (self.wordIndex + 1 < wordsThisSentence.count)) {
            let prefix = wordsThisSentence[self.wordIndex-1]
            let suffix1 = wordsThisSentence[self.wordIndex+1]
            word = "\(prefix) {{\(word)}} \(suffix1)"
        } else if (self.wordIndex > 0) {
            let prefix = wordsThisSentence[self.wordIndex-1]
            word = "\(prefix) {{\(word)}}"
        } else if (self.wordIndex + 1 < wordsThisSentence.count) {
            let suffix2 = wordsThisSentence[self.wordIndex+1]
            word = "{{\(word)}} \(suffix2)"
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
    override func mode() -> Int {
        return 2;
    }
    override func isDone(story: StoryModel) -> Bool {
        let wordsBySentences: [[String]] = story.allWordsbySentences
        return self.wordIndex + 1 == wordsBySentences[self.sentenceIndex].count
    }


}


class GameModeWordFullSentence: GameModeWordBySentence {

    var wordPosition: String.Index = "".index("".startIndex, offsetBy: 0)
    
    func buildWordPrefixSuffix(story: StoryModel, w: String) -> String {
        if (self.wordIndex == 0) {
            self.wordPosition = "".index("".startIndex, offsetBy: 0)
        }
        let wordsBySentences: [[String]] = story.allWordsbySentences
        let allSentences: [String] = story.allSentences
        let sentence: String = allSentences[self.sentenceIndex]
        
        let selectedWord = wordsBySentences[self.sentenceIndex][self.wordIndex] // word
        let startSentence = sentence.substring(to: self.wordPosition) // before word
        let wordAndEndSentence: String = sentence.substring(from: self.wordPosition) // endstring with word
        let wordRange = wordAndEndSentence.range(of: selectedWord)
        let prefix = wordAndEndSentence.substring(to: wordRange!.lowerBound)
        let endSentence = wordAndEndSentence.substring(from: (wordRange!.upperBound)) // after word
        self.wordPosition = "\(startSentence)\(prefix)\(selectedWord)".endIndex
        return "\(startSentence)\(prefix){{\(selectedWord)}}\(endSentence)";
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
    override func mode() -> Int {
        return 3;
    }
    override func isDone(story: StoryModel) -> Bool {
        let wordsBySentences: [[String]] = story.allWordsbySentences
        return self.wordIndex + 1 == wordsBySentences[self.sentenceIndex].count
    }

    
}

class GameModeWordFullSentenceAfterSentence: GameModeWordFullSentence {
    override func nextSentenceIndex(_ sentences: Array<Any>) -> Int {
        return self.sentenceIndex + 1
    }
    override func mode() -> Int {
        return 4;
    }
    
}


