# FoundationModels 框架集成说明

## 手动添加框架步骤

1. 打开 Xcode 项目：`/Users/ricardo/文稿/AI研究与学习/AI智能应用/ios/ai-ws/ai-ws.xcodeproj`

2. 选择目标应用 `ai-ws`

3. 进入 "General" 标签页

4. 在 "Frameworks, Libraries, and Embedded Content" 部分点击 "+"

5. 搜索 `FoundationModels`

6. 选择框架并添加，确保嵌入方式设置为 "Embed & Sign"

7. 同样添加 `NaturalLanguage` 框架

## Info.plist 配置

需要在 `Info.plist` 中添加以下隐私权限：

```xml
<key>NSPrivacyAccessedAPICategoryFoundationModel</key>
<array>
    <string>NSPrivacyAccessedAPICategoryFoundationModelGenerateText</string>
</array>
```

## 设备要求

- iOS 26.1 或更高版本
- 支持 Apple 神经引擎 (ANE) 的设备
- iPhone 15 及以上机型

## 构建命令

添加框架后，可以使用以下命令构建项目：

```bash
cd /Users/ricardo/文稿/AI研究与学习/AI智能应用/ios/ai-ws && xcodebuild -scheme ai-ws -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1' -configuration Debug build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

## 功能说明

- **智能对话**：使用 Apple 设备端基础模型生成自然语言回复
- **财务建议**：基于用户问题提供专业的财务建议
- **消费分析**：分析用户消费数据
- **预算规划**：提供预算建议

## 测试说明

1. 在支持的设备或模拟器上运行应用
2. 点击右下角的智能助手图标
3. 输入问题或使用快捷操作
4. 等待AI生成回复

## 常见问题

### 构建失败
- 确保已正确添加 FoundationModels 框架
- 确保使用 iOS 26.1 或更高版本的 SDK
- 确保 Info.plist 中已添加必要的隐私权限

### AI 回复失败
- 检查设备是否支持 Apple 神经引擎
- 检查网络连接（首次使用需要下载模型）
- 检查设备 iOS 版本是否为 26.1 或更高

## 替代方案

如果无法使用 Apple Foundation Models，可以使用以下替代方案：

1. 使用 OpenAI API（需要网络连接）
2. 使用 Google Gemini API（需要网络连接）
3. 继续使用模拟回复（已保留在代码中，可以通过修改 `sendMessage` 函数切换）