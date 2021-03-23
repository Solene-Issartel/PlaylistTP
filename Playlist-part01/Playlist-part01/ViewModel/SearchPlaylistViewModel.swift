//
//  PlaylistViewModel.swift
//  Playlist
//
//  Created by Christophe Fiorio on 18/02/2021.
//

import Foundation
import SwiftUI
import Combine

enum SearchPlayListState : CustomStringConvertible{
    case ready
    case loading(String)
    case loaded([Track])
    case loadingError(Error)
    case newTracks([TrackViewModel])

    var description: String{
        switch self {
        case .ready                               : return "ready"
        case .loading(let s)                      : return "loading: \(s)"
        case .loaded(let tracks)                  : return "loaded: \(tracks.count) tracks"
        case .loadingError(let error)             : return "loadingError: Error loading -> \(error)"
        case .newTracks(let tracks)               : return "newTracks: reset playlist with \(tracks.count) tracks"
        }
    }
    
}


class SearchPlaylistViewModel: PlaylistDelegate, ObservableObject{
    
    /// Playlist model of ViewModel
    private(set) var model: Playlist
    
    /// tracks of TrackViewModel synchronized with tracks of playlist model
    @Published private(set) var tracks = [TrackViewModel]()
    
    @Published var trackAddingError : Bool = false{
        didSet{
            if !trackAddingError{
                playListState = .ready
            }
        }
    }
    /// disclosure form is opened or closed according to a bool
    /// idealy, we should set this bool in SearchListView to false when state becomes .loaded or .loadingError
    /// but this bool has to be a @State var or a @Published var and change of state will be observed in view when the body has to be recomputed,
    /// i.e. when view is redisplayed, and  change in @State var or @Published var are not taken into account during a view drawing
    /// so the bool will not change and disclosure will not be closed
    /// It is why, the viewmodel handles this bool and tell the view when close the disclosure according to state change
    @Published var formViewOpen = false

    /// State of new data loading for playlist
    @Published var playListState : SearchPlayListState = .ready{
        didSet{
            #if DEBUG
            debugPrint("SearchPlvm : state.didSet = \(playListState)")
            #endif
            switch self.playListState { // state has changed
            case let .loaded(data):    // new data has been loaded, to change all tracks of playlist
                self.formViewOpen = false // close searchFormView, new tracks have been found
                #if DEBUG
                debugPrint("SearchPlvm: track loaded => formViewOpen=\(formViewOpen) -> model.new(tracks:)")
                #endif
                self.model.new(tracks: data)
            case .loadingError:
                self.formViewOpen = true // reopen or keep open searchFormView as there is an error on loading new tracks
            default:                   // nothing to do for ViewModel, perhaps for the view
                return
            }
        }
    }
    
    /// initialization
    /// - Parameter playlist: playlist model to be the ViewModel
    init(_ playlist: Playlist){
        self.model = playlist
        self.model.delegate = self
    }
    
    /// new list of tracks for the playlist
    /// - Parameter tracks: tracks that will define the playlist
    func new(tracks: [Track]){
        #if DEBUG
        debugPrint("SearchPlvm: model.new(tracks:) with \(tracks.count) tracks")
        #endif
        self.model.new(tracks: tracks)
    }
    
    /// add new tracks to the playlist
    /// - Parameter tracks: tracks to be added to the playlist
    func add(tracks: [Track]){
        self.model.add(tracks: tracks)
    }
    
    /// erase playlist
    func removeAllTracks(){
        self.model.removeAllTracks()
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
    /// called when playlist model has been deleted
    func playlistDeleted(){
        self.tracks.removeAll()
    }
    /// called when playlist model has changed all its list of tracks
    func newPlaylist() {
        #if DEBUG
        debugPrint("SearchPlvm: newPlaylist()")
        #endif
        self.tracks.removeAll()
        for track in self.model.tracks{
            self.tracks.append(TrackViewModel(track))
        }
        #if DEBUG
        debugPrint("SearchPlvm: playListState = .newTracks")
        #endif
        self.playListState = .newTracks(self.tracks)
    }
    /// call when a set of tracks has been append to the playlist
    /// - Parameter tracks: tracks to be added
    func playlistAdded(tracks: [Track]) {
        for track in tracks{
            self.tracks.append(TrackViewModel(track))
        }
        self.playListState = .newTracks(self.tracks)
    }
    
    func playlistModified(track: Track, index: Int) {
        return // SearchPlaylistViewModel manages loading an entire set of tracks, not individual change of track of the list
    }
    func trackDeleted(at index: Int) {
        return // SearchPlaylistViewModel manages loading an entire set of tracks, not individual change of track of the list
    }

    func tracksMoved(from source: IndexSet, to destination: Int) {
        return // SearchPlaylistViewModel manages loading an entire set of tracks, not individual change of track of the list
    }
    
}

