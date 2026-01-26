#!/bin/bash

# LiveFit AI 启动脚本

# 设置环境变量
export PYTHONUNBUFFERED=1

# 安装依赖
echo "正在安装依赖..."
pip install -r requirements.txt

# 启动应用
echo "正在启动 LiveFit AI 应用..."
python app.py