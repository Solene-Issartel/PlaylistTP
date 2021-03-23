//
//  Playlist.swift
//  Playlist
//
//  Created by Christophe Fiorio on 18/02/2021.
//

import Foundation


protocol PlaylistDelegate {
    func playlistModified(track: Track, index: Int)
    func newPlaylist()
    func playlistAdded(tracks: [Track])
    func playlistDeleted()
    func trackDeleted(at: Int)
    func tracksMoved(from source: IndexSet, to destination: Int)
}


class Playlist : ObservableObject{
    
    var delegate : PlaylistDelegate?
    
    private(set) var tracks = [Track]()
    
    func add(track: Track){
        self.tracks.append(track)
        self.delegate?.playlistModified(track: track, index: self.tracks.count-1)
    }
    func new(tracks: [Track]){
        self.tracks = tracks
        self.delegate?.newPlaylist()
    }
    func add(tracks: [Track]){
        self.tracks.append(contentsOf: tracks)
        self.delegate?.playlistAdded(tracks: tracks)
    }
    func removeAllTracks(){
        self.tracks.removeAll()
        self.delegate?.playlistDeleted()
    }
    func deleteTrack(at index: Int){
        self.tracks.remove(at: index)
        self.delegate?.trackDeleted(at: index)
    }
    func moveTracks(from source: IndexSet, to destination: Int){
        self.tracks.move(fromOffsets: source, toOffset: destination)
        self.delegate?.tracksMoved(from: source, to: destination)
    }
}

