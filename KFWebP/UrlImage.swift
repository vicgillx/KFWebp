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
    
    
    /// 监听 app 生命周期，用于在从后台恢复时刷新动画图片
    @Environment(\.scenePhase) private var scenePhase

    /// 强制刷新的触发器，用于在 app 从后台恢复时重新加载动画
    @State private var refreshTrigger = UUID()

    /// 记录上一次的 scenePhase，用于判断是否从后台恢复
    @State private var previousScenePhase: ScenePhase?
    
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
                // 配置选项：预加载所有动画帧数据，避免后台恢复时出现像素化
                .configure { view in
                    view.framePreloadCount = .max // 预加载所有帧
                }
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
                // 使用 refreshTrigger 作为 id，当从后台恢复时强制重新加载
                .id(refreshTrigger)
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
        .onChange(of: scenePhase) { newPhase in
            // 当 app 从后台恢复到前台时，刷新动画图片
            // 只有当从 background 切换到 active 时才刷新，避免不必要的重新加载
            if isAnimatedImage &&
               previousScenePhase == .background &&
               newPhase == .active {
                // 更新 refreshTrigger 会触发 KFAnimatedImage 的 id 变化，从而强制重新加载
                refreshTrigger = UUID()
            }
            // 更新上一次的 scenePhase
            previousScenePhase = newPhase
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
