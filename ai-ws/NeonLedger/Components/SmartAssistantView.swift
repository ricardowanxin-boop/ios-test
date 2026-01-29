import SwiftUI
import UIKit
import CryptoKit

// 聊天消息结构体
// 核心业务模型：定义了聊天消息的数据结构，包含状态管理字段
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let isUser: Bool // 区分消息来源（用户/助手）
    let timestamp = Date()
    
    // 普通消息字段
    var text: String
    
    // Loading 状态：用于显示AI思考中的动画
    var isLoading: Bool
    
    // 复杂交互：打字机效果相关字段
    // fullText 存储完整回复，text 存储当前显示的部分
    var fullText: String
    var isTyping: Bool // 标记是否正在进行打字机动画
    var typingSpeed: TimeInterval = 0.05 // 动画速率：每字符显示时间
    
    // 用户消息初始化
    init(text: String, isUser: Bool) {
        self.text = text
        self.isUser = isUser
        self.isLoading = false
        self.fullText = text
        self.isTyping = false
    }
    
    // 助手消息初始化
    init(text: String, isUser: Bool, isLoading: Bool) {
        // 确保初始文本不为空，避免气泡过小，优化UI体验
        self.text = text.isEmpty ? " " : text
        self.isUser = isUser
        self.isLoading = isLoading
        self.fullText = text
        self.isTyping = false
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id && 
        lhs.text == rhs.text &&
        lhs.isLoading == rhs.isLoading &&
        lhs.isTyping == rhs.isTyping
    }
}

// 聊天气泡视图
// UI组件：根据消息类型（发送/接收）和状态渲染不同的气泡样式
struct ChatBubble: View {
    @Binding var message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                // 用户消息：右侧显示，绿色背景
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text(message.text)
                        .padding(12)
                        .background(Color.wechatGreen)
                        .foregroundColor(.white)
                        // 使用自定义圆角扩展，实现气泡尖角效果
                        .cornerRadius(18, corners: [.topLeft, .topRight, .bottomLeft])
                        .frame(maxWidth: 350, alignment: .trailing)
                    Text("14:23") // TODO: 格式化真实时间
                        .font(.system(size: 12))
                        .foregroundColor(.wechatGray)
                }
                .padding(.trailing, 15)
            } else {
                // 助手消息：左侧显示，白色背景，带头像
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top, spacing: 10) {
                        // AI头像
                        ZStack {
                            Circle()
                                .fill(Color.wechatGray)
                                .frame(width: 36, height: 36)
                            Image(systemName: "brain.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                        
                        // 核心交互：根据消息状态动态切换显示内容
                        if message.isLoading {
                            // 状态1：AI思考中，显示Loading动画
                            LoadingView()
                        } else {
                            // 状态2：内容显示（支持打字机效果的动态更新）
                            Text(message.text)
                                .padding(12)
                                .background(Color.white)
                                .foregroundColor(.wechatBlack)
                                .cornerRadius(18, corners: [.topLeft, .topRight, .bottomRight])
                                .frame(maxWidth: 350, alignment: .leading)
                                .lineLimit(nil) // 允许文本换行
                                .fixedSize(horizontal: false, vertical: true) // 垂直方向自适应大小，防止截断
                        }
                    }
                    Text("14:23")
                        .font(.system(size: 12))
                        .foregroundColor(.wechatGray)
                        .padding(.leading, 46)
                }
                .padding(.leading, 15)
                Spacer()
            }
        }
        .padding(.vertical, 5)
    }
}

// 欢迎消息视图
struct WelcomeMessage: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.fill")
                .font(.system(size: 60))
                .foregroundColor(.wechatGreen)
            Text("欢迎使用智能助手")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.wechatBlack)
            Text("有什么可以帮您的吗？")
                .font(.system(size: 16))
                .foregroundColor(.wechatGray)
        }
        .padding(.top, 0)
        .padding(.bottom, 40)
    }
}

// 快捷操作按钮视图
struct QuickAction: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.wechatGreen.opacity(0.1))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(.wechatGreen)
                }
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.wechatBlack)
            }
            .frame(width: 80, height: 80)
        }
    }
}

// Loading 动画视图（三个黑色小气泡圆点循环闪动）
// 复杂交互：使用 scaleEffect 和 opacity 实现呼吸闪烁效果，模拟AI思考过程
struct LoadingView: View {
    @State private var animate = false
    private let animationDuration: TimeInterval = 1.5
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.wechatBlack)
                    .frame(width: 10, height: 10)
                    // 动画效果：缩放和透明度变化
                    .scaleEffect(animate ? 1.0 : 0.5)
                    .opacity(animate ? 1.0 : 0.3)
                    .animation(
                        Animation.easeInOut(duration: animationDuration)
                            .repeatForever()
                            // 核心技巧：通过 delay 实现波浪式动画
                            .delay(Double(index) * animationDuration / 3)
                    , value: animate)
            }
        }
        .frame(height: 40)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(18, corners: [.topLeft, .topRight, .bottomRight])
        .onAppear {
            animate = true
        }
    }
}

// 智能助手主视图
// 核心业务：集成了聊天界面、AI模型调用、消息状态管理和交互动画
struct SmartAssistantView: View {
    let onClose: () -> Void
    @State private var inputText = ""
    @State private var messages: [ChatMessage] = [] // 消息列表数据源
    @State private var showWelcome = true // 是否显示欢迎页
    @State private var isGenerating = false // 是否正在生成回复（用于禁用输入等）
    @State private var modelAvailable = false
    
    // 初始化时检查模型可用性
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        // 初始化为false，稍后在onAppear中检查
        self._modelAvailable = State(initialValue: false)
    }
    
    var body: some View {
        ZStack {
            // 微信风格浅色背景
            Color.wechatBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 聊天消息区域
                ScrollViewReader { proxy in
                    ScrollView {
                        if showWelcome {
                            WelcomeMessage()
                            
                            // 快捷操作
                            HStack(spacing: 30) {
                                QuickAction(title: "记账助手", icon: "plus.circle.fill", action: {
                                    sendMessage("记账助手")
                                })
                                QuickAction(title: "资产分析", icon: "chart.pie.fill", action: {
                                    sendMessage("资产分析")
                                })
                                QuickAction(title: "省钱建议", icon: "wallet.pass.fill", action: {
                                    sendMessage("省钱建议")
                                })
                            }
                        }
                        
                        // 渲染消息列表
                        ForEach(messages.indices, id: \.self) { index in
                            ChatBubble(message: $messages[index])
                        }
                        
                        // 底部占位符，确保最后一条消息可见
                        Rectangle()
                            .frame(height: 10)
                            .foregroundColor(.clear)
                            .id("bottom")
                    }
                    // 监听消息变化，自动滚动到底部
                    .onChange(of: messages) { _, _ in
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                
                // 输入区域
                VStack {
                    HStack(spacing: 10) {
                        Button(action: {
                            // 表情选择
                        }) {
                            Image(systemName: "face.smiling.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.wechatGray)
                        }
                        .padding(.leading, 10)
                        
                        TextField("请输入您的问题...", text: $inputText, axis: .vertical)
                            .padding(10)
                            .background(Color.wechatBackground)
                            .cornerRadius(20)
                            .lineLimit(3)
                        
                        Button(action: {
                            sendMessage(inputText)
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 20))
                                .foregroundColor(inputText.isEmpty ? .wechatLightGray : .wechatGreen)
                        }
                        .padding(.trailing, 10)
                        .disabled(inputText.isEmpty)
                    }
                    .padding(.vertical, 10)
                    // 优化底部安全距离，减少留白
                    .padding(.bottom, 5 + (UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.first?.safeAreaInsets.bottom ?? 0) / 2) 
                    .background(Color.white)
                }
            }
            .onAppear {
                print("=== 智能助手视图出现 ===")
                // 模型可用性将在生成回复时检查
            }  
        }
        .background(Color.wechatWhite)
    }
    
    // 发送消息
    // 业务逻辑：处理用户输入，更新UI，触发AI任务
    private func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        // 1. 立即显示用户消息
        withAnimation {
            messages.append(ChatMessage(text: text, isUser: true))
            inputText = ""
            showWelcome = false
        }
        
        // 2. 异步调用AI生成回复
        Task {
            await generateAIResponse(for: text)
        }
    }
    
    // 生成AI回复
    // 核心流程：Loading -> 调用AI -> 接收响应 -> 渲染打字机动画
    private func generateAIResponse(for prompt: String) async {
        print("=== 开始生成AI回复 ===")
        
        withAnimation {
            isGenerating = true
        }
        
        defer {
            withAnimation {
                isGenerating = false
            }
            print("=== AI回复生成完成 ===")
        }
        
        // 创建并添加loading消息
        print("1. 创建loading消息")
        let loadingMessage = ChatMessage(text: "", isUser: false, isLoading: true)
        withAnimation {
            messages.append(loadingMessage)
        }
        print("   - loading消息添加成功，id: \(loadingMessage.id)")
        
        // 尝试使用真实AI模型
        print("2. 调用AI模型生成回复")
        let aiResult = await tryGenerateAIResponse(for: prompt)
                    print("   - AI生成成功，回复内容: \(aiResult ?? "无")")
        // 根据AI生成结果决定显示内容
        var finalResponse: String
        if let aiText = aiResult {
            // AI生成成功
            print("   - AI生成成功，回复长度: \(aiText.count)")
            finalResponse = aiText
        } else {
            // AI生成失败，使用模拟回复（兜底策略）
            print("   - AI生成失败，使用模拟回复")
            finalResponse = getSimulatedResponse(for: prompt) + "\n\n(当前为模拟回复)"
        }
        
        // 移除loading消息
        print("3. 移除loading消息")
        withAnimation {
            if let index = messages.firstIndex(where: { $0.id == loadingMessage.id }) {
                messages.remove(at: index)
                print("   - loading消息移除成功")
            } else {
                print("   - 未找到loading消息")
            }
        }
        
        // 创建带有打字机效果的助手消息
        print("4. 创建助手消息")
        let assistantMessage = ChatMessage(text: "", isUser: false, isLoading: false)
        withAnimation {
            messages.append(assistantMessage)
        }
        print("   - 助手消息添加成功，id: \(assistantMessage.id)")
        
        // 应用打字机效果
        print("5. 开始应用打字机效果")
        await applyTypingEffect(to: assistantMessage, fullText: finalResponse)
        print("   - 打字机效果完成")
    }
    
    // 应用打字机效果
    // 复杂交互实现：通过定时器逐字符更新 UI，模拟真人输入感
    private func applyTypingEffect(to message: ChatMessage, fullText: String) async {
        // 打印调试信息
        print("=== 开始打字机效果 ===")
        print("完整回复内容: \(fullText)")
        print("回复长度: \(fullText.count) 字符")
        
        // 更新消息的完整文本和打字状态
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            // 确保UI更新在主线程
            DispatchQueue.main.async {
                self.messages[index].fullText = fullText
                self.messages[index].isTyping = true
            }
        }
        
        // 逐字符显示文本
        for i in 0..<fullText.count {
            // 获取当前要显示的文本
            let currentText = String(fullText.prefix(i + 1))
            
            // 打印当前显示的文本
            print("当前显示: \(currentText)")
            
            // 更新消息文本，确保在主线程
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                // 使用主线程更新UI
                DispatchQueue.main.async {
                    self.messages[index].text = currentText
                }
            }
            
            // 等待一段时间，实现打字效果
            // 50毫秒/字符，产生流畅的打字感
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05秒
        }
        
        // 完成打字效果
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            DispatchQueue.main.async {
                self.messages[index].isTyping = false
            }
        }
        
        print("=== 打字机效果完成 ===")
    }
    
    // 尝试生成AI回复
    private func tryGenerateAIResponse(for prompt: String) async -> String? {
        print("   - 进入tryGenerateAIResponse，prompt: \(prompt)")
        
        // 直接调用讯飞星火Lite模型
        if let aiResponse = await callXunfeiSparkLite(prompt: prompt) {
            print("   - 使用讯飞星火Lite模型生成回复成功")
            return aiResponse
        } else {
            print("   - 所有AI模型调用失败")
        }
        
        return nil
    }
    
    // HTTP调用讯飞星火模型
    // Native Feature: 使用 URLSession 发起网络请求，CryptoKit 进行签名计算
    private func callXunfeiSparkLite(prompt: String) async -> String? {
        print("   - 进入callXunfeiSparkLite，prompt: \(prompt)")
        print("   - 开始调用讯飞星火模型 API")
        
        // 1. 配置 API Key 和 URL
        // 注意：生产环境应将 Key 存储在安全位置，避免硬编码
        let apiKey = "SlxhOUgBFxZlObBfHDhu:rAYzMvBMImyWaaUUTKkJ"
        let urlString = "https://spark-api-open.xf-yun.com/v2/chat/completions"
        let url = URL(string: urlString)! 
        print("   - API URL: \(urlString)")
        
        // 2. 拆分 app_id 和 api_secret（严格处理空格）
        let apiKeyParts = apiKey.split(separator: ":", maxSplits: 1)
        guard apiKeyParts.count == 2 else {
            print("❌ API Key 格式错误 ===\n")
            return nil
        }
        let appId = String(apiKeyParts[0])
        let apiSecret = String(apiKeyParts[1]).trimmingCharacters(in: .whitespaces)
        
        // 3. 从 URL 提取 Host
        guard let host = url.host else {
            print("❌ 无效的 URL 格式 ===\n")
            return nil
        }
        
        // 4. 生成当前 UTC 时间 (RFC 1123 格式)
        // 鉴权要求：时间必须与服务器时间误差在5分钟内
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss GMT"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let currentTime = dateFormatter.string(from: Date())
        
        // 5. 构造签名字符串
        // 鉴权规范：host + date + request-line
        let method = "POST"
        let uri = "/v2/chat/completions"
        let signatureOrigin = "host: \(host)\ndate: \(currentTime)\n\(method) \(uri) HTTP/1.1"
        
        // 6. 生成 HMAC-SHA256 签名
        guard let signature = generateHMACSignature(signString: signatureOrigin, apiSecret: apiSecret) else {
            print("❌ 生成签名失败 ===\n")
            return nil
        }
        
        // 7. 构建 Authorization 头
        let authorization = "api_key=\"\(appId)\", algorithm=\"hmac-sha256\", headers=\"host date request-line\", signature=\"\(signature)\""
        
        // 8. 配置请求头
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(currentTime, forHTTPHeaderField: "Date")
        request.setValue(host, forHTTPHeaderField: "Host")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        
        // 9. 构建请求体
        let requestBody: [String: Any] = [
            "model": "spark-x",
            "user": "user_id",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "stream": false
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            // 10. 发送请求
            // 使用 Swift Concurrency 的 async/await 语法
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // 11. 处理响应
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                print("❌ HTTP 请求失败，状态码: \(statusCode) ===\n")
                // 打印响应内容用于调试
                if !data.isEmpty {
                    let responseString = String(data: data, encoding: .utf8) ?? "无法解析响应"
                    print("响应内容: \(responseString) ===\n")
                }
                return nil
            }
            
            // 解析响应
            print("   - 开始解析API响应")
            let responseString = String(data: data, encoding: .utf8)
            print("   - 原始响应: \(responseString ?? "无响应数据")")
            
            let responseObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("   - 解析后的响应对象: \(responseObject ?? [:])")
            
            guard let choices = responseObject?["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("❌ 解析响应失败，无法提取有效内容 ===")
                return nil
            }
            
            print("   - 成功提取响应内容，长度: \(content.count)")
            print("   - 响应内容: \(content)")
            return content
        } catch {
            print("=== 调用讯飞星火模型时出错: \(error) ===")
            return nil
        }
    }
    
    // 生成 HMAC-SHA256 签名
    // Native Feature: 使用 CryptoKit 进行加密计算
    private func generateHMACSignature(signString: String, apiSecret: String) -> String? {
        guard let apiSecretData = apiSecret.data(using: .utf8),
              let signData = signString.data(using: .utf8) else {
            return nil
        }
        
        let key = SymmetricKey(data: apiSecretData)
        let signature = HMAC<SHA256>.authenticationCode(for: signData, using: key)
        return Data(signature).base64EncodedString()
    }
    
    // 获取模拟回复
    private func getSimulatedResponse(for prompt: String) -> String {
        let lowercasedPrompt = prompt.lowercased()
        
        if lowercasedPrompt.contains("记账") {
            return "好的，我来帮您处理记账。您可以告诉我这笔交易的金额、分类和日期，我会帮您记录。"
        } else if lowercasedPrompt.contains("资产") || lowercasedPrompt.contains("分析") {
            return "正在分析您的资产状况...\n\n根据您的交易记录，您的总资产为¥18,619.00，本月收入¥10,000.00，支出¥1,381.00。建议您可以适当减少餐饮支出，增加储蓄比例。"
        } else if lowercasedPrompt.contains("省钱") || lowercasedPrompt.contains("建议") {
            return "根据您的消费习惯，我为您提供以下省钱建议：\n1. 减少不必要的外卖订单\n2. 制定每月预算计划\n3. 寻找优惠券和折扣\n4. 考虑长期投资规划"
        } else if lowercasedPrompt.contains("你好") || lowercasedPrompt.contains("hello") {
            return "您好！我是您的智能记账助手，有什么可以帮您的吗？"
        } else {
            return "这是一条模拟回复。在实际应用中，这里会显示来自AI模型的真实回复。您可以尝试询问与记账相关的问题，比如'如何记账'、'我的资产状况'或者'省钱建议'。"
        }
    }
}


