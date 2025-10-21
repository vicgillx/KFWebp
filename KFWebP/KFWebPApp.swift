//
//  KFWebPApp.swift
//  KFWebP
//
//  Created by jsy on 21/10/2025.
//

import SwiftUI
import Kingfisher
import KingfisherWebP

@main
struct KFWebPApp: App {
    @State private var show = false
    let webpURL = URL(string: "https://assets.langwangapp.com/test/avatar.webp")
    var body: some Scene {
        WindowGroup {
            Button(action: {
                show.toggle()
            }, label: {
                Text("展示")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
            })
            .sheet(isPresented: $show) {
                Color.black
                    .overlay(
                        VStack {
                            UrlImageUIkit(url: webpURL)
                                .frame(width: 100,height:100)
                            UrlImage(url: webpURL,useAnimationImage: true)
                                .frame(width: 100, height: 100)
                        }

                    )
            }
            .onAppear {
                setupKF()
            }
        }
    }
    
    func setupKF() {
        let modifier = AnyModifier { request in
            var req = request
            req.addValue("image/avif,image/webp,image/apng,*/*", forHTTPHeaderField: "Accept")
            return req
        }
        
        KingfisherManager.shared.defaultOptions += [
            .requestModifier(modifier),
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default),
            // 预加载所有动画帧数据，避免后台恢复时出现像素化问题
            .preloadAllAnimationData
        ]
    }
}
