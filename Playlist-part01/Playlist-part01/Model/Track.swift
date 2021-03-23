//
//  Album.swift
//  Playlist
//
//  Created by Christophe Fiorio on 18/02/2021.
//

import Foundation
import SwiftUI
import Combine


// ajouter trackId et albumId
// id devient calculé en fonction si song ou album
// init album et init song

class Track : Identifiable, ObservableObject, Encodable, Equatable{
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    static let unknonwCover : UIImage = UIImage(systemName: "questionmark.square.fill")!
    
    /// id of the track
    private(set) var id : Int
    /// name of the track (song)
    ///
    /// could have no name if track is for one entire album
    private(set) var name: String?
    /// artist of the song
    private(set) var artist: String
    /// album where this song has been published
    private(set) var album: String
    /// release date of this track
    private(set) var release: String
    /// string url of cover album image
    private(set) var imageUrl: String?{
        didSet{
            self.load()
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case name = "trackName"
        case artist = "artistName"
        case album = "collectionName"
        case release = "releaseDate"
        case imageUrl = "artworkUrl100"
//        var collectionId: Int
    }

    /// album cover
    @Published var image: UIImage?
    
    /// for testing purpose: to be deleted
    private var backupurl : String?
    
    /// initialization of a track
    /// - Parameters:
    ///   - id: unique id
    ///   - name: name of the song
    ///   - artist: artist name
    ///   - album: album name
    ///   - release: release date of the track
    ///   - imageUrl: url of image cover
    init(id: Int, name: String?, artist: String, album: String, release: String, imageUrl: String? =  nil){
        self.id      = id
        self.name    = name
        self.artist  = artist
        self.album   = album
        self.release = release
        self.imageUrl = name == "Starlight" ? nil : imageUrl // for testing asynchronous image loading
        self.backupurl = imageUrl                            //  -> keep url in backup for reuse later
        if self.imageUrl == nil {                            //  -> if url test, then
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {  // 3 second later
                self.imageUrl = self.backupurl                   // restoring url will trigger image loading, hopefully
            }
        }
    }
    /// initialization of a track
    /// - Parameters:
    ///   - id: unique id
    ///   - name: name of the song
    ///   - artist: artist name
    ///   - album: album name
    ///   - release: release date
    ///   - image: album cover image
    convenience init(id: Int, name: String?, artist: String, album: String, release: String, image: UIImage){
        self.init(id: id, name: name, artist: artist, album: album, release: release)
        self.image = image
    }
    
    private func imageLoaded(result: Result<UIImage,HttpRequestError>){
        switch result{
        case let .success(data):
            self.image = data
        case .failure(_):
            self.image = Self.unknonwCover
        }
    }

    func load(){
        guard let url = self.imageUrl else {
            self.image = Self.unknonwCover
            return            
        }
        InOutHelper.httpGetObject(from: url, initFromData: { (data: Data) -> UIImage? in return UIImage(data: data) }, endofrequest: imageLoaded)
    }

}
