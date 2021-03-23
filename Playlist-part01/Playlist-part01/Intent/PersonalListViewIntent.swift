//
//  PlaylistIntent.swift
//  Playlist
//
//  Created by Christophe Fiorio on 19/02/2021.
//

import Foundation
import SwiftUI



class PersonalListViewIntent{
    
    @ObservedObject var playlist : PersonalPlaylistViewModel
    
    init(playlist: PersonalPlaylistViewModel){
        self.playlist = playlist
    }
    
    
    func add(track: Track){
        #if DEBUG
        debugPrint("SearchIntent: \(self.playlist.playListState) => \(track) track added")
        #endif
        self.playlist.playListState = .adding(track)
    }
    
    func trackLoaded(){
        #if DEBUG
        debugPrint("SearchIntent: track deleted => save data")
        #endif
        playlist.playListState = .ready
    }

//    func loadPlaylist(url : String, artistFilter: String?){
//        self.artistFilter = artistFilter
//        #if DEBUG
//        debugPrint("SearchIntent: .loading(\(url))")
//        debugPrint("SearchIntent: asyncLoadTracks")
//        #endif
//        playlist.playListState = .loading(url)
//        ITunesTrackHelper.loadTracksFromAPI(url: url, endofrequest: httpJsonLoaded)
//    }
}
