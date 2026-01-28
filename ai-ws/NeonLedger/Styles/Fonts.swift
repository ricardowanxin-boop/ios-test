import SwiftUI

// 微信iOS风格字体体系
extension Font {
    // 标准系统字体 - 微信风格
    static let wechatSmall = Font.system(size: 12, weight: .regular)
    static let wechatMedium = Font.system(size: 14, weight: .regular)
    static let wechatRegular = Font.system(size: 16, weight: .regular)
    static let wechatSemiBold = Font.system(size: 16, weight: .semibold)
    static let wechatBold = Font.system(size: 18, weight: .bold)
    static let wechatLarge = Font.system(size: 20, weight: .bold)
}

// 文本样式
extension Text {
    // 微信标准文本样式
    func wechatPrimaryStyle() -> some View {
        self
            .font(.wechatRegular)
            .foregroundColor(.wechatGray)
    }
    
    func wechatSecondaryStyle() -> some View {
        self
            .font(.wechatMedium)
            .foregroundColor(.wechatLightGray)
    }
    
    func wechatBoldStyle() -> some View {
        self
            .font(.wechatBold)
            .foregroundColor(.wechatBlack)
    }
    
    func wechatTitleStyle() -> some View {
        self
            .font(.wechatLarge)
            .foregroundColor(.wechatBlack)
    }
}