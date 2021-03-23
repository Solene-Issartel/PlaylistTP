//
//  TrackDetail.swift
//  Playlist
//
//  Created by Christophe Fiorio on 21/02/2021.
//

import SwiftUI


struct SearchPlaylistTrackDetailView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.verticalSizeClass) var sizeClass
    
    @ObservedObject  var personalPlaylist : PersonalPlaylistViewModel
    let track : TrackViewModel
    var intent : PersonalListViewIntent


    init(playlist: PersonalPlaylistViewModel, trackViewed: TrackViewModel){
        self.personalPlaylist = playlist
        self.track            = trackViewed
        self.intent = PersonalListViewIntent(playlist: playlist)
    }
    
    var title : String{
        if let song = track.name{
            return "Song: \(song)"
        }
        else{
            return "Album: \(track.album)s"
        }
    }
    var isSong : Bool { return self.track.name != nil }
    var imagesize : CGFloat{
        if sizeClass == .regular { return 80  }
        else                     { return 140 }
    }

    @State var alert = false
    
    var body: some View {
        return VStack{
            Spacer().frame(maxHeight: 10)
            GeometryReader{ geometry in
                HStack{
                    if sizeClass == .regular{ track.image.smallSquare() }
                    else{ track.image.mediumSquare() }
                    GridProperties(properties: [
                        ("Artist",track.artist, true),
                        ("Album",track.album, isSong),
                        ("Release date",track.release, true),
                    ], size: 60).frame(width: geometry.size.width-imagesize, alignment: .trailing)
                }
            }.padding()
            HStack{
                Spacer()
                Button("Add to playlist",action : addTrack)
                .buttonStyle(ImportantButton(disabled: false))
                Spacer()
            }
            Spacer()
        }
        .navigationBarTitle(title, displayMode: .inline)
    }
    
    func saveUserPlaylist(){
        let _ = ITunesTrackHelper.saveUserPlaylist(name: PlaylistApp.keyname, data: self.personalPlaylist.model.tracks)
    }
    
    func addTrack(){
        let track = self.track.model
        self.intent.add(track : track)
    }
    
}

struct SearchPlaylistTrackDetail_Previews: PreviewProvider {
    @ObservedObject static var playlist = PersonalPlaylistViewModel(Playlist())
    static var previews: some View {
        let tvm = TrackViewModel(Track(id: 991509751, name: nil, artist: "Muse", album: "The Resistance", release: "2009-09-14T07:00:00Z", imageUrl: "https://is5-ssl.mzstatic.com/image/thumb/Music1/v4/f5/9f/ec/f59fec5d-5ce1-f226-d7bb-3204eddb9337/source/100x100bb.jpg"))
        return NavigationView{
            SearchPlaylistTrackDetailView(playlist: playlist, trackViewed: tvm)
        }.environmentObject(playlist)
    }
}
