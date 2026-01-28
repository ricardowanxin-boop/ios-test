# Apple Foundation Models 集成指南

本文档介绍如何在 iOS 应用中集成 Apple 设备端基础模型（Foundation Models），为应用添加 AI 功能。

## 一、前提条件

1. **开发环境要求**
   - Xcode 26.1 或更高版本
   - iOS 26.1 SDK 或更高版本
   - macOS 15 或更高版本（用于开发）

2. **设备要求**
   - iPhone/iPad 设备运行 iOS 26.1 或更高版本
   - 支持 Apple 神经引擎（ANE）的设备

## 二、集成步骤

### 1. 添加 FoundationModels 框架

在 Xcode 项目中添加 Apple 基础模型框架：

1. 打开 Xcode 项目
2. 选择目标应用
3. 进入 "General" 标签页
4. 在 "Frameworks, Libraries, and Embedded Content" 部分点击 "+"
5. 搜索 "FoundationModels"
6. 选择框架并添加

### 2. 配置隐私权限

在 `Info.plist` 中添加必要的隐私权限：

```xml
<key>NSPrivacyAccessedAPICategoryFoundationModel</key>
<array>
    <string>NSPrivacyAccessedAPICategoryFoundationModelGenerateText</string>
    <string>NSPrivacyAccessedAPICategoryFoundationModelGenerateImage</string>
</array>
```

### 3. 实现 AI 功能

#### 文本生成功能

```swift
import FoundationModels
import SwiftUI

struct AITextGeneratorView: View {
    @State private var prompt = ""
    @State private var generatedText = ""
    @State private var isGenerating = false
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("输入提示词...", text: $prompt)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button(action: generateText) {
                Text(isGenerating ? "生成中..." : "生成文本")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isGenerating)
            
            if !generatedText.isEmpty {
                Text(generatedText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
    }
    
    func generateText() {
        Task {
            isGenerating = true
            defer { isGenerating = false }
            
            do {
                let model = try TextGenerationFoundationModel()
                let result = try await model.generateText(for: prompt)
                generatedText = result
            } catch {
                print("生成失败: \(error)")
            }
        }
    }
}
```

#### 图像生成功能

```swift
struct AIImageGeneratorView: View {
    @State private var prompt = ""
    @State private var generatedImage: UIImage?
    @State private var isGenerating = false
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("输入图像描述...", text: $prompt)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button(action: generateImage) {
                Text(isGenerating ? "生成中..." : "生成图像")
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isGenerating)
            
            if let image = generatedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    func generateImage() {
        Task {
            isGenerating = true
            defer { isGenerating = false }
            
            do {
                let model = try ImageGenerationFoundationModel()
                let result = try await model.generateImage(for: prompt)
                generatedImage = result.image
            } catch {
                print("生成失败: \(error)")
            }
        }
    }
}
```

### 4. 在主应用中集成

将 AI 功能集成到现有的微信风格应用中：

```swift
// 在 MainView.swift 中添加 AI 功能入口
struct NeonLedgerMainView: View {
    // 现有状态...
    @State private var showAITools = false
    
    var body: some View {
        ZStack {
            // 现有代码...
            
            // AI 工具面板
            if showAITools {
                AIToolsView(onClose: { showAITools = false })
            }
        }
    }
    
    // 在合适位置添加 AI 工具按钮
    // ...
}

// AI 工具主界面
struct AIToolsView: View {
    let onClose: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: AITextGeneratorView()) {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .foregroundColor(.blue)
                        Text("文本生成")
                    }
                }
                
                NavigationLink(destination: AIImageGeneratorView()) {
                    HStack {
                        Image(systemName: "photo.fill")
                            .foregroundColor(.purple)
                        Text("图像生成")
                    }
                }
            }
            .navigationTitle("AI 工具")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") { onClose() }
                }
            }
        }
    }
}
```

## 三、可用的基础模型功能

### 1. 文本模型
- 文本生成
- 文本摘要
- 文本翻译
- 文本分类
- 问答系统

### 2. 图像模型
- 图像生成
- 图像编辑
- 图像描述

### 3. 多模态模型
- 图文结合生成
- 图像内容分析

## 四、最佳实践

1. **设备兼容性检查**
   ```swift
   if TextGenerationFoundationModel.isSupported {
       // 支持文本生成
   }
   
   if ImageGenerationFoundationModel.isSupported {
       // 支持图像生成
   }
   ```

2. **异步处理**
   - 使用 `Task` 和 `await` 处理模型调用
   - 提供加载状态反馈
   - 处理错误情况

3. **优化用户体验**
   - 提供清晰的加载指示器
   - 允许取消生成过程
   - 提供编辑生成结果的功能

4. **性能优化**
   - 缓存频繁使用的模型
   - 适当调整生成参数（如温度、最大长度）
   - 限制同时进行的生成任务数量

## 五、测试与调试

1. **在模拟器上测试**
   - 某些模型功能可能无法在模拟器上运行
   - 建议在真实设备上进行完整测试

2. **查看模型状态**
   ```swift
   do {
       let model = try TextGenerationFoundationModel()
       print("模型可用: \(model.isAvailable)")
       print("模型名称: \(model.name)")
   } catch {
       print("模型不可用: \(error)")
   }
   ```

3. **监控性能**
   - 使用 Instruments 监控模型调用的 CPU/GPU 使用率
   - 监控内存使用情况

## 六、注意事项

1. **模型大小**
   - 首次使用时，系统会下载模型文件
   - 模型文件可能较大，建议在 Wi-Fi 环境下下载

2. **隐私保护**
   - 所有 AI 处理均在设备端完成
   - 数据不会发送到 Apple 服务器
   - 符合 Apple 隐私政策

3. **使用限制**
   - 模型生成速度取决于设备性能
   - 某些高级功能可能仅在特定设备上可用

4. **API 稳定性**
   - FoundationModels API 仍在发展中
   - 建议关注 Apple 开发者文档的更新

## 七、常见问题

### 1. 模型不可用
   - 检查设备是否支持 ANE
   - 确保设备运行 iOS 26.1+ 
   - 检查网络连接（首次使用需要下载模型）

### 2. 生成速度慢
   - 尝试简化提示词
   - 减少生成内容长度
   - 在高性能设备上测试

### 3. 生成结果不符合预期
   - 优化提示词，提供更详细的描述
   - 调整生成参数
   - 尝试不同的模型变体

## 八、示例应用

本文档提供了基础的 AI 功能集成示例，您可以根据应用需求扩展更多功能：

- 账单智能分类
- 消费分析报告生成
- 财务建议生成
- 发票扫描与识别
- 智能记账助手

通过集成 Apple 设备端基础模型，您的应用可以提供强大的 AI 功能，同时保持良好的隐私保护和性能表现。