//
//  PlaylistIntent.swift
//  Playlist
//
//  Created by Christophe Fiorio on 19/02/2021.
//

import Foundation
import SwiftUI



class SearchListViewIntent{
    
    @ObservedObject var playlist : SearchPlaylistViewModel
    
    init(playlist: SearchPlaylistViewModel){
        self.playlist = playlist
    }
        
    func loaded(tracks: [Track]){
        #if DEBUG
        debugPrint("SearchIntent: \(self.playlist.playListState) => \(tracks.count) tracks loaded")
        #endif
        self.playlist.playListState = .ready
    }
    
    func httpJsonLoaded(result: Result<[Track],HttpRequestError>){
        switch result {
        case let .success(data):
            #if DEBUG
            debugPrint("SearchIntent: httpJsonLoaded -> success -> .loaded(tracks)")
            #endif
            if let artist = artistFilter{
                let tracks = data.filter( { track in track.artist.lowercased().contains(artist.lowercased()) } )
                playlist.playListState = .loaded(tracks)
            }
            else{
                playlist.playListState = .loaded(data)
            }
        case let .failure(error):
            playlist.playListState = .loadingError(error)
        }
    }
    
    func trackLoaded(){
        #if DEBUG
        debugPrint("SearchIntent: track deleted => save data")
        #endif
        playlist.playListState = .ready
    }

    var artistFilter : String? = nil

    func loadPlaylist(url : String, artistFilter: String?){
        self.artistFilter = artistFilter
        #if DEBUG
        debugPrint("SearchIntent: .loading(\(url))")
        debugPrint("SearchIntent: asyncLoadTracks")
        #endif
        playlist.playListState = .loading(url)
        ITunesTrackHelper.loadTracksFromAPI(url: url, endofrequest: httpJsonLoaded)
    }
}
