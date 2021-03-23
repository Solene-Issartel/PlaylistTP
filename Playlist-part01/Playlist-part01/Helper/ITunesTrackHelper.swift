//
//  TrackInOutHelper.swift
//  Playlist
//
//  Created by Christophe Fiorio on 22/02/2021.
//

import Foundation

struct ItunesData: Codable {
    var resultCount: Int
    var results: [TrackData]
}

struct TrackData: Codable {
    var trackId: Int?
    var collectionId: Int?
    var trackName: String?
    var artistName: String
    var collectionName: String
    var artworkUrl100: String?
    var releaseDate: String
}

struct ITunesTrackHelper{
    
    static func trackData2Track(data: [TrackData]) -> [Track]?{
        var tracks = [Track]()
        for tdata in data{
            guard (tdata.collectionId != nil) || (tdata.trackId != nil) else{
                return nil
            }
            let id : Int = tdata.trackId ?? tdata.collectionId!
            let track = Track(id: id, name: tdata.trackName, artist: tdata.artistName, album: tdata.collectionName, release: tdata.releaseDate, imageUrl: tdata.artworkUrl100)
            tracks.append(track)
        }
        return tracks
    }
    
    static func track2TrackData(data: [Track]) -> [TrackData]{
        var tracks = [TrackData]()
        for track in data{
            let collectionId : Int?
            let trackId : Int?
            if track.name != nil {
                collectionId = nil
                trackId = track.id
            }
            else{
                collectionId = track.id
                trackId = nil
            }
            let tdata = TrackData(trackId: trackId, collectionId: collectionId, trackName: track.name, artistName: track.artist, collectionName: track.album, artworkUrl100: track.imageUrl, releaseDate: track.release)
            tracks.append(tdata)
        }
        return tracks
    }
    
    
    
    // -------------------------------------------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: load/write json file synchronously
    //
    
    static func loadTracks(fromFile filename: String) -> Result<[Track],HttpRequestError>{
        guard let url = Bundle.main.url(forResource: PlaylistApp.filename, withExtension: nil) else {
            return .failure(.badURL(filename))
        }
        return self.loadTracks(fromFileUrl: url)
    }
    static func loadTracks(fromFileUrl url: URL) -> Result<[Track],HttpRequestError>{
        let result = InOutHelper.loadJsonFile(from: url, dataType: [TrackData].self)
        switch result{
        case let .success(data):
            guard let tracks = self.trackData2Track(data: data) else { return .failure(.JsonDecodingFailed) }
            return .success(tracks)
        case let .failure(error):
            return .failure(error)
        }
    }
    static func writeTracks(toFile filename: String, data: [Track]) -> Result<Int,HttpRequestError>{
        guard let url = Bundle.main.url(forResource: PlaylistApp.filename, withExtension: nil) else {
            return .failure(.badURL(filename))
        }
        return self.writeTracks(toFileUrl: url, data: data)
    }
    static func writeTracks(toFileUrl url: URL, data: [Track]) -> Result<Int,HttpRequestError>{
        let tracks = self.track2TrackData(data: data)
        return InOutHelper.writeJsonFile(fileUrl: url, data: tracks)
    }
    
    static func loadUserPlaylist(name: String) -> Result<[Track],HttpRequestError>{
        guard let data = UserDefaults.standard.data(forKey: name) else { return .failure(.requestFailed)}
        guard let decoded = try? JSONDecoder().decode([TrackData].self, from: data) else { return .failure(.JsonEncodingFailed) }
        guard let tracks = self.trackData2Track(data: decoded) else { return .failure(.JsonEncodingFailed) }
        return .success(tracks)
    }
    
    static func saveUserPlaylist(name: String, data: [Track]) -> Result<Int,HttpRequestError>{
        let tracks = self.track2TrackData(data: data)
        guard let encoded = try? JSONEncoder().encode(tracks) else { return .failure(.JsonDecodingFailed) }
        UserDefaults.standard.set(encoded, forKey: name)
        return .success(encoded.count)
    }
    
    // -------------------------------------------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: load/write json data asynchronously
    //
    static func loadTracksPlaylist(from filename: String, endofrequest: @escaping (Result<[Track],HttpRequestError>) -> Void){
        DispatchQueue.main.async {
            if let data = UserDefaults.standard.data(forKey: filename) {
                guard let decoded = try? JSONDecoder().decode([TrackData].self, from: data) else {
                    endofrequest(.failure(.JsonDecodingFailed))
                    return
                }
                guard let tracks = self.trackData2Track(data: decoded) else {
                    endofrequest(.failure(.JsonDecodingFailed))
                    return
                }
                endofrequest(.success(tracks))
            }
            loadTracksAsync(fromFile: filename, endofrequest: endofrequest)
        }
    }
    
    static func loadTracksAsync(fromUrl surl: String, endofrequest: @escaping (Result<[Track],HttpRequestError>) -> Void){
        guard let url = URL(string: surl) else {
            endofrequest(.failure(.badURL(surl)))
            return
        }
        self.loadTracksAsync(fromUrl: url, endofrequest: endofrequest)
    }
    
    static func loadTracksAsync(fromFile filename: String, endofrequest: @escaping (Result<[Track],HttpRequestError>) -> Void){
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            endofrequest(.failure(.badURL(filename)))
            return
        }
        self.loadTracksAsync(fromUrl: url, endofrequest: endofrequest)
    }
    
    static func loadTracksAsync(fromUrl url: URL, endofrequest: @escaping (Result<[Track],HttpRequestError>) -> Void){
        self.loadTracksFromJsonData(url: url, endofrequest: endofrequest, ItuneApiRequest: false)
    }
    
    static func loadTracksFromAPI(url surl: String, endofrequest: @escaping (Result<[Track],HttpRequestError>) -> Void){
        guard let url = URL(string: surl) else {
            endofrequest(.failure(.badURL(surl)))
            return
        }
        self.loadTracksFromAPI(url: url, endofrequest: endofrequest)
    }
    static func loadTracksFromAPI(url: URL, endofrequest: @escaping (Result<[Track],HttpRequestError>) -> Void){
        self.loadTracksFromJsonData(url: url, endofrequest: endofrequest, ItuneApiRequest: true)
    }

    private static func loadTracksFromJsonData(url: URL, endofrequest: @escaping (Result<[Track],HttpRequestError>) -> Void, ItuneApiRequest: Bool = true){
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decodedData : Decodable?
                if ItuneApiRequest{
                    decodedData = try? JSONDecoder().decode(ItunesData.self, from: data)
                }
                else{
                    decodedData = try? JSONDecoder().decode([TrackData].self, from: data)
                }
                guard let decodedResponse = decodedData else {
                    DispatchQueue.main.async { endofrequest(.failure(.JsonDecodingFailed)) }
                    return
                }
                var tracksData : [TrackData]
                if ItuneApiRequest{
                    tracksData = (decodedResponse as! ItunesData).results
                }
                else{
                    tracksData = (decodedResponse as! [TrackData])
                }
                guard let tracks = self.trackData2Track(data: tracksData) else{
                    DispatchQueue.main.async { endofrequest(.failure(.JsonDecodingFailed)) }
                    return
                }
                DispatchQueue.main.async {
                    endofrequest(.success(tracks))
                }
            }
            else{
                DispatchQueue.main.async {
                    if let error = error {
                        guard let error = error as? URLError else {
                            endofrequest(.failure(.unknown))
                            return
                        }
                        endofrequest(.failure(.failingURL(error)))
                    }
                    else{
                        guard let response = response as? HTTPURLResponse else{
                            endofrequest(.failure(.unknown))
                            return
                        }
                        guard response.statusCode == 200 else {
                            endofrequest(.failure(.requestFailed))
                            return
                        }
                        endofrequest(.failure(.unknown))
                    }
                }
            }
        }.resume()
    }


    static func writeTracksData(fileUrl url: URL, data: [Track], endofrequest: @escaping (Result<Int,HttpRequestError>) -> Void){
        let tracks = self.track2TrackData(data: data)
        InOutHelper.writeJsonData(fileUrl: url, data: tracks, endofrequest: endofrequest)
    }

    static func writeTracksData(filename: String, data: [Track], endofrequest: @escaping (Result<Int,HttpRequestError>) -> Void){
        let tracks = self.track2TrackData(data: data)
        InOutHelper.writeJsonData(filename: filename, data: tracks, endofrequest: endofrequest)
    }

}
