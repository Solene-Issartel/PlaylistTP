//
//  PlaylistViewModel.swift
//  Playlist
//
//  Created by Christophe Fiorio on 18/02/2021.
//

import Foundation
import SwiftUI
import Combine


enum PersonalPlayListState : CustomStringConvertible{
    case ready
    case adding(Track)
    case added(Track)
    case addedDenied(Error)

    var description: String{
        switch self {
        case .ready                               : return "ready"
        case .adding(let t)                       : return "track \(t) will be added"
        case .added(let t)                        : return "track \(t) is added"
        case .addedDenied(let error)              : return "addedError: Error adding -> \(error)"
            
        }
    }
    
}


class PersonalPlaylistViewModel: PlaylistDelegate, ObservableObject{
    /// Playlist model of ViewModel
    @Published private(set) var model: Playlist
    
    /// initialization
    /// - Parameter playlist: playlist model to be the ViewModel
    init(_ playlist: Playlist){
        self.model = playlist
        self.model.delegate = self
    }
    
    /// new list of tracks for the playlist
    ///
    /// called once playlist has been read from local save
    /// - Parameter tracks: tracks that will define the playlist
    func initWith(tracks: [Track]){
        self.model.new(tracks: tracks)
    }
    
    @Published var playListState : PersonalPlayListState = .ready{
        didSet{
            #if DEBUG
            debugPrint("SearchPlvm : state.didSet = \(playListState)")
            #endif
            switch self.playListState { // state has changed
            case let .adding(data):    // new data has been loaded, to change all tracks of playlist
                self.model.add(track: data)
            case let .added(data):    // new data has been loaded, to change all tracks of playlist
                    self.model.add(track: data)
            default:                   // nothing to do for ViewModel, perhaps for the view
                return
            }
        }
    }

    // ---------------------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: Playlist delegate
    
    /// called when playlist model has been modified
    ///
    /// if index exists, then this track has replaced the track already there, else track has been append to the list.
    /// - Parameters:
    ///   - track: track that is put into the list
    ///   - index: index where to set the track
    func playlistModified(track: Track, index: Int) {
    }
    /// called when playlist model has been deleted
    func playlistDeleted(){
    }
    /// called when a track is deleted in model
    /// - Parameter index: index of deleted track
    func trackDeleted(at index: Int) {
    }
    /// call when a track is moved in model
    /// - Parameters:
    ///   - source: index of initial position of moved track
    ///   - destination: index of final position of moved track
    func tracksMoved(from source: IndexSet, to destination: Int) {
    }
    /// called when playlist is intialized with initWith(tracks:)
    func newPlaylist() {
    }
    /// called when a set of tracks is added to model
    /// - Parameter tracks: set of track added to playlist
    func playlistAdded(tracks: [Track]) {
    }
    
    

}

