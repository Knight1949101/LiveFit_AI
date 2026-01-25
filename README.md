# LifeFit AI - 日程驱动的智能健身助手

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Platform](https://img.shields.io/badge/platform-flutter%7Candroid%7Cios-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> "不是你适应计划，而是计划适应你的生活。"

---
# 详细文档见https://modelscope.cn/docs/%E5%88%9B%E7%A9%BA%E9%97%B4%E5%8D%A1%E7%89%87
domain: #领域：cv/nlp/audio/multi-modal/AutoML
# - cv
tags: #自定义标签
-
datasets: #关联数据集
  evaluation:
  #- iic/ICDAR13_HCTR_Dataset
  test:
  #- iic/MTWI
  train:
  #- iic/SIBR
models: #关联模型
#- iic/ofa_ocr-recognition_general_base_zh

## 启动文件(若SDK为Gradio/Streamlit，默认为app.py, 若为Static HTML, 默认为index.html)
# deployspec:
#   entry_file: app.py
license: Apache License 2.0
---

## 📖 项目介绍 (Introduction)

**LifeFit AI** 是一款专为忙碌人群（学生、上班族）打造的 **“日程驱动型” (Schedule-Driven)** 智能健身 App。

与传统健身 App 不同，LifeFit 不强制你每天抽出固定的 1 小时。它像一个智能助理，通过 **AI 语音对话** 或 **手动输入** 快速了解你的日程安排，识别出你一天中的碎片空闲时间（如课间 20 分钟、会议取消的 30 分钟），并动态插入最适合当下的微运动建议。

## ✨ 核心功能 (Key Features)

### 1. 📅 智能日程构建 (Smart Schedule Builder)
*   **AI 语音助理**：按住说话，“明天下午三点有社团活动”，AI 自动识别时间地点并生成日程。
*   **极速手动录入**：为不方便语音的场景提供高效的快捷输入面板。
*   **课表导入**：(开发中) 支持学生上传课表截图，OCR 识别空闲时段。

### 2. 🧠 AI 编排引擎 (The Brain)
*   **动态调度**：当检测到日程冲突时，自动重新编排本周剩余计划。
*   **能量电池**：将身体比作电池，工作耗电，运动充电，提供直观的状态反馈。

### 3. 🌤️ 气象智能决策 (Weather Intelligence)
*   **雨天预警**：检测到未来 2 小时有雨，自动将“户外跑”替换为“室内 HIIT”或“跑步机计划”。
*   **舒适度分析**：根据温度和湿度，推荐最适宜的运动强度（如：高温天避开剧烈有氧）。
*   **穿衣建议**：早晨提醒“今日降温，户外晨跑建议加一件防风衣”。

### 4. 👤 个性化用户档案 (User Profile 2.0)
*   **体质分析**：不仅仅是身高体重，还包含 **外胚/中胚/内胚** 体质判定。
*   **资源定制**：根据你手头的器械（哑铃/弹力带/自重）和环境（宿舍/家/健身房）生成专属计划。

### 5. ⚡ 微运动库 (Micro-Workout Library)
*   **场景标签**：`#办公室` `#无汗` `#静音` `#宿舍`。
*   **极速加载**：轻量级 GIF/短视频指导，随时随地开练。

## 🛠 技术栈 (Tech Stack)

*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **State Management**: Provider / Riverpod (TBD)
*   **Local Storage**: SQLite (sqflite) / Hive
*   **AI & Speech**: 语音识别 (STT) + 自然语言处理 (NLP) 解析日程意图。
*   **Weather**: OpenWeatherMap / 和风天气 API (精准定位气象数据)。
*   **Privacy**: **Local-First** 架构，所有日程与语音数据仅在本地处理/脱敏，不上传服务器。

## 🚀 快速开始 (Getting Started)

### 环境要求
*   Python: 3.10+
*   Gradio: 最新版本

### 安装步骤

1.  **克隆项目**
    ```bash
    git clone https://www.modelscope.cn/studios/qinyula/lifefitAI.git
    cd lifefitAI
    ```

2.  **安装依赖**
    ```bash
    pip install -r requirements.txt
    ```

3.  **运行项目**
    ```bash
    python app.py
    ```

## 📄 开源协议 (License)

本项目采用 MIT 协议 - 详见 LICENSE 文件。

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
