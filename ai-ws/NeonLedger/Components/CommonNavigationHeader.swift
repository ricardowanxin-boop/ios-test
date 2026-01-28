import SwiftUI

// 公共导航头部组件
struct CommonNavigationHeader: View {
    let title: String
    let showBackButton: Bool
    let onBack: (() -> Void)?
    let moreButtonIcon: String
    let showMoreButton: Bool
    let onMore: (() -> Void)?
    
    init(
        title: String,
        showBackButton: Bool = false,
        onBack: (() -> Void)? = nil,
        moreButtonIcon: String = "ellipsis", // 默认更多图标
        showMoreButton: Bool = false,
        onMore: (() -> Void)? = nil
    ) {
        self.title = title
        self.showBackButton = showBackButton
        self.onBack = onBack
        self.moreButtonIcon = moreButtonIcon
        self.showMoreButton = showMoreButton
        self.onMore = onMore
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧区域：返回按钮或空占位符
            HStack {
                if showBackButton {
                    Button(action: {
                        onBack?()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.wechatBlack)
                            .frame(width: 40, height: 40)
                            .glassEffect(Glass.regular, in: Circle())
                    }
                    .padding(.leading, 15)
                }
            }
            .frame(minWidth: 50) // 确保左侧区域至少有50宽度
            
            // 中间标题区域，自动伸缩
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.wechatBlack)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center) // 确保标题居中
            
            // 右侧区域：更多按钮或空占位符
            HStack {
                if showMoreButton {
                    Button(action: {
                        onMore?()
                    }) {
                        Image(systemName: moreButtonIcon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.wechatBlack)
                    }
                    .padding(.trailing, 15)
                }
            }
            .frame(minWidth: 50) // 确保右侧区域至少有50宽度
        }
        .padding(.top, 10 + ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 0)) // 适配顶部安全区域
        .padding(.bottom, 10)
        // 视觉升级：毛玻璃背景 + 柔和阴影
        .glassEffect(Glass.regular, in: Rectangle())
        .ignoresSafeArea(edges: .top) // 确保背景延伸到安全区域顶部
    }
}
