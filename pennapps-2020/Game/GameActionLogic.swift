//
//  GameActionLogic.swift
//  pennapps-2020
//
//  Created by Elizabeth Powell on 9/13/20.
//  Copyright © 2020 Velleity. All rights reserved.
//

import Foundation

extension GameViewModel {
        
    func takeAction(handler: @escaping (String) -> Void) {
        print("taking action")

        var userGamePlayer = gamePlayers[userId]
        
        if !userGamePlayer!.active {
            handler("You can't perform actions while being inactive")
            return
        }
        
        print("user game player active")

        
        if userGamePlayer!.isInFlagZone() {
            captureFlag(userGamePlayer: userGamePlayer!, handler: handler)
        } else {
            tagClosestOpponentInRadius(userGamePlayer: userGamePlayer!, handler: handler)
        }
    }
    
    private func captureFlag(userGamePlayer: GamePlayer, handler: @escaping (String) -> Void) {
        
        let teamFlagString = userGamePlayer.team == 0 ? "blueFlagAvailable" : "redFlagAvailable"
        ref.child(PLAY_ROOMS_DB).child(ROOM_ID).child(teamFlagString).observeSingleEvent(of: .value) { (snapshot) in
            guard let flagAvailable = snapshot.value as? Bool else {
                handler("flag available was not boolean")
                return
            }
            
            if flagAvailable {
                self.ref.child(self.PLAY_ROOMS_DB).child(self.ROOM_ID).child("players").child(userGamePlayer.userId).child("hasFlag").setValue(true) { (error, dbRef) in
                    if error != nil {
                        handler("Failed to pick up the flag!")
                    } else {
                        self.ref.child(self.PLAY_ROOMS_DB).child(self.ROOM_ID).child(teamFlagString).setValue(false)
                        handler("You are holding the flag!")
                    }
                }
            } else {
                handler("Some else is holding the flag!")
            }
            
        }
        
    }
    
    private func tagClosestOpponentInRadius(userGamePlayer: GamePlayer, handler: @escaping (String) -> Void) {
        
        let userTeam = userGamePlayer.team
        var minDist: Double = Double(INT_MAX)
        var closestOpponent: GamePlayer? = nil
        for entry in gamePlayers {
            let gamePlayer = entry.value
            if gamePlayer.team != userTeam  {
                let dist = userGamePlayer.radialDistanceFrom(otherGamePlayer: gamePlayer)
                if dist < minDist {
                    minDist = dist
                    closestOpponent = entry.value
                }
            }
        }
        
        if (closestOpponent == nil) {
            handler("There are no opponents within taggable distance")
            return
        }
        
        let teamFlagString = closestOpponent!.team == 0 ? "blueFlagAvailable" : "redFlagAvailable"
        
        if minDist < TAGGABLE_RADIUS {
            ref.child(PLAY_ROOMS_DB).child(ROOM_ID).child("players").child(closestOpponent!.userId).child("active").setValue(false) { (error, dbRef) in
                
                if (closestOpponent!.hasFlag) {
                    self.ref.child(self.PLAY_ROOMS_DB).child(self.ROOM_ID).child("players").child(closestOpponent!.userId).child("hasFlag").setValue(false)
                    self.ref.child(self.PLAY_ROOMS_DB).child(self.ROOM_ID).child(teamFlagString).setValue(true)
                }

                if error != nil {
                    handler("Tag missed!")
                } else {
                    handler("\(closestOpponent!.nickname) was tagged!")
                }
            }
        } else {
            handler("There are no opponents within taggable distance")
        }
    }
    
}
