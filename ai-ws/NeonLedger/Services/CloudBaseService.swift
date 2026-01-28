import Foundation

class CloudBaseService {
    static let shared = CloudBaseService()
    
    private init() {}
    
    // CloudBase API 配置
    private let apiUrl = "https://wanxin1994-3g0nf07m2ee74437.api.tcloudbasegateway.com/v1/functions/signInRecord"
    private let apiToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjlkMWRjMzFlLWI0ZDAtNDQ4Yi1hNzZmLWIwY2M2M2Q4MTQ5OCJ9.eyJhdWQiOiJ3YW54aW4xOTk0LTNnMG5mMDdtMmVlNzQ0MzciLCJleHAiOjI1MzQwMjMwMDc5OSwiaWF0IjoxNzY5MDcxNjgzLCJhdF9oYXNoIjoiT0RURVE2Z2hUQ08tN0dSVjZXTkhEdyIsInByb2plY3RfaWQiOiJ3YW54aW4xOTk0LTNnMG5mMDdtMmVlNzQ0MzciLCJtZXRhIjp7InBsYXRmb3JtIjoiQXBpS2V5In0sImFkbWluaXN0cmF0b3JfaWQiOiIyMDE0MjQ1MDMyMjA1Mjc1MTM4IiwidXNlcl90eXBlIjoiIiwiY2xpZW50X3R5cGUiOiJjbGllbnRfc2VydmVyIiwiaXNfc3lzdGVtX2FkbWluIjp0cnVlfQ.PDHRXsx0wOFE1zMuyAgSvYmSkBG8--qqaOwqPTOoXG2APXASxw6btkf7xN9XC_cDJad7lui5teHNuR8fU1uyw6a1MeMpwZ6OOOTkS597RmLm7lMfpiaSVckuQTXvuoUuJk8kpF5t0isn7UqgCaer9VFfgoZZG-HI1pxGT67DrgmNSrI9AXt6FaV0TDxiViEzbrpPobDf06yenb2Rsc3-K2Vvu15JJYaKgrm-UZSd_H-gP1ck8d8afi7EQJtQqkySAhnz9OItBF2JLPXcP7BywzIluVnrVNtPUsjNofIaJtctniKF8uGOEvlTi493DU5cNbpY57pANsg8HfQwFV3aRA"
    
    // 调用 signInRecord 函数
    func signInRecord(completion: @escaping (String) -> Void) {
        print("=== 开始调用 CloudBase signInRecord API ===")
        
        guard let url = URL(string: apiUrl) else {
            completion("❌ 无效的 API URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        // 构建请求体
        // 直接发送请求参数，不需要包裹在 data 字段中
        // 尝试发送一些基础信息，或者根据业务需求发送空对象
        let requestBody: [String: Any] = [
            "userId": "test001",
            "timestamp": Int(Date().timeIntervalSince1970),
            "source": "ios_client"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                print("\n==================================================")
                print("📡 CloudBase API 请求日志")
                print("==================================================")
                print("🔗 请求 URL: \(url.absoluteString)")
                print("📝 请求方法: \(request.httpMethod ?? "UNKNOWN")")
                
                if let error = error {
                    print("❌ 请求失败: \(error.localizedDescription)")
                    print("==================================================\n")
                    completion("请求失败: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ 无效的 HTTP 响应")
                    print("==================================================\n")
                    completion("无效的 HTTP 响应")
                    return
                }
                
                print("🔢 状态码: \(httpResponse.statusCode)")
                
                var resultMessage = "请求完成，状态码: \(httpResponse.statusCode)"
                
                if let data = data {
                    // 尝试格式化打印 JSON
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        
                        // 尝试提取 message 或 msg 字段
                        if let msg = jsonObject["message"] as? String {
                            resultMessage = msg
                        } else if let msg = jsonObject["msg"] as? String {
                            resultMessage = msg
                        } else if let error = jsonObject["error"] as? String {
                            resultMessage = error
                        }
                        
                        // 打印漂亮的 JSON
                        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                           let jsonString = String(data: jsonData, encoding: .utf8) {
                            print("📄 响应内容 (JSON):\n\(jsonString)")
                        }
                    } else if let responseString = String(data: data, encoding: .utf8) {
                        print("📄 响应内容 (Raw): \(responseString)")
                        // 如果不是 JSON，尝试直接使用响应字符串作为消息（如果不太长）
                        if responseString.count < 100 {
                            resultMessage = responseString
                        }
                    }
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ 请求成功")
                } else {
                    print("⚠️ 请求返回非 200 状态")
                }
                print("==================================================\n")
                
                completion(resultMessage)
            }
            
            task.resume()
        } catch {
            print("❌ 构建请求体失败: \(error.localizedDescription)")
            completion("构建请求体失败: \(error.localizedDescription)")
        }
    }
}
