//
//  SearchFormView.swift
//  Playlist
//
//  Created by Christophe Fiorio on 21/02/2021.
//

import SwiftUI




struct SearchFormDisclosureView: View {
    
    /// Intent to manage search form view
    var intent : SearchListViewIntent

    /// string recording term to search
    @State var searchTerm : String = ""
    /// true if we look for album, false for songs
    @State var searchForAlbum : Bool = false
    /// true if term relates to artist's name, false if we look term into title of song ou album name
    @State var searchForArtist : Bool = true
    
    private var searchForAlbumTitle : String{
        return searchForAlbum ? "Albums" : "Songs"
    }
    private var searchForArtistTitle : String{
        return searchForArtist ? "Artist name" : (searchForAlbum ? "Album title" : "Song title")
    }
    private var searchCaption : String{
        guard !searchTerm.isEmpty else { return " " }
        return "search for \(searchForAlbum ? "albums" : "songs") with \(searchTerm) \(searchForArtist ? "as artist" : "in title")"
    }
    private var entity : String{
        return searchForAlbum ? "album" : "song"
    }
    private var attribute : String{
        return searchForArtist ? "artistTerm" : (searchForAlbum ? "albumTerm" : "songTerm")
    }
    private var url : String?{
        guard !searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else{ return nil }
        guard let searchTermUrl = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        return "https://itunes.apple.com/search?term=\(searchTermUrl)&entity=\(entity)&attribute=\(attribute)&limit=200"
    }
    
    var body: some View {
        VStack{
            Section{
                Toggle(searchForAlbumTitle, isOn: $searchForAlbum)
                Toggle(searchForArtistTitle, isOn: $searchForArtist)
                HStack{
                    Text(searchCaption).foregroundColor(.textInfo).italic()
                    Spacer()
                }
                TextField("search term", text: $searchTerm)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.textFieldTextColor)
                    .padding(10)
            }
            Section{
//                Text(url ?? "").font(.footnote)
//                    .padding()
                HStack{
                    Spacer()
                    Button("Search for tracks", action: searchAction)
                        .disabled(searchTerm.isEmpty)
                        .buttonStyle(ImportantButton(disabled: searchTerm.isEmpty))
                        .keyboardShortcut(.defaultAction)
                    Spacer()
                }
                
            }
            Spacer()
        }
    }
    
    func searchAction(){
        if let url = url{
            #if DEBUG
            debugPrint("searFormDisclosure: loadPlaylist(url: \(url))")
            #endif
            self.intent.loadPlaylist(url: url, artistFilter: searchForArtist ? searchTerm : nil)
        }
    }
}

struct SearchFormDisclosureViewAction_Previews: PreviewProvider {
    @State static var isPresented = true
    
    static var previews: some View {
        Group {
            NavigationView{
                SearchFormDisclosureView(intent: SearchListViewIntent(playlist: SearchPlaylistViewModel(Playlist())))
            }
            NavigationView{
                SearchFormDisclosureView(intent: SearchListViewIntent(playlist: SearchPlaylistViewModel(Playlist())))
            }
        }
    }
}
