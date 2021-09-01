//
//  ContentView.swift
//  TransferApp
//
//  Created by AlkanBurak on 29.08.2021.
//

import SwiftUI
import CreateML
import CoreML
import Vision






struct ContentView: View {
    @State var iterations : Double = 20
    @State var styleStrenght : Double = 5
    @State var textelDensity : Double = 256
    @State var cnn : Bool = false
    @State var cnnLite : Bool = true

    @State var styleImage: UIImage?
    @State var contentImage: UIImage?
    
    @State var showStyleImagePicker = false
    @State var showContentImagePicker = false
    
    @State var result : UIImage?
    @State var show = false
    
    var body: some View {
        ZStack{
            if result != nil {
                Image(uiImage: result!)
                    .frame(width: 0, height: 0)
                    .opacity(0)
            }
            VStack{
                Spacer()
                HStack{
                    VStack(alignment: .leading){
                        Text("Style Image").bold()
                        Button {
                            showStyleImagePicker.toggle()
                        } label: {
                            if styleImage != nil {
                                Image(uiImage: styleImage!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    
                            }else{
                                VStack{
                                    Image(systemName: "plus")
                                        .resizable().frame(width: 50, height: 50)
                                        .foregroundColor(.white)
                                
                                    Text("Select Photo")
                                        .bold()
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .frame(width: 150, height: 150)
                        .background(styleImage == nil ? Color.gray.opacity(0.6) : Color.clear)
                        .sheet(isPresented: $showStyleImagePicker) {
                            ImagePicker(sourceType: .photoLibrary) { image in
                                styleImage = image
                             //q   _ = savePng(styleImage!)
                                
                            }
                        }
                    }.padding()
                    
                    VStack(alignment: .leading){
                        Text("Filter Image").bold()
                        Button {
                            showContentImagePicker.toggle()
                        } label: {
                            if contentImage != nil {
                                Image(uiImage: contentImage!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    
                            }else{
                                VStack{
                                    Image(systemName: "plus")
                                        .resizable().frame(width: 50, height: 50)
                                        .foregroundColor(.white)
                                
                                    Text("Select Photo")
                                        .bold()
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .frame(width: 150, height: 150)
                        .background(contentImage == nil ? Color.gray.opacity(0.6) : Color.clear)
                        .sheet(isPresented: $showContentImagePicker) {
                            ImagePicker(sourceType: .photoLibrary) { image in
                                contentImage = image
                                _ = savePng(contentImage!)
                            }
                        }
                    }.padding()
                    
                }
                VStack(alignment: .leading){
                    Text("Iterations: \(Int(iterations))")
                        .bold()
                        .padding(.leading)
                    Slider(value: $iterations, in: 1...200).padding([.leading,.trailing])
                    Text("Style Strength: \(Int(styleStrenght))")
                        .bold()
                        .padding(.leading)
                    Slider(value: $styleStrenght, in: 1...10).padding([.leading,.trailing])
                    Text("Textel Density: \(Int(textelDensity))")
                        .bold()
                        .padding(.leading)
                    Slider(value: $textelDensity, in: 64...564).padding([.leading,.trailing])
                    Text("Algorithm Type")
                        .bold()
                        .padding(.leading)
                    HStack{
                        Toggle("CNN", isOn: $cnn)
                            .toggleStyle(ButtonToggleStyle())
                            .onChange(of: cnn) { type in
                            if type { cnnLite = false}
                        }
                        Toggle("CNN Lite", isOn: $cnnLite)
                            .toggleStyle(ButtonToggleStyle())
                            .onChange(of: cnnLite) { type in
                            if type { cnn = false}
                        }
                    }.padding(.leading)
                }
                Spacer()
                Button {
                    train()
                    show.toggle()
                    
                } label: {
                    Text("Apply Filter")
                        .bold()
                        .foregroundColor(.white)
                }
                .sheet(isPresented: $show, content: {
                    ResultView(image: result ?? UIImage(named: "modernTalking.jpg")!)
                })
                .frame(width: 120, height: 60)
                .background(Color.black)
                .cornerRadius(20)
                .padding(.bottom , 40)


            }}
    }
    
    func train() {
                
        _ = savePng(contentImage!)
        //Style Transfer uygalancak görsel "styleImage" , içerik resimleri de "contentDirectory" ile belirtilir ve modelin eğiteleceği data bu değişkenle oluşturulur
        let data = MLStyleTransfer.DataSource.images(styleImage: (documentDirectoryPath()?.appendingPathComponent("examplePng.png"))!, contentDirectory: FileManager.default.urls(for: .documentDirectory,in: .userDomainMask).first!)
        
        // Bu satırda model eğitilmeye başlanır ve bu işlem uygulama ile senkron bir şekilde tamamlanır
        // Parametrelerde değişiklik yaparak da modelin eğitim süresi değiştirilebilir
        // styleStrength [1,10] aralığında bir değer almalıdır
        // textelDensity [64,1024] aralığında bir değer almalıdır. textelDensity düşürülerek modelin eğitilmesi hızlanır fakat kalite düşer, yükselmesi halinde fotoğrafın kalitesi artar ancak çökmede yaşanılabilir.
        let model = try! MLStyleTransfer(trainingData: data , parameters: MLStyleTransfer.ModelParameters.init(algorithm: cnnLite ? .cnnLite : .cnn ,maxIterations: Int(iterations) , textelDensity: Int(textelDensity) , styleStrength: Int(styleStrenght) ))
        
        //Oluşan modeli belirtilen dosya konumuna yazdırır
        try! model.write(to: documentDirectoryPath()!)
        
        
        let ciImage = CIImage(image: styleImage!)
        let cgImage =  convertCIImageToCGImage(inputImage: ciImage!)!
        
        //stylize fonksiyonu ile belirtilen görselin çıktısı alınabilir
        let imageResult =  try! model.stylize(image: cgImage)
        
        print(model.description)
        
        result = UIImage(cgImage: imageResult!)
                    
        
        
    }
    
        func savePng(_ image: UIImage) -> URL {
            if let pngData = image.pngData(),
               let path = documentDirectoryPath()?.appendingPathComponent("examplePng.png") {
                try? pngData.write(to: path)
                return path
            }
                return URL(string: "")!
        }
    
    
    
    
    
        func documentDirectoryPath() -> URL? {
            let path = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask)
            return path.first
        }
        
    
 
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        if context != nil {
            return context.createCGImage(inputImage, from: inputImage.extent)
        }
        return nil
    }
}

