//
//  Playlist.swift
//  PaceBeat
//
//  Created by Nicholas Tallents on 8/31/15.
//  Copyright (c) 2015 Nicholas Tallents. All rights reserved.
//

import Foundation
import RealmSwift

class Playlist: Object {
    dynamic var name      : String = ""
    dynamic var targetBPM : Int = 0
    
    var songs : List<Song> = List<Song>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
