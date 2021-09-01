//
//  ResultView.swift
//  ResultView
//
//  Created by AlkanBurak on 1.09.2021.
//

import Foundation
import SwiftUI

struct ResultView : View{
    @State var image : UIImage
    @State var radians : CGFloat = 0
    var body: some View{
        VStack{
            Image(uiImage: image).resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
            Button {
                radians += 90
                image = image.rotated(degrees: radians)!
            } label: {
                    Text("Rotate")
                        .foregroundColor(.white)
                        .bold()
                        .padding()
            }
            .frame(width: 100, height: 60)
            .background(Color.black)
            .cornerRadius(10)
            
            Button {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            } label: {
                Text("Save").bold().foregroundColor(.white)
            }.frame(width: 100, height: 60)
                .background(Color.blue)
                .cornerRadius(10)



        }
    }
}
