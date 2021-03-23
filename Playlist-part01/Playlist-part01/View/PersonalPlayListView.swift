//
//  PersonalPlayList.swift
//  Playlist
//
//  Created by Christophe Fiorio on 21/02/2021.
//

import SwiftUI


struct PersonalPlayListView: View {
    /// the personal playlist to be displayed
    @ObservedObject var personalPlaylist : PersonalPlaylistViewModel
    
    /// view of personal playlist
    var body: some View {
        // then return view
        return NavigationView{
            VStack{
                Text("Personal playlist view")
                Spacer()
                ZStack{
                    List{
                        ForEach(self.personalPlaylist.model.tracks) {
                            track in
                            Text("Artist : \(track.artist)")
                        }
                    }
                    if self.personalPlaylist.model.tracks.count == 0{
                        VStack{
                            Spacer()
                            Text("No tracks")
                            Spacer()
                        }
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        }}
}


struct PersonalPlayList_Previews: PreviewProvider {
    static var playlist = PersonalPlaylistViewModel(Playlist())
    static var previews: some View {
        PersonalPlayListView(personalPlaylist: playlist)
    }
}
