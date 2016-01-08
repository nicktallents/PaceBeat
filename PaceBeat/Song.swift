//
//  Song.swift
//  PaceBeat
//
//  Created by Nicholas Tallents on 8/31/15.
//  Copyright (c) 2015 Nicholas Tallents. All rights reserved.
//

import RealmSwift
import MediaPlayer

class Song: Object {
    var mediaItem : MPMediaItem?
    dynamic var id        : Int = -1
    dynamic var bpm       : Int = -1
    dynamic var canUse    : Bool = false
    dynamic var title     : String = ""
    dynamic var artist    : String = ""
    dynamic var album     : String = ""
    //dynamic var year      : Int = 0
    
    required init() {
        super.init()
        bpm = -1
        canUse = false
        title = ""
        artist = ""
        //year = 0
        album = ""
    }
    
    init(mediaItem: MPMediaItem, bpm: Int, canUse: Bool, logged: Bool) {
    //init(bpm: Int, canUse: Bool, logged: Bool) {
        super.init()
        self.mediaItem = mediaItem
        self.bpm = bpm
        self.canUse = canUse
        self.title = ""
        self.artist = ""
        //self.year = 0
        self.album = ""
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["mediaItem"]
    }
}
