/// LifeFit AI - 日程驱动的智能健身助手
/// 应用入口文件
///
/// 相关文档：
/// - 项目架构设计：docs/core/architecture_design.md
/// - 技术文档：docs/core/technical_architecture.md
/// - 项目结构：docs/core/project_structure.md
/// - 开发环境配置：docs/development/开发环境配置.md
///
/// 核心功能：
/// - 用户认证与登录
/// - 仪表盘与日程管理
/// - AI智能建议
/// - 天气集成
/// - 主题与国际化支持
///
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/theme/theme_provider.dart';
import 'src/core/localization/locale_provider.dart';
import 'src/core/localization/app_localizations.dart';
import 'src/core/services/storage_service.dart';
import 'src/core/services/time_service.dart';
import 'src/core/utils/env_utils.dart';
import 'src/core/services/log_service.dart';
import 'src/features/authentication/presentation/login_screen.dart';
import 'src/features/dashboard/presentation/pages/dashboard_page.dart';
import 'src/features/profile/presentation/providers/user_profile_provider.dart';
import 'src/features/weather/presentation/providers/weather_provider.dart';
import 'src/features/ai/data/services/silicon_flow_service.dart';
import 'src/features/ai/data/services/echo_service.dart';
import 'src/features/ai/presentation/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting();

    // Initialize environment variables
    await EnvUtils.initialize();

    // Initialize storage service
    await StorageService.initialize();

    // Initialize time service
    await TimeService().initialize();
  } catch (e, stackTrace) {
    log.error('初始化应用程序时出错: $e $stackTrace');
    // 即使初始化失败，也继续运行应用程序
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(
          // 使用 EchoService 进行测试，如果需要真实 AI 对话请切换回 SiliconFlowService
          create: (_) => ChatProvider(SiliconFlowService()),
          // create: (_) => ChatProvider(EchoService()),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final weatherProvider = WeatherProvider();
            // Initialize weather provider after creation
            try {
              weatherProvider.initialize();
            } catch (e, stackTrace) {
              log.error('初始化天气提供者时出错: $e $stackTrace');
            }
            return weatherProvider;
          },
        ),
      ],
      child: const LifeFitApp(),
    ),
  );
}

class LifeFitApp extends StatelessWidget {
  const LifeFitApp({super.key});

  // 手机屏幕尺寸 (iPhone 14 Pro Max)
  static const double maxMobileWidth = 430.0;
  static const double maxMobileHeight = 932.0;

  // 构建功能项目
  Widget _buildFeatureItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            desc,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, color: Color(0xFF4ECDC4), size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: 'LifeFit AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          supportedLocales: const [Locale('en'), Locale('zh')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // 使用builder包裹所有页面，根据屏幕尺寸自适应布局
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // 如果屏幕宽度足够，显示左侧说明面板
                final showSidePanel = constraints.maxWidth > 900;
                
                // 移动端布局（全屏显示）
                if (!showSidePanel) {
                  return child!;
                }
                
                // Web/桌面端布局（显示手机模拟器）
                return Container(
                  color: const Color(0xFF1a1a2e), // 深色背景
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 左侧说明文字
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'LifeFit AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '日程驱动的智能健身助手',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // 理念介绍
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '核心理念',
                                      style: TextStyle(
                                        color: Color(0xFF4ECDC4),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '“让运动融入日常，而非打断生活”',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '通过AI智能分析您的日程安排',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '在空闲时间插入微运动建议',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // 功能介绍
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '核心功能',
                                      style: TextStyle(
                                        color: Color(0xFF4ECDC4),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildFeatureItem(Icons.calendar_today, '日程驱动', '智能分析日程空闲时段'),
                                    _buildFeatureItem(Icons.mic, 'AI语音助手', '语音输入快速添加日程'),
                                    _buildFeatureItem(Icons.cloud, '气象决策', '根据天气推荐运动'),
                                    _buildFeatureItem(Icons.fitness_center, '微运动库', '丰富的空闲健身动作'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Android App 标识
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3DDC84).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFF3DDC84).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.android,
                                      color: Color(0xFF3DDC84),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Android App Web 演示版',
                                          style: TextStyle(
                                            color: Color(0xFF3DDC84),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '完整体验请下载 Android App',
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 中间的手机模拟器
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxMobileWidth,
                              maxHeight: constraints.maxHeight * 0.9,
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: child,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 右侧空白区域（保持平衡）
                      Expanded(
                        child: const SizedBox(),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          home: const _StartupScreen(),
        );
      },
    );
  }
}

class _StartupScreen extends StatefulWidget {
  const _StartupScreen();

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _checkStartupState();
  }

  Future<void> _checkStartupState() async {
    try {
      // Check if user profile exists
      final userProfile = await _storageService.loadUserProfile();
      if (!mounted) return;

      if (userProfile != null) {
        // User profile exists, go to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        // No user profile, go to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Default to login screen on error
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple splash screen
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'LifeFit AI',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
