//
//  ContentView.swift
//  Playlist
//
//  Created by Christophe Fiorio on 18/02/2021.
//

import SwiftUI
import Combine

struct SearchListView: View {
    
    @EnvironmentObject var personalPlaylist : PersonalPlaylistViewModel
    
    /*
     * If searchPlaylist is initialized here, we must ensure that intent initialized here stays the same with the initial playlist
     * Else intent could manage another playlist if struct is reinit
     * The way to do that is a bit complicated but possible (see solution in comment below)
     * So the best is to pass searchPlaylist in parameter so, even if struct is reinit and intent recreated, it will manage the good searchplaylist
     *
    // MUST be a StateObject to stay the same and not being reallocated if struct is reinit
    @StateObject var searchPlaylist : SearchPlaylistViewModel
    // MUST be a StateObject to stay the same and not being reallocated if struct is reinit
    @StateObject var intent : SearchListViewIntent

    
    /// initialize view: create the search playlist and the intent of the view
    init(){
        let playlist    = SearchPlaylistViewModel(Playlist()) // create a searchList
        _searchPlaylist = StateObject(wrappedValue: playlist) // if searchPlaylist has already been allocated, this statement has no effect
        _intent         = StateObject(wrappedValue: SearchListViewIntent(playlist: playlist)) // same thing for intent
        // note : if intent whas not a StateObject, when struct is reallocated, a new intent is created with local playlist created here, and so
        // intent will no more manage the initial playlist!
    }
     */
    
    @ObservedObject var searchPlaylist : SearchPlaylistViewModel
    var intent : SearchListViewIntent
    
    init(searchPlaylist: SearchPlaylistViewModel){
        self.searchPlaylist = searchPlaylist
        self.intent = SearchListViewIntent(playlist: searchPlaylist)
        let _  = self.searchPlaylist.$playListState.sink(receiveValue: stateChanged)
    }


    private var searchState : SearchPlayListState{
        return self.searchPlaylist.playListState
    }
    
    @State private var showModal      = false
    @State var detailPresented : Bool = false
    @State var revealSearchForm: Bool = false
    @State var textSearch             = ""
    
    /// Use to fake DetailView when displayed in DisclosureGroupe as DetailView need such bool when used in Modal view
    @State var dumbPresented : Bool = true
    
    
    var tracks : [TrackViewModel] {
        return self.searchPlaylist.tracks
    }
    
    private func filterSearch(track: TrackViewModel) -> Bool{
        var ret = true
        if !textSearch.isEmpty {
            ret = false
            if let name = track.name{
                ret = ret || name.contains(textSearch)
            }
            ret = ret || track.album.contains(textSearch)
            ret = ret || track.artist.contains(textSearch)
        }
        return ret
    }
    
    func stateChanged(state: SearchPlayListState){
        #if DEBUG
        debugPrint("SearchListView -> searchList state : \(state)")
        debugPrint("SearchListView -> formViewOpen=\(searchPlaylist.formViewOpen)")
        #endif
        switch state {
        case .newTracks:
            self.intent.trackLoaded()
        default:
            break
        }
    }

    var body: some View {
//        stateChanged(state: searchPlaylist.playListState)
        return NavigationView{
            VStack{
                TextField("term filter", text: $textSearch).font(.footnote)
                Spacer()
                ZStack{
                    List{
                        ForEach(self.searchPlaylist.tracks.filter(filterSearch)){ track in
                            NavigationLink(destination: SearchPlaylistTrackDetailView(playlist: personalPlaylist, trackViewed: track)){
                                ListRow(track: track)
                            }
                        }
                    }
                    if tracks.count == 0{
                        VStack{
                            Spacer()
                            Text("No tracks")
                            Spacer()
                        }
                    }
                    ErrorView(state: searchState)
                }
                VStack{
                    DisclosureGroup("Search form", isExpanded: $searchPlaylist.formViewOpen){
                        VStack{
                            SearchFormDisclosureView(intent: self.intent)
                        }
                    }
                }
                .padding(10)
                .background(Color.backgroundForm)
            }
            .navigationTitle("Search list tracks")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SearchListView_Previews: PreviewProvider {
    static var previews: some View {
        SearchListView(searchPlaylist: SearchPlaylistViewModel(Playlist()))
    }
}

struct ListRow : View{
    let track : TrackViewModel
    var body: some View{
        HStack{
            track.image.smallSquare()
            VStack(alignment: .leading){
                if let name = track.name { Text(name).font(.title2) }
                Text(track.album)
                    .font(.headline)
                Text(track.artist)
            }
        }
    }
}

struct ErrorView : View{
    let state : SearchPlayListState
    var body: some View{
        VStack{
            Spacer()
            switch state{
            case .loading, .loaded:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(3)
            case .loadingError(let error):
                ErrorMessage(error: error)
            default:
                EmptyView()
            }
            if case let .loaded(data) = state{
                Text("\(data.count) tracks found!")
            }
            Spacer()
        }
    }
}




struct ErrorMessage : View{
    let error :  Error
    var body: some View{
        VStack{
            Text("Error in search request")
                .errorStyle()
            if let error = error  as? HttpRequestError {
                Text("\(error.description)")
                    .noteStyle()
            }
            else{
                Text("Unknown error")
                    .errorStyle()
            }
        }
    }
}

