
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../utils/env_utils.dart';

/// 阿里云语音识别服务
/// 集成阿里云HTTP API和本地离线识别作为备选
class AliyunVoiceRecognitionService {
  // 阿里云API配置
  static String get apiUrl => EnvUtils.get('ALICLOUD_VOICE_API_URL', defaultValue: 'https://nls-gateway.cn-shanghai.aliyuncs.com/stream/v1/asr')!;
  static String get accessKeyId => EnvUtils.get('ALICLOUD_ACCESS_KEY_ID', defaultValue: '')!;
  static String get accessKeySecret => EnvUtils.get('ALICLOUD_ACCESS_KEY_SECRET', defaultValue: '')!;
  static String get appKey => EnvUtils.get('ALICLOUD_VOICE_APP_KEY', defaultValue: '')!;

  // 本地识别服务
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  // 服务状态
  bool _isInitialized = false;
  bool _isUsingOffline = false;

  // 识别结果
  String _lastWords = '';
  double _confidence = 0.0;
  String _currentLocale = 'zh_CN';

  // 初始化服务
  Future<void> initSpeech() async {
    try {
      print('开始初始化阿里云语音识别服务...');

      // 检查阿里云API配置
      final hasAliyunConfig = accessKeyId.isNotEmpty && accessKeySecret.isNotEmpty && appKey.isNotEmpty;
      print('阿里云API配置状态: $hasAliyunConfig');

      // 初始化本地语音识别作为备选
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          print('本地语音识别状态: $status');
        },
        onError: (error) {
          print('本地语音识别错误: ${error.errorMsg}');
        },
      );
      print('本地语音识别初始化结果: $_speechEnabled');

      // 设置初始化标志
      _isInitialized = true;

      // 检查是否需要使用离线模式
      _isUsingOffline = !hasAliyunConfig || !_speechEnabled;
      if (_isUsingOffline) {
        print('使用离线识别模式');
      }
    } catch (e) {
      print('初始化语音识别服务出错: $e');
      _isInitialized = true;
      _isUsingOffline = true;
    }
  }

  // 开始监听
  void startListening({
    required Function(String) onResult,
    required Function(String) onPartialResult,
    required Function(double) onConfidence,
    required Function(double) onSoundLevel,
    required Function(String) onStatus,
    required Function(String) onError,
  }) async {
    try {
      if (!_isInitialized) {
        await initSpeech();
      }

      // 检查是否可以使用阿里云API
      final canUseAliyun = accessKeyId.isNotEmpty && accessKeySecret.isNotEmpty && appKey.isNotEmpty;

      if (canUseAliyun) {
        // 使用阿里云API
        await _startAliyunRecognition(
          onResult: onResult,
          onPartialResult: onPartialResult,
          onConfidence: onConfidence,
          onSoundLevel: onSoundLevel,
          onStatus: onStatus,
          onError: onError,
        );
      } else {
        // 使用本地识别作为备选
        await _startLocalRecognition(
          onResult: onResult,
          onPartialResult: onPartialResult,
          onConfidence: onConfidence,
          onSoundLevel: onSoundLevel,
          onStatus: onStatus,
          onError: onError,
        );
      }
    } catch (e) {
      print('开始语音识别出错: $e');
      onError('开始语音识别时出错: $e');
    }
  }

  // 使用阿里云API进行识别
  Future<void> _startAliyunRecognition({
    required Function(String) onResult,
    required Function(String) onPartialResult,
    required Function(double) onConfidence,
    required Function(double) onSoundLevel,
    required Function(String) onStatus,
    required Function(String) onError,
  }) async {
    try {
      onStatus('正在连接阿里云语音识别服务...');

      // 生成Access Token
      final token = await _getAccessToken();
      if (token == null) {
        onError('获取阿里云Access Token失败');
        // 回退到本地识别
        await _startLocalRecognition(
          onResult: onResult,
          onPartialResult: onPartialResult,
          onConfidence: onConfidence,
          onSoundLevel: onSoundLevel,
          onStatus: onStatus,
          onError: onError,
        );
        return;
      }

      onStatus('使用阿里云语音识别服务');

      // 注意：这里是简化实现，实际需要：
      // 1. 开始录音
      // 2. 流式上传音频数据
      // 3. 处理实时返回结果
      
      // 由于阿里云API需要复杂的音频流处理，这里我们先使用本地识别作为过渡
      // 同时提示用户需要完整集成
      onError('阿里云语音识别API需要完整集成，暂时使用本地识别');
      await _startLocalRecognition(
        onResult: onResult,
        onPartialResult: onPartialResult,
        onConfidence: onConfidence,
        onSoundLevel: onSoundLevel,
        onStatus: onStatus,
        onError: onError,
      );
    } catch (e) {
      print('阿里云语音识别出错: $e');
      onError('阿里云语音识别失败: $e');
      // 回退到本地识别
      await _startLocalRecognition(
        onResult: onResult,
        onPartialResult: onPartialResult,
        onConfidence: onConfidence,
        onSoundLevel: onSoundLevel,
        onStatus: onStatus,
        onError: onError,
      );
    }
  }

  // 使用本地识别
  Future<void> _startLocalRecognition({
    required Function(String) onResult,
    required Function(String) onPartialResult,
    required Function(double) onConfidence,
    required Function(double) onSoundLevel,
    required Function(String) onStatus,
    required Function(String) onError,
  }) async {
    try {
      if (!_speechEnabled) {
        onError('本地语音识别服务不可用');
        return;
      }

      onStatus('使用本地语音识别服务');

      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          if (result.finalResult) {
            _lastWords = result.recognizedWords;
            _confidence = result.confidence;
            
            onResult(_lastWords);
            onConfidence(_confidence);
            onStatus('识别完成');
          } else {
            // 处理部分结果
            onPartialResult(result.recognizedWords);
          }
        },
        onSoundLevelChange: (level) {
          onSoundLevel(level);
        },
        listenFor: const Duration(minutes: 3),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocale,
        onDevice: true, // 使用离线识别
        listenMode: ListenMode.dictation,
      );

      onStatus('开始监听...');
    } catch (e) {
      print('本地语音识别出错: $e');
      onError('本地语音识别失败: $e');
    }
  }

  // 获取阿里云Access Token
  Future<String?> _getAccessToken() async {
    try {
      if (accessKeyId.isEmpty || accessKeySecret.isEmpty) {
        return null;
      }

      // 这里简化实现，实际需要使用阿里云STS服务获取Token
      // 或者使用SDK生成签名
      print('获取阿里云Access Token...');
      // 模拟返回Token
      return 'mock_access_token';
    } catch (e) {
      print('获取Access Token出错: $e');
      return null;
    }
  }

  // 停止监听
  Future<void> stopListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
    } catch (e) {
      print('停止监听出错: $e');
    }
  }

  // 取消监听
  Future<void> cancelListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.cancel();
      }
    } catch (e) {
      print('取消监听出错: $e');
    }
  }

  // 获取监听状态
  bool get isListening {
    try {
      return _speechToText.isListening;
    } catch (e) {
      print('获取监听状态出错: $e');
      return false;
    }
  }

  // 获取服务可用性
  bool get isAvailable {
    return _isInitialized && (_speechEnabled || (accessKeyId.isNotEmpty && accessKeySecret.isNotEmpty));
  }

  // 获取最后识别结果
  String get lastWords => _lastWords;

  // 获取置信度
  double get confidence => _confidence;

  // 获取当前使用模式
  bool get isUsingOffline => _isUsingOffline;

  // 清理资源
  Future<void> dispose() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.cancel();
      }
    } catch (e) {
      print('清理资源出错: $e');
    }
  }
}

/// 离线语音识别服务
/// 专门用于无网络环境的语音识别
class OfflineVoiceRecognitionService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _speechEnabled = false;

  // 初始化服务
  Future<void> initSpeech() async {
    try {
      print('初始化离线语音识别服务...');

      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          print('离线语音识别状态: $status');
        },
        onError: (error) {
          print('离线语音识别错误: ${error.errorMsg}');
        },
      );

      _isInitialized = true;
      print('离线语音识别初始化结果: $_speechEnabled');
    } catch (e) {
      print('初始化离线语音识别服务出错: $e');
      _isInitialized = true;
      _speechEnabled = false;
    }
  }

  // 开始监听
  void startListening({
    required Function(String) onResult,
    required Function(String) onPartialResult,
    required Function(double) onConfidence,
    required Function(double) onSoundLevel,
    required Function(String) onStatus,
    required Function(String) onError,
  }) async {
    try {
      if (!_isInitialized) {
        await initSpeech();
      }

      if (!_speechEnabled) {
        onError('离线语音识别服务不可用');
        return;
      }

      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            onConfidence(result.confidence);
            onStatus('识别完成');
          } else {
            // 处理部分结果
            onPartialResult(result.recognizedWords);
          }
        },
        onSoundLevelChange: (level) {
          onSoundLevel(level);
        },
        listenFor: const Duration(minutes: 3),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: 'zh_CN',
        onDevice: true, // 强制使用离线识别
        listenMode: ListenMode.dictation,
      );

      onStatus('开始离线监听...');
    } catch (e) {
      print('离线语音识别出错: $e');
      onError('离线语音识别失败: $e');
    }
  }

  // 停止监听
  Future<void> stopListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
    } catch (e) {
      print('停止离线监听出错: $e');
    }
  }

  // 取消监听
  Future<void> cancelListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.cancel();
      }
    } catch (e) {
      print('取消离线监听出错: $e');
    }
  }

  // 获取监听状态
  bool get isListening {
    try {
      return _speechToText.isListening;
    } catch (e) {
      print('获取离线监听状态出错: $e');
      return false;
    }
  }

  // 获取服务可用性
  bool get isAvailable => _isInitialized && _speechEnabled;

  // 清理资源
  Future<void> dispose() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.cancel();
      }
    } catch (e) {
      print('清理离线资源出错: $e');
    }
  }
}
