//
//  InOutHelper.swift
//  Playlist
//
//  Created by Christophe Fiorio on 20/02/2021.
//

import Foundation
import Combine

enum HttpRequestError : Error, CustomStringConvertible{
    case fileNotFound(String)
    case badURL(String)
    case failingURL(URLError)
    case requestFailed
    case outputFailed
    case JsonDecodingFailed
    case JsonEncodingFailed
    case initDataFailed
    case unknown
    
    var description : String {
        switch self {
        case .badURL(let url): return "Bad URL : \(url)"
        case .failingURL(let error): return "URL error : \(error.failureURLString ?? "")\n \(error.localizedDescription)"
        case .requestFailed: return "Request Failed"
        case .outputFailed: return "Output data Failed"
        case .JsonDecodingFailed: return "JSON decoding failed"
        case .JsonEncodingFailed: return "JSON encoding failed"
        case .initDataFailed: return "Bad data format: initialization of data failed"
        case .unknown: return "unknown error"
        case .fileNotFound(let filename): return "File \(filename) not found"
        }
    }
}

// -------------------------------------------------------------------------------------------------------------------------------
// MARK: -
// MARK: Function definition

class InOutHelper {
    
    // -------------------------------------------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: load/write json file synchronously
    //
    static func loadJsonFile<T: Decodable>(from url: URL, dataType: T.Type) -> Result<T,HttpRequestError>{
        guard let data = try? Data(contentsOf: url) else {
            return .failure(.requestFailed)
        }
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(T.self, from: data) else {
            return .failure(.JsonDecodingFailed)
        }
        return .success(decoded)
    }
    static func writeJsonFile<T: Encodable>(fileUrl url: URL, data: [T]) -> Result<Int,HttpRequestError>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try? encoder.encode(data)
        guard let jsonData = json else {
            return .failure(.JsonEncodingFailed)
        }
        guard let _ = try? jsonData.write(to: url) else{
            return .failure(.outputFailed)
        }
        return .success(jsonData.count)
    }

    // -------------------------------------------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: read json data asynchronously from an url (file or http)
    //
    
    
    /// read json data asynchronously from an url (file or http)
    /// - Parameters:
    ///   - url: source of data
    ///   - endofrequest: closure that will handle result of request, error or returned data
    static func getJsonData<T: Decodable>(from url: URL, endofrequest: @escaping (Result<T,HttpRequestError>) -> Void){
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decodedData = try? JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    guard let decodedResponse = decodedData else {
                        endofrequest(.failure(.JsonDecodingFailed))
                        return
                    }
                    endofrequest(.success(decodedResponse))
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

    static func httpGetJsonData<T: Decodable>(from surl: String, endofrequest: @escaping (Result<T,HttpRequestError>) -> Void){
        guard let url = URL(string: surl) else {
            endofrequest(.failure(.badURL(surl)))
            return
        }
        getJsonData(from: url, endofrequest: endofrequest)
    }

    static func fileGetJsonData<T: Decodable>(filename: String, endofrequest: @escaping (Result<T,HttpRequestError>) -> Void){
        guard let url = Bundle.main.url(forResource: PlaylistApp.filename, withExtension: nil) else {
            endofrequest(.failure(.badURL(filename)))
            return
        }
        getJsonData(from: url, endofrequest: endofrequest)
    }

    
    // -------------------------------------------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: write json data asynchronously to a file
    //
        
    static func writeJsonData<T: Encodable>(fileUrl url: URL, data: [T], endofrequest: @escaping (Result<Int,HttpRequestError>) -> Void){
        DispatchQueue.main.async {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let json = try? encoder.encode(data)
            guard let jsonData = json else {
                endofrequest(.failure(.JsonEncodingFailed))
                return
            }
            guard let _ = try? jsonData.write(to: url) else{
                endofrequest(.failure(.requestFailed))
                return
            }
            endofrequest(.success(jsonData.count))
        }
    }

    static func writeJsonData<T: Encodable>(filename: String, data: [T], endofrequest: @escaping (Result<Int,HttpRequestError>) -> Void){
        DispatchQueue.main.async {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let json = try? encoder.encode(data)
            guard let jsonData = json else {
                endofrequest(.failure(.JsonEncodingFailed))
                return
            }
            UserDefaults.standard.set(jsonData, forKey: filename)
            endofrequest(.success(jsonData.count))
        }
    }



    // -------------------------------------------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: write json data asynchronously to a file
    //
        
    static func httpGetObject<T>(from surl: String, initFromData: @escaping (Data) -> T?, endofrequest: @escaping (Result<T,HttpRequestError>) -> Void){
        guard let url = URL(string: surl) else {
            endofrequest(.failure(.badURL(surl)))
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    guard let result = initFromData(data) else {
                        endofrequest(.failure(.initDataFailed))
                        return
                    }
                    endofrequest(.success(result))
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
    
    
    
    // -------------------------------------------------------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------------------------------------------------------
    // ------------------------------------------- To be deleted? --------------------------------------------------------------------
    // -------------------------------------------------------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------------------------------------------------------

    
    
    // -------------------------------------------------------------------------------------------------------------------------------
    // MARK: -
    //
    // solution with combine dataTask Publisher
    // -> requires to store and retain cancellable subscriber -> not a good idea if we want to reuse httpGet request several times in //
    // -> perhaps for search request if we want to ensure that only one request (the last one) is performed
    // -> clearly not a good idea for images
        
    
    static var tracksRequest : AnyCancellable? // dataTaskPublished need a retained cancellable!
    
    static func httpGetJsonDataCombine<T: Decodable>(from surl: String, endofrequest: @escaping (Result<T,HttpRequestError>) -> Void){
        imageRequest.removeAll()
        guard let url = URL(string: surl) else {
            DispatchQueue.main.async { endofrequest(.failure(.badURL(surl))) } // if we want change property, that has to be done on main queue
            return
        }
        let request = URLRequest(url: url)
        tracksRequest = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else{
                    throw HttpRequestError.unknown
                }
                guard response.statusCode == 200 else {
                    throw HttpRequestError.requestFailed
                }
                return output.data
            }
            .mapError{ error -> HttpRequestError in
                if let error = error as? HttpRequestError {
                    return error
                }
                if let error = error as? URLError{
                    return HttpRequestError.failingURL(error)
                }
                else{
                    return HttpRequestError.unknown
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError{ error -> HttpRequestError in
                if let error = error as? HttpRequestError { return error }
                else if let _ = error as? DecodingError { return HttpRequestError.JsonDecodingFailed }
                else {
                    return HttpRequestError.unknown
                }
            }
            .receive(on: DispatchQueue.main) // if we want change property, that has to be done on main queue
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    endofrequest(.failure(error))
                }
            }, receiveValue: { data in
                endofrequest(.success(data))
            })
    }
    
    static var imageRequest = [AnyCancellable]() // dataTaskPublished need a retained cancellable and we will load several images in // !

    static func httpGetObjectCombine<T>(from surl: String, initFromData: @escaping (Data) -> T?, endofrequest: @escaping (Result<T,HttpRequestError>) -> Void){
        guard let url = URL(string: surl) else {
            DispatchQueue.main.async { endofrequest(.failure(.badURL(surl))) } // if we want change property, that has to be done on main queue
            return
        }
        let request = URLRequest(url: url)
        imageRequest.append(
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { output -> Data in
                    guard let response = output.response as? HTTPURLResponse else{
                        throw HttpRequestError.unknown
                    }
                    guard response.statusCode == 200 else {
                        throw HttpRequestError.requestFailed
                    }
                    guard output.data.count > 0  else {
                        throw HttpRequestError.initDataFailed
                    }
                    return output.data
                }
                .mapError{ error -> HttpRequestError in
                    if let error = error as? HttpRequestError {
                        return error
                    }
                    if let error = error as? URLError{
                        return HttpRequestError.failingURL(error)
                    }
                    else{
                        return HttpRequestError.unknown
                    }
                }
                .receive(on: DispatchQueue.main) // if we want change property, that has to be done on main queue
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        endofrequest(.failure(error))
                    }
                }, receiveValue: { data  in
                    guard let result = initFromData(data) else {
                        endofrequest(.failure(.initDataFailed))
                        return
                    }
                    endofrequest(.success(result))
                })
        )
    }

}

