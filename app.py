"""
LifeFit AI - 静态文件服务器
用于在魔搭创空间托管Flutter Web应用
"""
import os
from flask import Flask, send_from_directory, send_file

app = Flask(__name__, static_folder='build/web')

# 从环境变量获取配置
HOST = os.environ.get('HOST', '0.0.0.0')
PORT = int(os.environ.get('PORT', 7860))

# API Keys 从环境变量加载
DEEPSEEK_API_KEY = os.environ.get('DEEPSEEK_API_KEY', '')
VOICE_RECOGNITION_API_KEY = os.environ.get('VOICE_RECOGNITION_API_KEY', '')
VOICE_RECOGNITION_SECRET_KEY = os.environ.get('VOICE_RECOGNITION_SECRET_KEY', '')
NLP_API_KEY = os.environ.get('NLP_API_KEY', '')

@app.route('/')
def index():
    """提供主页"""
    return send_from_directory(app.static_folder, 'index.html')

@app.route('/<path:path>')
def serve_static(path):
    """提供静态文件"""
    file_path = os.path.join(app.static_folder, path)
    if os.path.exists(file_path):
        return send_from_directory(app.static_folder, path)
    else:
        # 对于SPA路由，返回index.html
        return send_from_directory(app.static_folder, 'index.html')

@app.route('/api/config')
def get_config():
    """提供前端配置（不包含敏感信息）"""
    return {
        'version': '1.0.0',
        'name': 'LifeFit AI'
    }

if __name__ == '__main__':
    print(f"Starting LifeFit AI server on {HOST}:{PORT}")
    app.run(host=HOST, port=PORT, debug=False)
