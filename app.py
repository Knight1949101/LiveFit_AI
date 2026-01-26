import gradio as gr
import os
import datetime

# 加载环境变量
def load_env_variables():
    env_vars = {
        'AMAP_API_KEY': os.getenv('AMAP_API_KEY', ''),
        'DEEPSEEK_API_KEY': os.getenv('DEEPSEEK_API_KEY', ''),
        'DEEPSEEK_API_BASE_URL': os.getenv('DEEPSEEK_API_BASE_URL', ''),
        'VOICE_RECOGNITION_API_KEY': os.getenv('VOICE_RECOGNITION_API_KEY', ''),
        'VOICE_RECOGNITION_SECRET_KEY': os.getenv('VOICE_RECOGNITION_SECRET_KEY', ''),
        'VOICE_RECOGNITION_API_URL': os.getenv('VOICE_RECOGNITION_API_URL', ''),
        'WEATHER_API_BASE_URL': os.getenv('WEATHER_API_BASE_URL', ''),
        'WEATHER_API_KEY': os.getenv('WEATHER_API_KEY', ''),
        'WEATHER_CREDENTIAL_ID': os.getenv('WEATHER_CREDENTIAL_ID', ''),
        'GEOCODING_API_BASE_URL': os.getenv('GEOCODING_API_BASE_URL', ''),
        'NLP_API_URL': os.getenv('NLP_API_URL', ''),
        'NLP_API_KEY': os.getenv('NLP_API_KEY', ''),
    }
    return env_vars

# 健身计划生成功能
def generate_fitness_plan(goal, duration, intensity):
    """生成健身计划"""
    plans = {
        "减脂": {
            "低强度": ["每日30分钟快走", "每周2次瑜伽", "控制饮食热量"],
            "中强度": ["每日45分钟跑步", "每周3次力量训练", "高蛋白饮食"],
            "高强度": ["每日60分钟HIIT", "每周4次力量训练", "严格饮食控制"]
        },
        "增肌": {
            "低强度": ["每周3次力量训练", "蛋白质补充", "充足休息"],
            "中强度": ["每周4次力量训练", "高蛋白饮食", "渐进超负荷"],
            "高强度": ["每周5次力量训练", "专业营养计划", "肌肉恢复管理"]
        },
        "塑形": {
            "低强度": ["每周3次全身训练", "柔韧性练习", "均衡饮食"],
            "中强度": ["每周4次针对性训练", "核心力量训练", "合理饮食"],
            "高强度": ["每周5次综合训练", "功能性训练", "精确营养控制"]
        }
    }
    
    plan = plans.get(goal, plans["减脂"]).get(intensity, plans["减脂"]["中强度"])
    return f"### {goal}计划 ({duration}周，{intensity}强度)\n" + "\n".join([f"- {item}" for item in plan])

# 日程建议功能
def get_schedule_suggestion(activity, time_preference):
    """生成日程建议"""
    schedules = {
        "晨练": {
            "工作日": "6:00-7:00 晨跑 + 拉伸",
            "周末": "7:00-8:30 户外骑行或爬山"
        },
        "午间活动": {
            "工作日": "12:30-13:00 办公室瑜伽",
            "周末": "11:00-12:00 游泳或网球"
        },
        "晚间锻炼": {
            "工作日": "19:30-21:00 力量训练",
            "周末": "20:00-21:30 团体健身课程"
        }
    }
    
    return f"### {activity}建议\n" + schedules.get(activity, schedules["晨练"]).get(time_preference, schedules["晨练"]["工作日"])

# 天气查询功能（模拟）
def get_weather_suggestion(city, weather_type):
    """根据天气提供健身建议"""
    suggestions = {
        "晴天": "适合户外跑步、骑行、球类运动等",
        "雨天": "建议室内健身，如瑜伽、力量训练、跑步机",
        "阴天": "适合户外轻量运动，如快走、徒步",
        "雪天": "建议室内活动，如普拉提、健身操",
        "雾霾": "避免户外活动，选择室内健身"
    }
    
    return f"### {city}天气健身建议\n当前天气：{weather_type}\n推荐活动：{suggestions.get(weather_type, suggestions['晴天'])}"

# 健康数据跟踪功能
def track_health_data(weight, steps, calories):
    """跟踪健康数据"""
    today = datetime.datetime.now().strftime("%Y-%m-%d")
    return f"### 健康数据记录 ({today})\n" + \
           f"- 体重：{weight} kg\n" + \
           f"- 步数：{steps} 步\n" + \
           f"- 卡路里消耗：{calories} kcal\n" + \
           "\n📊 建议：保持每日步数在8000-10000步，根据目标调整卡路里摄入"

# 主界面函数
def lifefit_ai_interface():
    env_vars = load_env_variables()
    
    # 创建自定义主题，匹配安卓端现代科技蓝风格
    custom_theme = gr.themes.Soft(
        primary_hue="blue",
        secondary_hue="green",
        neutral_hue="gray",
        
        # 基于安卓端颜色配置
        primary=gr.themes.Color(
            c50="#E8F0FF",  # primaryContainer
            c100="#CCDBFF",
            c200="#99BEFF",
            c300="#669FFF",
            c400="#4A6FFF",  # primary
            c500="#3366FF",
            c600="#2952CC",
            c700="#1F3D99",
            c800="#142966",
            c900="#0D1A4A",
        ),
        
        secondary=gr.themes.Color(
            c50="#E8F5E8",  # secondaryContainer
            c100="#C8E6C8",
            c200="#A5D6A7",
            c300="#81C784",
            c400="#66BB6A",
            c500="#4CAF50",
            c600="#43A047",
            c700="#388E3C",
            c800="#2E7D32",
            c900="#1B5E20",  # onSecondaryContainer
        ),
        
        neutral=gr.themes.Color(
            c50="#F9FAFB",  # surfaceContainerHighest
            c100="#F3F4F6",
            c200="#E5E7EB",
            c300="#D1D5DB",
            c400="#9CA3AF",
            c500="#6B7280",  # onSurfaceVariant
            c600="#4B5563",
            c700="#374151",
            c800="#1F2937",
            c900="#1A1D2E",  # onSurface
        ),
        
        background_fill="#F5F8FF",  # backgroundLightModern
        surface_fill="#FFFFFF",  # surfaceLightModern
        
        text_size=gr.themes.Size(
            xs="12px",
            sm="14px",
            md="16px",
            lg="18px",
            xl="20px",
        ),
        
        # 卡片和边框样式
        radius="lg",
        shadow="sm",
    )
    
    with gr.Blocks(
        title="LiveFit AI - 日程驱动的智能健身助手", 
        theme=custom_theme,
        css="""
        /* 安卓端风格样式 */
        .gradio-container {
            background-color: #F5F8FF; /* 梦幻蓝白背景 */
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .gr-markdown h1 {
            color: #1A1D2E; /* textPrimaryLight */
            font-weight: 700;
            margin-bottom: 0.5rem;
        }
        
        .gr-markdown h2 {
            color: #1A1D2E;
            font-weight: 600;
            margin-bottom: 1rem;
        }
        
        .gr-markdown h3 {
            color: #1A1D2E;
            font-weight: 600;
            margin-bottom: 0.75rem;
        }
        
        .gr-markdown {
            color: #6B7280; /* textSecondaryLight */
            line-height: 1.6;
        }
        
        /* 选项卡样式 */
        .gr-tabs {
            background-color: #FFFFFF;
            border-radius: 12px;
            padding: 1rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }
        
        .gr-tab-nav {
            background-color: #F9FAFB;
            border-radius: 8px;
            padding: 0.25rem;
            margin-bottom: 1.5rem;
        }
        
        .gr-tab {
            border-radius: 6px;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        
        .gr-tab:hover {
            background-color: #E8F0FF;
        }
        
        .gr-tab-selected {
            background-color: #4A6FFF !important;
            color: white !important;
        }
        
        /* 卡片样式 */
        .gr-box {
            background-color: #FFFFFF;
            border-radius: 12px;
            border: 1px solid #E8F0FF; /* borderLightModern */
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }
        
        /* 按钮样式 */
        .gr-button {
            background: linear-gradient(135deg, #4A6FFF 0%, #00E676 100%);
            border: none;
            border-radius: 8px;
            font-weight: 600;
            padding: 0.75rem 1.5rem;
            transition: all 0.2s ease;
        }
        
        .gr-button:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(74, 111, 255, 0.3);
        }
        
        .gr-button:active {
            transform: translateY(0);
        }
        
        /* 输入控件样式 */
        .gr-input {
            border: 1px solid #E8F0FF;
            border-radius: 8px;
            padding: 0.75rem;
            transition: all 0.2s ease;
        }
        
        .gr-input:focus {
            border-color: #4A6FFF;
            box-shadow: 0 0 0 3px rgba(74, 111, 255, 0.1);
        }
        
        /* 下拉菜单样式 */
        .gr-dropdown {
            border: 1px solid #E8F0FF;
            border-radius: 8px;
        }
        
        /* 滑块样式 */
        .gr-slider {
            accent-color: #4A6FFF;
        }
        
        /* 单选按钮样式 */
        .gr-radio {
            accent-color: #4A6FFF;
        }
        
        /* 布局样式 */
        .gr-row {
            gap: 1.5rem;
        }
        
        .gr-column {
            gap: 1rem;
        }
        
        /* 输出区域样式 */
        .gr-output {
            background-color: #FFFFFF;
            border: 1px solid #E8F0FF;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }
        """
    ) as demo:
        # 标题栏 - 模拟安卓端顶部栏
        with gr.Row(elem_classes="gr-box", style={"background": "linear-gradient(135deg, #4A6FFF 0%, #00E676 100%)", "color": "white", "padding": "1.5rem", "border-radius": "12px", "margin-bottom": "1.5rem"}):
            with gr.Column(scale=1, style={"text-align": "center"}):
                gr.Markdown("""# LiveFit AI
## 日程驱动的智能健身助手

基于个人日程和偏好，提供智能化的健身建议和计划生成""", elem_classes="title-content")
        
        # 选项卡布局 - 模拟安卓端底部导航栏
        with gr.Tabs():
            # 健身计划生成
            with gr.TabItem("🏋️ 健身计划生成"):
                with gr.Row():
                    # 输入区域 - 左侧卡片
                    with gr.Column(scale=1, elem_classes="gr-box"):
                        gr.Markdown("### 个性化设置")
                        
                        goal = gr.Dropdown(
                            choices=["减脂", "增肌", "塑形"],
                            label="健身目标",
                            value="减脂",
                            elem_classes="gr-input"
                        )
                        
                        duration = gr.Slider(
                            minimum=1, maximum=12, value=4,
                            label="计划周期（周）",
                            step=1,
                            elem_classes="gr-slider"
                        )
                        
                        intensity = gr.Radio(
                            choices=["低强度", "中强度", "高强度"],
                            label="训练强度",
                            value="中强度",
                            elem_classes="gr-radio"
                        )
                        
                        generate_btn = gr.Button("生成计划")
                    
                    # 输出区域 - 右侧卡片
                    with gr.Column(scale=2, elem_classes="gr-output"):
                        plan_output = gr.Markdown(label="健身计划", value="### 请点击'生成计划'按钮获取个性化健身计划")
                
                generate_btn.click(
                    fn=generate_fitness_plan,
                    inputs=[goal, duration, intensity],
                    outputs=plan_output
                )
            
            # 日程建议
            with gr.TabItem("📅 日程建议"):
                with gr.Row():
                    # 输入区域
                    with gr.Column(scale=1, elem_classes="gr-box"):
                        gr.Markdown("### 日程设置")
                        
                        activity = gr.Dropdown(
                            choices=["晨练", "午间活动", "晚间锻炼"],
                            label="活动类型",
                            value="晨练",
                            elem_classes="gr-input"
                        )
                        
                        time_preference = gr.Radio(
                            choices=["工作日", "周末"],
                            label="时间偏好",
                            value="工作日",
                            elem_classes="gr-radio"
                        )
                        
                        schedule_btn = gr.Button("获取建议")
                    
                    # 输出区域
                    with gr.Column(scale=2, elem_classes="gr-output"):
                        schedule_output = gr.Markdown(label="日程建议", value="### 请点击'获取建议'按钮获取智能日程安排")
                
                schedule_btn.click(
                    fn=get_schedule_suggestion,
                    inputs=[activity, time_preference],
                    outputs=schedule_output
                )
            
            # 天气健身建议
            with gr.TabItem("🌤️ 天气建议"):
                with gr.Row():
                    # 输入区域
                    with gr.Column(scale=1, elem_classes="gr-box"):
                        gr.Markdown("### 天气设置")
                        
                        city = gr.Textbox(
                            label="城市",
                            value="北京",
                            elem_classes="gr-input"
                        )
                        
                        weather_type = gr.Dropdown(
                            choices=["晴天", "雨天", "阴天", "雪天", "雾霾"],
                            label="天气类型",
                            value="晴天",
                            elem_classes="gr-input"
                        )
                        
                        weather_btn = gr.Button("获取建议")
                    
                    # 输出区域
                    with gr.Column(scale=2, elem_classes="gr-output"):
                        weather_output = gr.Markdown(label="天气健身建议", value="### 请点击'获取建议'按钮获取天气适配的健身建议")
                
                weather_btn.click(
                    fn=get_weather_suggestion,
                    inputs=[city, weather_type],
                    outputs=weather_output
                )
            
            # 健康数据跟踪
            with gr.TabItem("📊 健康数据"):
                with gr.Row():
                    # 输入区域
                    with gr.Column(scale=1, elem_classes="gr-box"):
                        gr.Markdown("### 数据记录")
                        
                        weight = gr.Number(
                            label="体重 (kg)",
                            value=70.0,
                            elem_classes="gr-input"
                        )
                        
                        steps = gr.Number(
                            label="今日步数",
                            value=8000,
                            elem_classes="gr-input"
                        )
                        
                        calories = gr.Number(
                            label="卡路里消耗 (kcal)",
                            value=300.0,
                            elem_classes="gr-input"
                        )
                        
                        track_btn = gr.Button("记录数据")
                    
                    # 输出区域
                    with gr.Column(scale=2, elem_classes="gr-output"):
                        health_output = gr.Markdown(label="健康数据记录", value="### 请输入健康数据并点击'记录数据'按钮")
                
                track_btn.click(
                    fn=track_health_data,
                    inputs=[weight, steps, calories],
                    outputs=health_output
                )
            
            # 关于
            with gr.TabItem("ℹ️ 关于"):
                with gr.Column(elem_classes="gr-box", style={"padding": "1.5rem"}):
                    gr.Markdown("""# LiveFit AI

## 项目介绍
LiveFit AI 是一个日程驱动的智能健身助手，基于个人日程和偏好，提供智能化的健身建议和计划生成。

## 核心功能
- 🏋️ 个性化健身计划生成
- 📅 智能日程建议
- 🌤️ 天气适配的健身建议
- 📊 健康数据跟踪

## 技术栈
- Gradio Web UI
- 人工智能算法
- 天气API集成
- 地理位置服务

## 设计理念
采用现代科技蓝主题，营造科技感与专业感，同时提升视觉舒适度。

## 开发团队
LiveFit AI 开发团队

## 版本
v1.0.0""")
    
    return demo

if __name__ == "__main__":
    # 创建并启动应用
    demo = lifefit_ai_interface()
    # 确保在魔搭社区正确暴露端口
    demo.launch(
        server_name="0.0.0.0",
        server_port=7860,
        share=True,
        debug=False,
        show_api=False
    )