//
//  TrackViewModel.swift
//  Playlist
//
//  Created by Christophe Fiorio on 18/02/2021.
//

import Foundation

//
//  AlbumViewModel.swift
//  Playlist
//
//  Created by Christophe Fiorio on 18/02/2021.
//

import Foundation
import SwiftUI


struct AsyncImage: View {

    @ObservedObject private var track : Track
    
    init(track: Track){
        self.track = track
    }

    var body: some View {
        content
            .onAppear(perform: track.load)
    }
    
    private var content: some View {
        if let image = track.image{
            return Image(uiImage: image).resizable()
        }
        else{
            return Image(uiImage: Track.unknonwCover).resizable()
        }
    }
}

class TrackViewModel: Identifiable, Equatable {
    static func == (lhs: TrackViewModel, rhs: TrackViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    @ObservedObject private(set) var model : Track
    
    var id : Int{
        return model.id
    }
    var name: String?{
        return model.name
    }
    var artist: String{
        return model.artist
    }
    var album: String{
        return model.album
    }
    
    var release : String{
        return model.release
    }

    var image : AsyncImage
    
    init(_ track: Track){
        self.image = AsyncImage(track: track)
        self.model = track
    }
    
}
