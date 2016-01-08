//
//  RealmControl.swift
//  PaceBeat
//
//  Created by Nicholas Tallents on 9/1/15.
//  Copyright (c) 2015 Nicholas Tallents. All rights reserved.
//

import Foundation
import RealmSwift
import MediaPlayer

class RealmControl : NSObject, NSURLSessionDelegate {
    let mediaPlayer = MPMusicPlayerController.systemMusicPlayer()
    var realm       : Realm!
    
    var songs     = [Song]()
    var playlists = [Playlist]()
    
    var downloadStatus = 0 // 0 -> Nothing, 1 -> Downloading data name, 2 -> Downloading song data, 3 -> Done downloading
    
    override init() {
        super.init()
        do {
            try realm = Realm()
            reloadData()
        } catch {
            
        }
    }
    
    // Get songs and playlists and synchronize with iPod Library
    func reloadData() {
        songs = [Song]()
        playlists = [Playlist]()
        
        let allSongs : [MPMediaItem] = MPMediaQuery.songsQuery().items!
        let songResults = realm.objects(Song)
        let playlistResults = realm.objects(Playlist)
        
        for result in songResults {
            let query = allSongs.filter({ $0.title == result.title && $0.artist == result.artist && $0.albumTitle == result.album })
            if query.count > 0 {
                result.mediaItem = query[0]
                songs.append(result)
            }
        }
        
        for result in playlistResults {
            playlists.append(result)
        }
    }
    
    func createPlaylist(playlist : Playlist) {
        // TODO: Will need to do some error handling if playlist already exists
        do {
            try self.realm.write {
                self.realm.add(playlist)
            }
        } catch {
            
        }
    }
    
    // Will only delete a playlist that exists in realm. Probably could get away with just deleting playlist
    // if I assume that I will only use the function if the playlist is stored...Or do some error handling
    func deletePlaylist(playlist : Playlist) {
        for p in playlists {
            if p.name == playlist.name {
                do {
                    try realm.write({
                        self.realm.delete(p)
                    })
                } catch {
                    
                }
            }
        }
    }
    
    func addSongToPlaylist(playlist : Playlist, song : Song) {
        do {
           try realm.write({
            playlist.songs.append(song)
            self.realm.add(playlist, update: true)
           })
        } catch {
            
        }
    }
    
    func addSongToPlaylistAtIndex(index: Int, playlist : Playlist, song : Song) {
        // TODO: Will need to do some error handling if index is out of bounds
        do {
           try realm.write({
            playlist.songs.insert(song, atIndex: index)
            self.realm.add(playlist, update: true)
           })
        } catch {
            
        }
    }
    
    func removeSongFromPlaylistAtIndex(index: Int, playlist : Playlist) {
        // TODO: Will need to do some error handling if index is out of bounds
        do {
            try realm.write({
            playlist.songs.removeAtIndex(index)
            self.realm.add(playlist, update: true)
            })
        } catch {
            
        }
    }
    
    func renamePlaylist(playlist : Playlist, newName : String) {
        do {
           try realm.write({
            playlist.name = newName
            self.realm.add(playlist, update: true)
           })
        } catch {
            
        }
    }
    
    func logSong(song : Song) {
        // TODO: Will need to do some error handling if song already exists
        do {
            try realm.write {
                self.realm.add(song)
            }
        } catch {
            
        }
    }
    
    // See conditions with deletePlaylist()
    func deleteSong(song : Song) {
        for s in songs {
            if s.id == song.id {
                do {
                    try realm.write({
                    self.realm.delete(s)
                    })
                } catch {
                    
                }
            }
        }
    }
    
    func updateSong(song : Song, bpm : Int, canUse : Bool) {
        // TODO: Will need to do some error handling if song doesn't exist
        do {
            try realm.write({
                song.bpm = bpm
                song.canUse = canUse
                self.realm.add(song, update: true)
            })
        } catch {
            
        }
    }
    
}