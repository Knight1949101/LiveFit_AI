import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/iflytek_voice_recognition_service.dart';
import '../../../../core/services/nlp_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/event_bus_service.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../schedule/domain/models/schedule_event.dart';
import '../../../schedule/presentation/pages/schedule_edit_page.dart';
import '../../../schedule/presentation/pages/manual_schedule_page.dart';
import '../../../schedule/domain/services/schedule_conflict_detector.dart';
import '../widgets/voice_wave_animation.dart';
import '../widgets/schedule_preview_card.dart';
import '../../../schedule/presentation/widgets/conflict_resolution_dialog.dart';
import '../../../../core/services/log_service.dart';

class VoiceScheduleScreen extends StatefulWidget {
  const VoiceScheduleScreen({super.key});

  @override
  State<VoiceScheduleScreen> createState() => _VoiceScheduleScreenState();
}

class _VoiceScheduleScreenState extends State<VoiceScheduleScreen> {
  final IFlytekVoiceRecognitionService _voiceService =
      IFlytekVoiceRecognitionService();
  final NlpService _nlpService = NlpService();
  final AiService _aiService = AiService();
  final StorageService _storageService = StorageService();
  final ScheduleConflictDetector _conflictDetector = ScheduleConflictDetector();
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isOnline = false; // 初始化为false，避免在网络检查完成前尝试初始化语音服务
  String _recognizedText = '';
  String _partialText = '';
  double _confidence = 0.0;
  List<ScheduleEvent> _generatedSchedules = [];
  List<ScheduleEvent> _existingEvents = [];
  String _clarificationQuestion = '';
  Map<String, dynamic> _ambiguousSchedule = {};

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// 初始化屏幕，按顺序执行初始化操作
  Future<void> _initializeScreen() async {
    try {
      await _checkNetworkStatus();
      await _initSpeechService();
      await _loadExistingEvents();
    } catch (e, stackTrace) {
      log.error('初始化屏幕出错: $e');
      log.error('堆栈跟踪: $stackTrace');
      // 显示初始化错误信息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('初始化语音日程功能失败: $e'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 检查网络状态
  Future<void> _checkNetworkStatus() async {
    final isOnline = await _aiService.isConnected();
    setState(() {
      _isOnline = isOnline;
    });

    if (!isOnline) {
      // 离线状态下显示提示信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('未连接到网络，仅支持手动输入日程'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// 初始化语音服务并检查状态
  Future<void> _initSpeechService() async {
    try {
      // 初始化科大讯飞语音服务
      await _voiceService.initialize();

      // 仅在在线状态下检查语音服务是否可用
      if (_isOnline) {
        // 检查科大讯飞语音服务是否可用
        if (!_voiceService.isInitialized) {
          // 如果不可用，显示详细提示信息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '语音识别不可用。请检查：\n'
                '1. 设备是否支持语音识别\n'
                '2. 科大讯飞SDK是否正确配置\n'
                '3. 应用是否有麦克风权限\n'
                '4. 小米设备请检查应用权限设置中的"语音识别"权限',
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      // 处理初始化错误，显示详细信息
      log.error('语音服务初始化失败异常: $e');
      log.error('堆栈跟踪: $stackTrace');

      String errorMsg;
      if (e.toString().contains('permission')) {
        errorMsg = '请授予应用麦克风权限以使用语音识别功能。';
      } else {
        errorMsg = '语音服务初始化失败: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), duration: Duration(seconds: 2)),
      );
    }
  }

  // Load existing schedule events from storage
  Future<void> _loadExistingEvents() async {
    final events = await _storageService.loadActiveEvents();
    if (events != null) {
      setState(() {
        _existingEvents = events;
      });
    }
  }

  void _startListening() async {
    // 检查网络状态
    await _checkNetworkStatus();

    if (!_isOnline) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('未连接到网络，请使用手动输入功能')));
      return;
    }

    // 检查麦克风权限
    final permissionStatus = await Permission.microphone.status;

    if (permissionStatus != PermissionStatus.granted) {
      // 请求麦克风权限
      final result = await Permission.microphone.request();
      if (result != PermissionStatus.granted) {
        // 权限被拒绝，显示提示信息
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('需要麦克风权限才能使用语音识别功能')));
        return;
      }
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _partialText = '';
      _confidence = 0.0;
      _generatedSchedules = []; // Clear previous results
    });

    try {
      log.debug('开始调用语音识别服务...');
      await _voiceService.startListening(
        onResult: (result) {
          setState(() {
            _recognizedText = result;
          });
        },
        onPartialResult: (partialResult) {
          setState(() {
            _partialText = partialResult;
          });
        },
        onConfidence: (confidence) {
          setState(() {
            _confidence = confidence;
          });
        },
        onSoundLevel: (level) {
          // Sound level is not used in the UI
        },
        onStatus: (status) {
          // Handle status changes if needed
          log.debug('语音状态变化: $status');
          if (status == 'completed' || status == 'error') {
            setState(() {
              _isListening = false;
              _isProcessing = true;
            });
            // Process the recognized text
            _processRecognizedText();
          }
        },
        onError: (error, errorType) {
          setState(() {
            _isListening = false;
          });
          // Show error message
          log.error('语音识别错误: $error');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('语音识别错误: $error')));
        },
      );
    } catch (e, stackTrace) {
      setState(() {
        _isListening = false;
      });
      log.error('调用语音识别服务出错: $e');
      log.error('堆栈跟踪: $stackTrace');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('调用语音识别服务出错: $e')));
    }
  }

  void _stopListening() async {
    try {
      await _voiceService.stopListening();
    } catch (e) {
      log.error('停止监听出错: $e');
    }
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });

    // Process the recognized text
    await _processRecognizedText();
  }

  Future<void> _processRecognizedText() async {
    try {
      // 检查网络状态
      await _checkNetworkStatus();

      if (!_isOnline) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('未连接到网络，请使用手动输入功能')));
        return;
      }

      // Use NLP service to extract schedule events
      final textToProcess = _recognizedText.isNotEmpty
          ? _recognizedText
          : _partialText;

      if (textToProcess.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('未识别到语音内容，请重试')));
        return;
      }

      // 检查是否正在处理澄清问题
      if (_clarificationQuestion.isNotEmpty && _ambiguousSchedule.isNotEmpty) {
        await _handleClarificationResponse(textToProcess);
        return;
      }

      // 使用AI服务解析文本
      final extractedEvents = await _aiService.extractScheduleEvents(
        textToProcess,
      );
      final scheduleEvents = extractedEvents
          .map((event) => _nlpService.toScheduleEvent(event))
          .toList();

      if (scheduleEvents.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('未能从语音中提取日程信息，请尝试更清晰的表达')));
        return;
      }

      // 检查生成的日程是否有模糊信息
      final processedEvents = <ScheduleEvent>[];
      for (var event in scheduleEvents) {
        final scheduleMap = {
          'title': event.title,
          'startTime': event.startTime,
          'endTime': event.endTime,
          'location': event.location,
          'description': event.description,
          'type': event.type.name,
          'priority': event.priority,
        };

        // 检测模糊信息
        final ambiguities = _detectAmbiguity(scheduleMap);
        if (ambiguities.isNotEmpty) {
          // 有模糊信息，生成AI澄清问题
          final question = await _aiService.generateClarificationQuestion(
            ambiguities[0],
            scheduleMap,
            textToProcess,
          );

          setState(() {
            _isProcessing = false;
            _ambiguousSchedule = scheduleMap;
            _clarificationQuestion = question;
          });
          return;
        } else {
          processedEvents.add(event);
        }
      }

      setState(() {
        _isProcessing = false;
        _generatedSchedules = processedEvents;
        _clarificationQuestion = '';
        _ambiguousSchedule = {};
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      // 处理AI处理过程中的错误
      String errorMsg = '处理语音内容时出错';
      if (e.toString().contains('未连接到网络')) {
        errorMsg = '未连接到网络，请使用手动输入功能';
      } else {
        errorMsg = '处理语音内容时出错: $e';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  /// 处理用户对澄清问题的回答
  Future<void> _handleClarificationResponse(String response) async {
    try {
      // 检查网络状态
      await _checkNetworkStatus();

      if (!_isOnline) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('未连接到网络，请使用手动输入功能')));
        return;
      }

      // 使用AI服务处理澄清回答
      final combinedText =
          '$_recognizedText\n$_clarificationQuestion\n$response';
      final processedEvent = await _aiService.parseSingleEvent(combinedText);

      if (processedEvent != null) {
        // 将AI处理结果转换为ScheduleEvent
        final scheduleEvent = _nlpService.toScheduleEvent(processedEvent);
        setState(() {
          _isProcessing = false;
          _generatedSchedules = [scheduleEvent];
          _clarificationQuestion = '';
          _ambiguousSchedule = {};
        });
      } else {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('处理澄清回答时出错，请重试')));
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      String errorMsg = '处理澄清回答时出错';
      if (e.toString().contains('未连接到网络')) {
        errorMsg = '未连接到网络，请使用手动输入功能';
      } else {
        errorMsg = '处理澄清回答时出错: $e';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  /// 检测日程中的模糊信息
  List<String> _detectAmbiguity(Map<String, dynamic> schedule) {
    final List<String> ambiguities = [];

    // 标题模糊检测
    if (schedule['title'] == '未命名事件' ||
        (schedule['title'] as String).length < 3) {
      ambiguities.add('title');
    }

    // 时间模糊检测
    try {
      final now = DateTime.now();
      DateTime startTime;

      // 检查startTime是否已经是DateTime对象，如果不是则尝试解析
      if (schedule['startTime'] is DateTime) {
        startTime = schedule['startTime'] as DateTime;
      } else {
        startTime = DateTime.parse(schedule['startTime'] as String);
      }

      final diff = startTime.difference(now);
      final description = schedule['description'] as String? ?? '';
      if (diff.inHours < 24 && !description.contains('今天')) {
        ambiguities.add('time');
      }
    } catch (e) {
      // 如果时间解析失败，添加时间模糊标记
      ambiguities.add('time');
    }

    // 地点模糊检测
    final location = schedule['location'] as String? ?? '';
    if (location.isEmpty) {
      ambiguities.add('location');
    }

    return ambiguities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('语音日程'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_note),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManualSchedulePage(
                    onSave: (newEvent) async {
                      // 保存新事件到存储
                      final existingEvents =
                          await _storageService.loadActiveEvents() ?? [];
                      final updatedEvents = [...existingEvents, newEvent];
                      await _storageService.saveScheduleEvents(updatedEvents);

                      // 发送日程更新事件，通知其他页面刷新
                      EventBusService().fireEvent(
                        EventBusService.eventScheduleUpdated,
                      );

                      // 返回上一页并显示成功消息
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('日程保存成功')));
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimary
                : AppColors.textPrimaryLight,
            tooltip: '手动添加日程',
          ),
        ],
      ),
      body: Column(
        children: [
          // Voice recognition results display
          if (_isListening ||
              _recognizedText.isNotEmpty ||
              _partialText.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '识别结果',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isListening ? _partialText : _recognizedText,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_confidence > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Text(
                            '置信度: ${(_confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textDisabled,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _confidence,
                              backgroundColor: Colors.grey[300],
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          // 澄清问题显示
          if (_clarificationQuestion.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 提问',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _clarificationQuestion,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '请长按麦克风回答',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(child: _buildContent(context)),
          _buildBottomControl(),
          if (_generatedSchedules.isNotEmpty) _buildImportButton(),
        ],
      ),
    );
  }

  // Build import button
  Widget _buildImportButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          // Implement import functionality
          _showImportConfirmation();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text('导入到日程'),
      ),
    );
  }

  // Show import confirmation dialog
  void _showImportConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认导入'),
        content: Text('您确定要导入 ${_generatedSchedules.length} 个日程吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement actual import logic
              Navigator.pop(context);
              _importSchedules();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('导入'),
          ),
        ],
      ),
    );
  }

  // Import schedules to main schedule
  Future<void> _importSchedules() async {
    List<ScheduleEvent> eventsToImport = [];

    // Check for conflicts for each generated schedule
    for (var event in _generatedSchedules) {
      final conflicts = _conflictDetector.detectConflictsForEvent(
        event,
        _existingEvents,
      );

      if (conflicts.isNotEmpty) {
        // Handle conflicts
        final hasResolvedConflict = await _handleConflict(event, conflicts);
        if (hasResolvedConflict) {
          eventsToImport.add(event);
        }
      } else {
        // No conflicts, add to import list
        eventsToImport.add(event);
      }
    }

    if (eventsToImport.isNotEmpty) {
      // Load current events again to ensure we have the latest data
      await _loadExistingEvents();

      // Merge with existing events
      final updatedEvents = [..._existingEvents, ...eventsToImport];

      // Save to storage
      final success = await _storageService.saveScheduleEvents(updatedEvents);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('导入成功')));

        // Clear the generated schedules after import
        setState(() {
          _generatedSchedules.clear();
          _recognizedText = '';
          _partialText = '';
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('导入失败')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('没有可导入的事件')));
    }
  }

  // Handle schedule conflicts
  Future<bool> _handleConflict(
    ScheduleEvent newEvent,
    List<ScheduleConflict> conflicts,
  ) async {
    final completer = Completer<bool>();

    showDialog(
      context: context,
      builder: (context) => ConflictResolutionDialog(
        newEvent: newEvent,
        conflicts: conflicts,
        onKeepExisting: () {
          // Keep existing events, don't import this one
          Navigator.pop(context);
          completer.complete(false);
        },
        onReplaceExisting: () async {
          // Replace existing conflicting events
          Navigator.pop(context);
          completer.complete(true);
        },
        onAdjustTime: () {
          // Navigate to edit page to adjust time
          Navigator.pop(context);
          _navigateToEditPage(context, newEvent);
          completer.complete(false); // Will re-import after edit
        },
      ),
    );

    return completer.future;
  }

  Widget _buildContent(BuildContext context) {
    if (_isProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              '正在处理您的计划...',
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      );
    }

    if (_generatedSchedules.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _generatedSchedules.length,
        itemBuilder: (context, index) {
          final event = _generatedSchedules[index];
          return SchedulePreviewCard(
            title: event.title,
            timeRange:
                '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - ${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
            type: event.type.toString().split('.').last,
            onEdit: () {
              _navigateToEditPage(context, event);
            },
            onDelete: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('确认删除'),
                  content: Text('您确定要删除这个日程吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _generatedSchedules.removeAt(index);
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        '删除',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    // 离线状态下显示离线提示
    if (!_isOnline) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text(
              '未连接到网络',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请使用手动输入功能添加日程',
              style: TextStyle(color: AppColors.textDisabled),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 跳转到手动输入页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManualSchedulePage(
                      onSave: (newEvent) async {
                        // 保存新事件到存储
                        final existingEvents =
                            await _storageService.loadActiveEvents() ?? [];
                        final updatedEvents = [...existingEvents, newEvent];
                        await _storageService.saveScheduleEvents(updatedEvents);

                        // 发送日程更新事件，通知其他页面刷新
                        EventBusService().fireEvent(
                          EventBusService.eventScheduleUpdated,
                        );

                        // 返回上一页并显示成功消息
                        Navigator.pop(context);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('日程保存成功')));
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(200, 50),
              ),
              child: Text('手动输入日程'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          VoiceWaveAnimation(isListening: _isListening),
          const SizedBox(height: 32),
          Text(
            _isListening ? '正在聆听...' : '长按麦克风开始说话',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: _isListening
                  ? AppColors.primary
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (!_isListening)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '例如：明天上午10点开会，下午3点去健身房',
                style: TextStyle(color: AppColors.textDisabled),
              ),
            ),
        ],
      ),
    );
  }

  // Navigate to schedule edit page
  void _navigateToEditPage(BuildContext context, ScheduleEvent? event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleEditPage(
          initialEvent: event,
          onSave: (editedEvent) {
            if (event != null) {
              // Edit existing event
              final index = _generatedSchedules.indexWhere(
                (e) => e.id == event.id,
              );
              if (index != -1) {
                setState(() {
                  _generatedSchedules[index] = editedEvent;
                });
              }
            } else {
              // Add new event
              setState(() {
                _generatedSchedules.add(editedEvent);
              });
            }
            Navigator.pop(context);
          },
          onCancel: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildBottomControl() {
    // 离线状态下不显示语音控制按钮
    if (!_isOnline) {
      return SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(32),
      child: SizedBox(
        width: 80,
        height: 80,
        child: GestureDetector(
          // 按下录音
          onLongPressStart: (_) => _startListening(),
          // 松开结束
          onLongPressEnd: (_) => _stopListening(),
          child: FloatingActionButton(
            onPressed: () {}, // 禁用点击，只允许长按
            backgroundColor: _isListening ? AppColors.error : AppColors.primary,
            elevation: 4,
            shape: const CircleBorder(),
            child: Icon(
              _isListening ? Icons.stop : Icons.mic,
              size: 36,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
