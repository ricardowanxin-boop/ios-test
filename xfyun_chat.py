import json
import requests
import time
import hashlib
import hmac
import base64


# 请替换为您的 API Key 和 Secret Key, 获取地址：https://console.xfyun.cn/services/bmx1
# 从原始api_key中拆分出key和secret
api_key = "SlxhOUgBFxZlObBfHDhu"
api_secret = "rAYzMvBMImyWaaUUTKkJ"
url = "https://spark-api-open.xf-yun.com/v2/chat/completions"

# 请求模型，并将结果输出
def get_answer(message):
    # 初始化请求体
    # 获取当前时间，格式化为RFC1123格式
    current_date = time.strftime('%a, %d %b %Y %H:%M:%S GMT', time.gmtime())
    
    # 构造签名字符串
    host = "spark-api-open.xf-yun.com"
    method = "POST"
    uri = "/v2/chat/completions"
    signature_origin = f"host: {host}\ndate: {current_date}\n{method} {uri} HTTP/1.1"
    
    # 使用HMAC-SHA256算法生成签名
    signature = hmac.new(api_secret.encode('utf-8'), signature_origin.encode('utf-8'), digestmod=hashlib.sha256).digest()
    signature_base64 = base64.b64encode(signature).decode('utf-8')
    
    # 构造Authorization头
    authorization = f'api_key="{api_key}", algorithm="hmac-sha256", headers="host date request-line", signature="{signature_base64}"'
    authorization_base64 = base64.b64encode(authorization.encode('utf-8')).decode('utf-8')
    
    headers = {
        'date': current_date,
        'Authorization': authorization_base64,
        'Content-Type': "application/json",
        'Host': host
    }
    body = {
        "model": "x1",
        "user": "user_id",
        "messages": message,
        # 下面是可选参数
        "stream": True,
        "tools": [
            {
                "type": "web_search",
                "web_search": {
                    "enable": True,
                    "search_mode":"deep"
                }
            }
        ]
    }
    full_response = ""  # 存储返回结果
    isFirstContent = True  # 首帧标识

    response = requests.post(url=url,json= body,headers= headers,stream= True)
    # print(response)
    for chunks in response.iter_lines():
        # 打印返回的每帧内容
        # print(chunks)
        if (chunks and '[DONE]' not in str(chunks)):
            try:
                # 检查是否是SSE格式（以"data: "开头）
                chunks_str = chunks.decode('utf-8') if isinstance(chunks, bytes) else chunks
                if chunks_str.startswith('data: '):
                    data_org = chunks_str[6:]
                else:
                    data_org = chunks_str
                
                # 跳过空数据
                if not data_org:
                    continue
                
                chunk = json.loads(data_org)
                text = chunk['choices'][0]['delta']
                # 判断思维链状态并输出
                if ('reasoning_content' in text and '' != text['reasoning_content']):
                    reasoning_content = text["reasoning_content"]
                    print(reasoning_content, end="")
                # 判断最终结果状态并输出
                if ('content' in text and '' != text['content']):
                    content = text["content"]
                    if (True == isFirstContent):
                        print("\n*******************以上为思维链内容，模型回复内容如下********************\n")
                        isFirstContent = False
                    print(content, end="")
                    full_response += content
            except json.JSONDecodeError as e:
                print(f"\nJSON解码错误: {e}")
                print(f"原始数据: {chunks}")
            except Exception as e:
                print(f"\n处理错误: {e}")
                print(f"原始数据: {chunks}")
    return full_response


# 管理对话历史，按序编为列表
def getText(text,role, content):
    jsoncon = {}
    jsoncon["role"] = role
    jsoncon["content"] = content
    text.append(jsoncon)
    return text

# 获取对话中的所有角色的content长度
def getlength(text):
    length = 0
    for content in text:
        temp = content["content"]
        leng = len(temp)
        length += leng
    return length

# 判断长度是否超长，当前限制8K tokens
def checklen(text):
    while (getlength(text) > 11000):
        del text[0]
    return text


#主程序入口
if __name__ =='__main__':
    import sys
    
    #对话历史存储列表
    chatHistory = []
    
    # 如果有命令行参数，使用第一个参数作为输入，否则进入交互式模式
    if len(sys.argv) > 1:
        # 非交互式模式，只运行一次
        Input = sys.argv[1]
        print(f"\n我:{Input}")
        question = checklen(getText(chatHistory,"user", Input))
        # 开始输出模型内容
        print("星火:", end="")
        getText(chatHistory,"assistant", get_answer(question))
        print()
    else:
        # 循环对话轮次
        while (1):
            # 等待控制台输入
            Input = input("\n" + "我:")
            question = checklen(getText(chatHistory,"user", Input))
            # 开始输出模型内容
            print("星火:", end="")
            getText(chatHistory,"assistant", get_answer(question))
