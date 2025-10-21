//
//  UrlImage.swift
//  KFWebP
//
//  Created by jsy on 21/10/2025.
//

import SwiftUI
import Kingfisher
import KingfisherWebP

struct UrlImageUIkit:UIViewRepresentable {
    
    let url:URL?
    
    func makeUIView(context: Context) -> UIImageView {
        let animatedView = AnimatedImageView()
        animatedView.contentMode = .scaleAspectFit
        animatedView.backgroundColor = .lightGray
        
        // 设置内容拥抱优先级和抗压缩优先级，让视图遵循外部约束
        animatedView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        animatedView.setContentHuggingPriority(.defaultLow, for: .vertical)
        animatedView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        animatedView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        animatedView.kf.setImage(with: url)
        return animatedView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        
    }
}

struct UrlImage: View {
    let url:URL?
    
    var placeholderImage:Image?
    
    
    var useAnimationImage = false
    /// In List Cell
    /// Loading an image in a list cell is a so common operation. It would be a waste if a cell is already out of screen, but the loading is not done yet. You can use .cancelOnDisappear to cancel any on-going download tasks automatically:
    /// from kf
    /// 在list里 设置为true
    var cancelOnDisappear = false
    
    var contentMode:SwiftUI.ContentMode = .fill
    
    var resizeablePlaceholder:Bool = false
        
    @State private var loading = false
    
    private var isAnimatedImage: Bool {
        guard useAnimationImage else { return false }
        guard let url = url else { return false }
        let path = url.path.lowercased()
        return path.hasSuffix(".webp") || path.hasSuffix(".gif")
    }
    
    @ViewBuilder
    var kf:some View {
        if isAnimatedImage {
            KFAnimatedImage(url)
                .setProcessor(WebPProcessor.default)
                .serialize(by: WebPSerializer.default)
                .placeholder { _ in
                    placehodler
                }
                .onProgress { _, _ in
                    loading = true
                }.onSuccess { result in
                    loading = false
                }.onFailure { error in
                    loading = false
                }
                .cancelOnDisappear(cancelOnDisappear)
        }else {
            KFImage(url)
                .placeholder { _ in
                    placehodler
                }
                .onProgress { _, _ in
                    loading = true
                }.onSuccess { result in
                    loading = false
                }.onFailure { error in
                    loading = false
                }
                .cancelOnDisappear(cancelOnDisappear)
                .resizable()
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            kf
                .aspectRatio(contentMode: contentMode)
                .frame(width: proxy.size.width,height: proxy.size.height)
                .cornerRadius(0)
        }
    }
    
    var placehodler:some View {
        if resizeablePlaceholder {
            placeholderImage?
                .resizable()
        }else {
            placeholderImage
        }
    }
}

#Preview {
    Color.black
        .overlay(
            UrlImage(url: URL(string: "https://assets.langwangapp.com/test/avatar.webp"),useAnimationImage: true)
                .frame(width: 50, height: 50)
        )
}
