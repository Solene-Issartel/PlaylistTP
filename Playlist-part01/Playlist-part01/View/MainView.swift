//
//  MainView.swift
//  Playlist
//
//  Created by Christophe Fiorio on 21/02/2021.
//

import SwiftUI

struct MainView: View {
    /// personal playlist, the one that is edited and saved
    @EnvironmentObject var personalPlaylist : PersonalPlaylistViewModel
    /// search list used by SearchListView
    @StateObject var searchPlaylist   : SearchPlaylistViewModel   = SearchPlaylistViewModel(Playlist())

    /// which tab appear selected
    @State private var tabSelected  = 1
    
    var body: some View {
        TabView(selection: $tabSelected){
            SearchListView(searchPlaylist: searchPlaylist)
                .tabItem{
                    Label("Search", systemImage: "rectangle.and.text.magnifyingglass")
                }.tag(0)
            PersonalPlayListView(personalPlaylist: personalPlaylist)
                .tabItem{
                    Label("Playlist", systemImage: "list.dash")
                }.tag(1)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(SearchPlaylistViewModel(Playlist()))
    }
}
