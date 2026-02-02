import 'dart:async';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class VoiceRecognitionService {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  double _confidence = 0.0;
  double _soundLevel = 0.0;
  String _currentLocale = 'zh_CN'; // 默认中文
  List<String> _availableLocales = [];

  // 识别模式
  RecognitionMode _recognitionMode = RecognitionMode.precise;

  // 重试计数
  int _retryCount = 0;
  static const int MAX_RETRIES = 3;

  // 获取可用的语言列表
  List<String> get availableLocales => _availableLocales;
  String get currentLocale => _currentLocale;
  double get soundLevel => _soundLevel;
  RecognitionMode get recognitionMode => _recognitionMode;
  bool get isAvailable => _speechEnabled;

  // 初始化语音识别服务
  Future<void> initSpeech() async {
    try {
      // 请求权限
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        print('语音识别权限被拒绝');
        _speechEnabled = false;
        return;
      }

      // 初始化本地语音识别
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          print('语音识别状态: $status');
        },
        onError: (errorNotification) {
          print('语音识别错误: ${errorNotification.errorMsg}');
        },
      );

      // 获取可用的语言列表
      if (_speechEnabled) {
        final locales = await _speechToText.locales();
        _availableLocales = locales.map((locale) => locale.localeId).toList();
        print('可用语言列表: $_availableLocales');
      }
    } catch (e) {
      print('语音识别初始化失败: $e');
      _speechEnabled = false;
    }
  }

  // 请求必要权限
  Future<bool> _requestPermissions() async {
    // 麦克风权限
    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      return false;
    }

    // 存储权限（用于离线语言包）
    final storagePermission = await Permission.storage.request();
    if (!storagePermission.isGranted) {
      return false;
    }

    return true;
  }

  // 设置语言
  void setLocale(String localeId) {
    _currentLocale = localeId;
  }

  // 设置识别模式
  void setRecognitionMode(RecognitionMode mode) {
    _recognitionMode = mode;
  }

  // 开始监听
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onPartialResult,
    required Function(double) onConfidence,
    required Function(double) onSoundLevel,
    required Function(String) onStatus,
    required Function(String) onError,
  }) async {
    if (!_speechEnabled) {
      await initSpeech();
      if (!_speechEnabled) {
        onError('语音识别服务初始化失败');
        return;
      }
    }

    try {
      // 检查网络连接
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        onStatus('无网络连接，尝试使用离线识别');
      }

      // 重置重试计数
      _retryCount = 0;

      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          _lastWords = result.recognizedWords;
          _confidence = result.confidence;

          // 根据识别模式和置信度处理结果
          if (_confidence < 0.7 && _retryCount < MAX_RETRIES) {
            _retryCount++;
            onStatus('识别结果置信度低，正在重试 ($_retryCount/$MAX_RETRIES)');
            // 可以在这里添加云端API调用逻辑
          } else {
            onResult(_lastWords);
            onConfidence(_confidence);
            onStatus('识别完成');
          }
        },
        onSoundLevelChange: (level) {
          _soundLevel = level;
          onSoundLevel(level);
        },
        listenFor: const Duration(minutes: 3),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocale,
        // 根据识别模式调整参数
        cancelOnError: _recognitionMode == RecognitionMode.general,
        listenMode: _recognitionMode == RecognitionMode.precise
            ? ListenMode.confirmation
            : ListenMode.dictation,
      );

      onStatus('开始识别...');
    } catch (e) {
      onError('开始识别失败: $e');
      // 尝试重试
      if (_retryCount < MAX_RETRIES) {
        _retryCount++;
        onStatus('正在重试 ($_retryCount/$MAX_RETRIES)');
        await Future.delayed(const Duration(milliseconds: 500));
        await startListening(
          onResult: onResult,
          onPartialResult: onPartialResult,
          onConfidence: onConfidence,
          onSoundLevel: onSoundLevel,
          onStatus: onStatus,
          onError: onError,
        );
      }
    }
  }

  // 停止监听
  Future<void> stopListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
    } catch (e) {
      print('停止识别失败: $e');
    }
  }

  // 取消监听
  Future<void> cancelListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.cancel();
      }
    } catch (e) {
      print('取消识别失败: $e');
    }
  }

  // 检查是否正在监听
  bool get isListening => _speechToText.isListening;

  // 获取最后识别的文本
  String get lastWords => _lastWords;

  // 获取最后识别的置信度
  double get confidence => _confidence;

  // 销毁服务
  Future<void> dispose() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.cancel();
      }
    } catch (e) {
      print('销毁语音识别服务失败: $e');
    }
  }
}

// 识别模式枚举
enum RecognitionMode {
  precise, // 精准模式，适合安静环境
  general, // 通用模式，适合嘈杂环境
}

// 识别状态枚举
enum RecognitionStatus {
  idle, // 空闲
  initializing, // 初始化中
  listening, // 监听中
  processing, // 处理中
  completed, // 完成
  error, // 错误
}
