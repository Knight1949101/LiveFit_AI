import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IFlytekVoiceRecognitionService {
  final String _appId = dotenv.env['IFLYTEK_APP_ID'] ?? '';
  final String _apiKey = dotenv.env['IFLYTEK_API_KEY'] ?? '';
  final String _apiSecret = dotenv.env['IFLYTEK_API_SECRET'] ?? '';

  static const MethodChannel _channel = MethodChannel(
    'iflytek_voice_recognition',
  );

  bool _isInitialized = false;
  bool _isListening = false;
  String _lastResult = '';
  double _confidence = 0.0;
  double _soundLevel = 0.0;

  // 识别模式
  RecognitionMode _recognitionMode = RecognitionMode.precise;

  // 重试计数
  int _retryCount = 0;
  static const int MAX_RETRIES = 3;

  // 获取状态
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get lastResult => _lastResult;
  double get confidence => _confidence;
  double get soundLevel => _soundLevel;
  RecognitionMode get recognitionMode => _recognitionMode;

  // 初始化服务
  Future<void> initialize() async {
    try {
      // 检查配置
      if (_appId.isEmpty || _apiKey.isEmpty || _apiSecret.isEmpty) {
        print(
          '科大讯飞配置缺失，请在.env文件中配置IFLYTEK_APP_ID、IFLYTEK_API_KEY、IFLYTEK_API_SECRET',
        );
        return;
      }

      // 请求权限
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        print('语音识别权限被拒绝');
        return;
      }

      // 初始化SDK
      _isInitialized = await _initSDK();
      if (_isInitialized) {
        print('科大讯飞语音识别服务初始化成功');
      } else {
        print('科大讯飞语音识别服务初始化失败');
      }
    } catch (e) {
      print('初始化科大讯飞语音识别服务失败: $e');
    }
  }

  // 请求权限
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

  // 初始化SDK
  Future<bool> _initSDK() async {
    try {
      // 通过MethodChannel调用原生Android代码初始化SDK
      final result = await _channel.invokeMethod<bool>('initSDK', {
        'appId': _appId,
        'apiKey': _apiKey,
        'apiSecret': _apiSecret,
      });
      return result ?? false;
    } catch (e) {
      print('初始化SDK失败: $e');
      return false;
    }
  }

  // 设置识别模式
  void setRecognitionMode(RecognitionMode mode) {
    _recognitionMode = mode;
  }

  // 开始语音识别
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onPartialResult,
    required Function(double) onConfidence,
    required Function(double) onSoundLevel,
    required Function(String) onStatus,
    required Function(String, VoiceRecognitionErrorType) onError,
  }) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        onError('语音识别服务初始化失败', VoiceRecognitionErrorType.initializationFailed);
        return;
      }
    }

    try {
      // 检查网络连接
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        onStatus('无网络连接，尝试使用离线识别');
        // 检查离线语言包是否存在
        final hasOfflinePack = await checkOfflineLanguagePack('zh_cn');
        if (!hasOfflinePack) {
          onError('无网络连接且未下载离线语言包', VoiceRecognitionErrorType.networkError);
          _isListening = false;
          return;
        }
      }

      _isListening = true;
      onStatus('开始识别...');

      // 重置重试计数
      _retryCount = 0;

      try {
        // 通过MethodChannel调用原生Android代码开始语音识别
        await _channel.invokeMethod('startListening', {
          'mode': _recognitionMode == RecognitionMode.precise
              ? 'precise'
              : 'general',
        });
      } on PlatformException catch (e) {
        // 处理平台异常
        switch (e.code) {
          case 'MICROPHONE_PERMISSION_DENIED':
            onError('麦克风权限被拒绝', VoiceRecognitionErrorType.permissionDenied);
            _isListening = false;
            return;
          case 'SDK_INITIALIZATION_FAILED':
            onError('SDK初始化失败', VoiceRecognitionErrorType.initializationFailed);
            _isListening = false;
            return;
          case 'NETWORK_ERROR':
            onError('网络错误', VoiceRecognitionErrorType.networkError);
            _isListening = false;
            return;
          default:
            onError('语音识别失败: ${e.message}', VoiceRecognitionErrorType.unknown);
            _isListening = false;
            return;
        }
      }

      // 模拟语音识别过程（实际项目中会通过事件回调获取结果）
      await Future.delayed(const Duration(seconds: 1), () {
        onPartialResult('正在识别...');
      });

      await Future.delayed(const Duration(seconds: 2), () {
        _lastResult = '这是一段测试语音识别结果';
        _confidence = 0.95;
        _soundLevel = 0.5;

        onResult(_lastResult);
        onConfidence(_confidence);
        onSoundLevel(_soundLevel);
        onStatus('识别完成');

        _isListening = false;
      });
    } catch (e) {
      final errorType = _determineErrorType(e);
      onError('识别失败: $e', errorType);
      _isListening = false;

      // 尝试重试
      if (_retryCount < MAX_RETRIES) {
        // 只对特定错误类型进行重试
        if ([
          VoiceRecognitionErrorType.networkError,
          VoiceRecognitionErrorType.unknown,
        ].contains(errorType)) {
          _retryCount++;
          onStatus('正在重试 ($_retryCount/$MAX_RETRIES)');
          await Future.delayed(
            Duration(milliseconds: 500 * _retryCount),
          ); // 递增重试间隔
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
  }

  // 停止识别
  Future<void> stopListening() async {
    try {
      if (_isListening) {
        // 通过MethodChannel调用原生Android代码停止语音识别
        await _channel.invokeMethod('stopListening');
        _isListening = false;
        print('停止语音识别');
      }
    } catch (e) {
      print('停止识别失败: $e');
    }
  }

  // 取消识别
  Future<void> cancelListening() async {
    try {
      if (_isListening) {
        // 通过MethodChannel调用原生Android代码取消语音识别
        await _channel.invokeMethod('cancelListening');
        _isListening = false;
        print('取消语音识别');
      }
    } catch (e) {
      print('取消识别失败: $e');
    }
  }

  // 下载离线语言包
  Future<bool> downloadOfflineLanguagePack(String languageCode) async {
    try {
      print('开始下载离线语言包: $languageCode');
      // 通过MethodChannel调用原生Android代码下载语言包
      final result = await _channel.invokeMethod<bool>('downloadLanguagePack', {
        'language': languageCode,
      });
      print('离线语言包下载完成');
      return result ?? false;
    } catch (e) {
      print('下载离线语言包失败: $e');
      return false;
    }
  }

  // 删除离线语言包
  Future<bool> deleteOfflineLanguagePack(String languageCode) async {
    try {
      print('开始删除离线语言包: $languageCode');
      // 通过MethodChannel调用原生Android代码删除语言包
      final result = await _channel.invokeMethod<bool>('deleteLanguagePack', {
        'language': languageCode,
      });
      print('离线语言包删除完成');
      return result ?? false;
    } catch (e) {
      print('删除离线语言包失败: $e');
      return false;
    }
  }

  // 检查离线语言包是否存在
  Future<bool> checkOfflineLanguagePack(String languageCode) async {
    try {
      // 通过MethodChannel调用原生Android代码检查语言包
      final result = await _channel.invokeMethod<bool>('checkLanguagePack', {
        'language': languageCode,
      });
      return result ?? false;
    } catch (e) {
      print('检查离线语言包失败: $e');
      return false;
    }
  }

  // 销毁服务
  Future<void> dispose() async {
    try {
      if (_isListening) {
        await cancelListening();
      }
      _isInitialized = false;
      print('科大讯飞语音识别服务已销毁');
    } catch (e) {
      print('销毁服务失败: $e');
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

// 语音识别错误类型枚举
enum VoiceRecognitionErrorType {
  initializationFailed, // 初始化失败
  permissionDenied, // 权限被拒绝
  networkError, // 网络错误
  microphoneError, // 麦克风错误
  recognitionFailed, // 识别失败
  timeout, // 超时
  unknown, // 未知错误
}

// 错误类型判断方法
VoiceRecognitionErrorType _determineErrorType(dynamic error) {
  if (error is PlatformException) {
    switch (error.code) {
      case 'PERMISSION_DENIED':
      case 'MICROPHONE_PERMISSION_DENIED':
        return VoiceRecognitionErrorType.permissionDenied;
      case 'NETWORK_ERROR':
      case 'NO_INTERNET':
        return VoiceRecognitionErrorType.networkError;
      case 'MICROPHONE_ERROR':
      case 'AUDIO_RECORD_ERROR':
        return VoiceRecognitionErrorType.microphoneError;
      case 'INITIALIZATION_FAILED':
      case 'SDK_INITIALIZATION_FAILED':
        return VoiceRecognitionErrorType.initializationFailed;
      case 'RECOGNITION_FAILED':
        return VoiceRecognitionErrorType.recognitionFailed;
      case 'TIMEOUT':
        return VoiceRecognitionErrorType.timeout;
      default:
        return VoiceRecognitionErrorType.unknown;
    }
  }

  if (error is TimeoutException) {
    return VoiceRecognitionErrorType.timeout;
  }

  if (error.toString().contains('network') ||
      error.toString().contains('internet')) {
    return VoiceRecognitionErrorType.networkError;
  }

  if (error.toString().contains('permission') ||
      error.toString().contains('denied')) {
    return VoiceRecognitionErrorType.permissionDenied;
  }

  if (error.toString().contains('microphone') ||
      error.toString().contains('audio')) {
    return VoiceRecognitionErrorType.microphoneError;
  }

  return VoiceRecognitionErrorType.unknown;
}
