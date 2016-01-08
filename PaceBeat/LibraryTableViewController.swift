//
//  LibraryTableViewController.swift
//  PaceBeat
//
//  Created by Nicholas Tallents on 10/15/15.
//  Copyright © 2015 Nicholas Tallents. All rights reserved.
//

import UIKit
import MediaPlayer

class LibraryTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SongCellDelegate {

    @IBOutlet weak var CategorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var songProgressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    
    var rc           = RealmControl()
    var selectedCell = 0
    var musicPlayer  = MPMusicPlayerController.systemMusicPlayer()
    
    var enabledSongs   : [Song]!
    var disabledSongs  : [Song]!
    var notLoggedSongs : [MPMediaItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate   = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        rc.reloadData()
        
        let allSongs : [MPMediaItem] = MPMediaQuery.songsQuery().items!
        
        enabledSongs  = rc.songs.filter({ $0.mediaItem != nil &&  $0.canUse && $0.bpm > 0 })
        disabledSongs = rc.songs.filter({ $0.mediaItem != nil && !$0.canUse && $0.bpm > 0 })
        
        if enabledSongs == nil {
            enabledSongs = [Song]()
        }
        if disabledSongs == nil {
            disabledSongs = [Song]()
        }
        notLoggedSongs = [MPMediaItem]()
        
        for song in allSongs {
            if !enabledSongs.contains({ $0.mediaItem == song }) && !disabledSongs.contains({ $0.mediaItem == song }) {
                notLoggedSongs.append(song)
            }
        }
        enabledSongs  = enabledSongs.sort({ $0.title < $1.title })
        disabledSongs = disabledSongs.sort({ $0.title < $1.title })
        
        setPlayButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // TODO: Vary based on first character in song title
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Vary based on first character in song title
        switch CategorySegmentedControl.selectedSegmentIndex {
        case 0:
            if enabledSongs != nil {
                return enabledSongs.count
            } else {
                return 0
            }
        case 1:
            if disabledSongs != nil {
                return disabledSongs.count
            } else {
                return 0
            }
        default:
            return notLoggedSongs.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as! SongTableViewCell

        let index = indexPath.row
        
        switch CategorySegmentedControl.selectedSegmentIndex {
        case 0:
            cell.AlbumImageView.image  = enabledSongs[index].mediaItem?.artwork?.imageWithSize(cell.AlbumImageView.frame.size)
            cell.SongTitleLabel.text   = enabledSongs[index].title
            cell.ArtistAlbumLabel.text = enabledSongs[index].artist + " - " + enabledSongs[index].album
            cell.BpmLabel.text         = "\(enabledSongs[index].bpm) BPM"
            break
        case 1:
            cell.AlbumImageView.image  = disabledSongs[index].mediaItem?.artwork?.imageWithSize(cell.AlbumImageView.frame.size)
            cell.SongTitleLabel.text   = disabledSongs[index].title
            cell.ArtistAlbumLabel.text = disabledSongs[index].artist + " - " + enabledSongs[index].album
            cell.BpmLabel.text         = "\(disabledSongs[index].bpm) BPM"
            break
        default:
            var artistName = ""
            var albumTitle = ""
            
            if notLoggedSongs[index].artist != nil {
                artistName = notLoggedSongs[index].artist!
            }
            if notLoggedSongs[index].albumTitle != nil {
                albumTitle = notLoggedSongs[index].albumTitle!
            }
            
            cell.AlbumImageView.image  = notLoggedSongs[index].artwork?.imageWithSize(cell.AlbumImageView.frame.size)
            cell.SongTitleLabel.text   = notLoggedSongs[index].title
            cell.ArtistAlbumLabel.text = artistName + " - " + albumTitle
            cell.BpmLabel.text         = ""
        }
        
        cell.index = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var collection = [MPMediaItem]()
        switch CategorySegmentedControl.selectedSegmentIndex {
        case 0:
            collection.append(enabledSongs[indexPath.row].mediaItem!)
            break
        case 1:
            collection.append(disabledSongs[indexPath.row].mediaItem!)
            break
        default:
            collection.append(notLoggedSongs[indexPath.row])
        }
        musicPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: collection))
        musicPlayer.play()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    @IBAction func playButtonTapped(sender: AnyObject) {
        if musicPlayer.playbackState == MPMusicPlaybackState.Playing {
            musicPlayer.pause()
        } else {
            musicPlayer.play()
        }
    }
    
    @IBAction func SwitchedCategory(sender: AnyObject) {
        tableView.reloadData()
    }
    
    func songMenuButtonPressed() {
        var title  : String = ""
        var artist : String = ""
        
        switch CategorySegmentedControl.selectedSegmentIndex {
        case 0:
            title  = enabledSongs[selectedCell].title
            artist = enabledSongs[selectedCell].artist
            break
        case 1:
            title  = disabledSongs[selectedCell].title
            artist = disabledSongs[selectedCell].artist
        default:
            if notLoggedSongs[selectedCell].title != nil {
                title = notLoggedSongs[selectedCell].title!
            }
            if notLoggedSongs[selectedCell].artist != nil {
                artist = notLoggedSongs[selectedCell].artist!
            }
        }
        
        let alert = UIAlertController(title: title, message: artist, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Set BPM Manually", style: UIAlertActionStyle.Default, handler: navigateToManualBpmSet))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func navigateToManualBpmSet(action: UIAlertAction) {
        
    }
    // TODO: NEXT MUST PUT OBSERVER ON MUSICPLAYER
    func setPlayButtonState() {
        if musicPlayer.playbackState != MPMusicPlaybackState.Playing {
            //playButton.titleLabel?.text = "Play"
            playButton.setTitle("Play", forState: UIControlState.Normal)
            if musicPlayer.nowPlayingItem == nil {
                playButton.enabled = false
            }
        } else {
            //playButton.titleLabel?.text = "Pause"
            playButton.setTitle("Pause", forState: UIControlState.Normal)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
