//
//  ViewStyles.swift
//  Playlist
//
//  Created by Christophe Fiorio on 21/02/2021.
//

import Foundation
import SwiftUI

extension Color{
    static let backgroundForm     = Color("WhiteFog")
    static let textFieldTextColor = Color("MarineBlue")
    static let textInfo           = Color("RoyalPurple")
    static let lightBlue          = Color("LightBlue")
    static let marineBlue         = Color("MarineBlue")
    static let whiteFog           = Color("WhiteFog")
    static let royalPurple        = Color("RoyalPurple")
    static let lightGray          = Color("lightGray")
}

extension Text{
    func errorStyle() -> some View{
        self
            .foregroundColor(.red)
            .font(.title)
    }
    
    func noteStyle() -> some View{
        self
            .italic()
            .foregroundColor(.gray)
    }
}


extension View {
    func smallSquare() -> some View{
        self
            .frame(width: 60, height: 60, alignment: .center)
            .aspectRatio(contentMode: .fit)
    }
    func mediumSquare() -> some View{
        self
            .frame(width: 120, height: 120, alignment: .top)
            .aspectRatio(contentMode: .fit)
    }
}


struct PropertyName : View{
    let name :  String
    let value : String
    var body: some View{
        HStack{
            Text(name).padding()
            Text(value)
            Spacer()
        }
    }
}

struct PropertySized : View{
    let name :  String
    let value : String
    let size : CGFloat
    let columns : [GridItem]
    init(name:  String, value: String, size: CGFloat){
        self.name = name
        self.value = value
        self.size = size
        self.columns = [
            GridItem(.fixed(size),spacing: 0),
            GridItem(.fixed(5),spacing: 10),
            GridItem(.flexible(minimum: size),spacing: 0)
        ]
    }
    var body: some View{
        LazyVGrid(columns: columns, alignment: .leading){
            Text(name)
            Text(":")
            Text(value)
        }
    }
}


struct ImportantButton: ButtonStyle {
    let disabled : Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .accentColor(.marineBlue)
            .foregroundColor(configuration.isPressed ? .red : (disabled ? .lightGray : .accentColor) )
            .padding(8)
            .background(
                RoundedRectangle(
                    cornerRadius: 8,
                    style: .continuous
                )
                .stroke(disabled ? Color.lightGray : Color.marineBlue)
                .background(disabled ? Color.whiteFog : Color.lightBlue)
        )
    }
}


struct GridProperties : View{
    let properties :  [(name: String, value: String, display: Bool)]
    let size : CGFloat
    let columns : [GridItem]
    init(properties:  [(name: String, value: String, display: Bool)], size: CGFloat){
        self.properties = properties
        self.size = size
        self.columns = [
            GridItem(.fixed(size),spacing: 0),
            GridItem(.fixed(5),spacing: 10),
            GridItem(.flexible(minimum: size),spacing: 0)
        ]
    }
    var body: some View{
        LazyVGrid(columns: columns, alignment: .leading){
            ForEach(properties, id: \.self.name){ p in
                if p.display{
                    Text(p.name)
                    Text(":")
                    Text(p.value)
                }
            }
        }
    }
}

