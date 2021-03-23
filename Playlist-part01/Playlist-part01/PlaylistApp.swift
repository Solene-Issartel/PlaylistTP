//
//  PlaylistApp.swift
//  Playlist
//
//  Created by Christophe Fiorio on 18/02/2021.
//

import SwiftUI

@main
struct PlaylistApp: App {
    @Environment(\.scenePhase) private var lifecycle
    
    static var filename = "playlist.json"
    static var keyname = "myplaylist"
    static var fileUrl : URL!
    
    @StateObject var personalPlaylist : PersonalPlaylistViewModel = PersonalPlaylistViewModel(Playlist())

    init(){
        guard let url = Bundle.main.url(forResource: PlaylistApp.filename, withExtension: nil) else {
            fatalError("playlist file missing")
        }
        Self.fileUrl = url
    }
    
    func loadUserPlaylist(){
        let result = ITunesTrackHelper.loadUserPlaylist(name: Self.keyname)
        switch result {
        case .success(let tracks):
            #if DEBUG
            debugPrint("personal playlist tracks loaded : \(tracks.count) tracks loaded")
            #endif
            self.personalPlaylist.initWith(tracks: tracks)
        case .failure:
            let initResult = ITunesTrackHelper.loadTracks(fromFile: Self.filename)
            switch initResult {
            case .success(let tracks):
                self.personalPlaylist.initWith(tracks: tracks)
            default:
                fatalError("neither save data, nor initial playlist data")
            }
        }
    }
    
    func saveUserPlaylist(){
        let _ = ITunesTrackHelper.saveUserPlaylist(name: Self.keyname, data: self.personalPlaylist.model.tracks)
    }
    
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(personalPlaylist)
        }.onChange(of: lifecycle){ phase in
            switch phase{
            case .active:
                self.loadUserPlaylist()
            case .background, .inactive:
                self.saveUserPlaylist()
                break
            @unknown default:
                fatalError("unknown application lifecycle phase")
            }
        }
    }
}
