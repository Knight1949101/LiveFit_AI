import 'package:flutter/material.dart';
import '../../../../core/services/iflytek_voice_recognition_service.dart';
import '../widgets/iflytek_voice_animation.dart';
import '../widgets/voice_recognition_result.dart';
import '../widgets/offline_language_pack_manager.dart';
import '../../../../core/theme/app_colors.dart';

class IFlytekVoiceTestScreen extends StatefulWidget {
  const IFlytekVoiceTestScreen({super.key});

  @override
  State<IFlytekVoiceTestScreen> createState() => _IFlytekVoiceTestScreenState();
}

class _IFlytekVoiceTestScreenState extends State<IFlytekVoiceTestScreen> {
  final IFlytekVoiceRecognitionService _voiceService =
      IFlytekVoiceRecognitionService();

  // 状态
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isCompleted = false;
  String _recognitionResult = '';
  String _partialResult = '';
  double _confidence = 0.0;
  double _soundLevel = 0.0;
  String _statusMessage = '';
  String _errorMessage = '';
  VoiceRecognitionErrorType? _errorType;

  // 离线语言包管理
  final List<LanguagePack> _availablePacks = predefinedLanguagePacks;
  final List<LanguagePack> _downloadedPacks = [];
  final Map<String, double> _downloadProgress = {};

  // 初始化服务
  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() {
      _statusMessage = '正在初始化语音识别服务...';
    });

    await _voiceService.initialize();

    setState(() {
      _isInitialized = _voiceService.isInitialized;
      _statusMessage = _isInitialized ? '语音识别服务初始化成功' : '语音识别服务初始化失败';
    });
  }

  // 开始识别
  Future<void> _startListening() async {
    if (!_isInitialized) {
      await _initializeService();
      if (!_isInitialized) {
        return;
      }
    }

    setState(() {
      _isListening = true;
      _isCompleted = false;
      _recognitionResult = '';
      _partialResult = '';
      _confidence = 0.0;
      _soundLevel = 0.0;
      _statusMessage = '开始识别...';
      _errorMessage = '';
      _errorType = null;
    });

    await _voiceService.startListening(
      onResult: (result) {
        setState(() {
          _recognitionResult = result;
          _isCompleted = true;
          _isListening = false;
          _statusMessage = '识别完成';
        });
      },
      onPartialResult: (partialResult) {
        setState(() {
          _partialResult = partialResult;
        });
      },
      onConfidence: (confidence) {
        setState(() {
          _confidence = confidence;
        });
      },
      onSoundLevel: (soundLevel) {
        setState(() {
          _soundLevel = soundLevel;
        });
      },
      onStatus: (status) {
        setState(() {
          _statusMessage = status;
        });
      },
      onError: (error, errorType) {
        setState(() {
          _errorMessage = error;
          _errorType = errorType;
          _isListening = false;
          _isCompleted = false;
        });
      },
    );
  }

  // 停止识别
  Future<void> _stopListening() async {
    await _voiceService.stopListening();
    setState(() {
      _isListening = false;
      _statusMessage = '识别已停止';
    });
  }

  // 取消识别
  Future<void> _cancelListening() async {
    await _voiceService.cancelListening();
    setState(() {
      _isListening = false;
      _isCompleted = false;
      _recognitionResult = '';
      _partialResult = '';
      _statusMessage = '识别已取消';
    });
  }

  // 重新识别
  void _retryListening() {
    _startListening();
  }

  // 确认结果
  void _confirmResult() {
    setState(() {
      _isCompleted = false;
      _statusMessage = '结果已确认';
    });
  }

  // 下载语言包
  Future<void> _downloadLanguagePack(LanguagePack pack) async {
    setState(() {
      _downloadProgress[pack.code] = 0.0;
    });

    // 模拟下载过程
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _downloadProgress[pack.code] = i / 10;
      });
    }

    setState(() {
      _downloadedPacks.add(pack);
      _downloadProgress.remove(pack.code);
    });
  }

  // 删除语言包
  void _deleteLanguagePack(LanguagePack pack) {
    setState(() {
      _downloadedPacks.remove(pack);
    });
  }

  // 检查语言包状态
  void _checkLanguagePackStatus(LanguagePack pack) {
    // 实际项目中会调用服务检查状态
    setState(() {
      _statusMessage = '检查${pack.name}状态...';
    });
  }

  // 切换识别模式
  void _toggleRecognitionMode() {
    final newMode = _voiceService.recognitionMode == RecognitionMode.precise
        ? RecognitionMode.general
        : RecognitionMode.precise;
    _voiceService.setRecognitionMode(newMode);
    setState(() {
      _statusMessage =
          '识别模式已切换为${newMode == RecognitionMode.precise ? '精准模式' : '通用模式'}';
    });
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('科大讯飞语音识别测试'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态信息
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '服务状态',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '初始化状态: ${_isInitialized ? '已初始化' : '未初始化'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '当前模式: ${_voiceService.recognitionMode == RecognitionMode.precise ? '精准模式' : '通用模式'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '状态: $_statusMessage',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '错误: $_errorMessage',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),

            // 语音输入动画
            if (_isListening) ...[
              Center(
                child: IFlytekVoiceAnimation(
                  isListening: _isListening,
                  soundLevel: _soundLevel,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 识别结果
            VoiceRecognitionResult(
              result: _recognitionResult,
              partialResult: _partialResult,
              isListening: _isListening,
              isCompleted: _isCompleted,
              onResultChanged: (result) {
                setState(() {
                  _recognitionResult = result;
                });
              },
              onConfirm: _confirmResult,
              onRetry: _retryListening,
            ),

            const SizedBox(height: 20),

            // 控制按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (!_isListening) ...[
                  ElevatedButton.icon(
                    onPressed: _startListening,
                    icon: const Icon(Icons.mic, size: 20),
                    label: const Text('开始识别'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _toggleRecognitionMode,
                    icon: Icon(
                      _voiceService.recognitionMode == RecognitionMode.precise
                          ? Icons.settings_suggest
                          : Icons.settings_voice,
                      size: 20,
                    ),
                    label: Text(
                      _voiceService.recognitionMode == RecognitionMode.precise
                          ? '切换到通用模式'
                          : '切换到精准模式',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight,
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: _stopListening,
                    icon: const Icon(Icons.stop, size: 20),
                    label: const Text('停止识别'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _cancelListening,
                    icon: const Icon(Icons.cancel, size: 20),
                    label: const Text('取消识别'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 30),

            // 离线语言包管理
            OfflineLanguagePackManager(
              availablePacks: _availablePacks,
              downloadedPacks: _downloadedPacks,
              onDownload: _downloadLanguagePack,
              onDelete: _deleteLanguagePack,
              onCheckStatus: _checkLanguagePackStatus,
              downloadProgress: _downloadProgress,
            ),
          ],
        ),
      ),
    );
  }
}
