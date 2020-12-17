//
//  SetGameLogic.swift
//  SetGame
//
//  Created by Maida on 12/16/20.
//

import Foundation

struct SetGameLogic<CardContent> where CardContent: Equatable{
   private(set) var cards: Array<Card>
    
    private var IndexOfOnlyFaceUpCard: Int? {
        get{
            cards.indices.filter {index -> Bool in cards[index].isFaceUp }.only
        }
        set {
            for index in cards.indices {
                cards [index].isFaceUp = index == newValue
            }
        }
    }
    mutating func choose(card: Card){
        print("card chosen: \(card)")
        if let chosenIndex = cards.firstIndex(matching: card), !cards[chosenIndex].isFaceUp, !cards[chosenIndex].isMatched{
            if let potentialMatchIndex = IndexOfOnlyFaceUpCard {
                if cards[chosenIndex].content == cards[potentialMatchIndex].content{
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                self.cards[chosenIndex].isFaceUp = !self.cards[chosenIndex].isFaceUp
            } else {
                IndexOfOnlyFaceUpCard = chosenIndex //becomes the only face up again
            }
        }
    }
    func index(of card: Card) -> Int{
        for index in 0..<cards.count {
            if cards[index].id == card.id{
                return index
            }
        }
        return 0 // TODO: return
    }
    

    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = Array<Card>()   //empty array
        for pairIndex in 0..<numberOfPairsOfCards{
            let content = cardContentFactory(pairIndex)
            cards.append(Card(id: pairIndex*2, content: content))
            cards.append(Card(id: pairIndex*2+1, content: content))
        }
        cards.shuffle()
    }
    
    struct Card: Identifiable {
        var id: Int
        var isFaceUp: Bool = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched: Bool = false {
            didSet {
                stopUsingBonusTime()
            }
        }
        var content: CardContent
    
        // MARK: - Bonus time
        //matching bonus points for fast matches
        var bonusTimeLimit: TimeInterval = 6
        
        //how long this card has been face up
        private var faceUpTime : TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            }else{
                return pastFaceUpTime
            }
        }
        //last time the card was turned face up and is still face up
        var lastFaceUpDate: Date?
        //total time of face up until the current face up
        var pastFaceUpTime: TimeInterval = 0
        //time left on bonus time
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        //percentage of bonus time remaining
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0 ) ? bonusTimeRemaining/bonusTimeLimit : 0
        }
        //whether card was matched during bonus time
        var hasEarnedBonus: Bool {
            isMatched && bonusRemaining > 0
        }
        // whether currently face up, not matched and still have bonus active
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }
        //called when card tranistions to face up state
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        //called when the card goes back face down or is matched
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            lastFaceUpDate = nil
        }
    }
}
