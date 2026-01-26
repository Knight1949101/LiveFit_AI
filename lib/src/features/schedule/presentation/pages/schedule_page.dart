import 'package:flutter/material.dart';
import 'package:life_fit/src/core/theme/app_colors.dart';
import 'package:life_fit/src/features/schedule/domain/models/schedule_event.dart';
import 'package:life_fit/src/features/schedule/presentation/widgets/calendar_strip.dart';
import 'package:life_fit/src/features/schedule/presentation/widgets/timeline_view.dart';
import 'package:life_fit/src/features/schedule/presentation/widgets/event_card.dart';
import '../../../../core/services/event_bus_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/operation_log_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../voice_schedule/presentation/screens/voice_schedule_screen.dart';

enum ViewType { calendar, list }

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with AutomaticKeepAliveClientMixin<SchedulePage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<ScheduleEvent>> _events;
  late List<ScheduleEvent> _allEvents;
  late List<ScheduleEvent> _allEventsIncludingDeleted;
  ViewType _currentView = ViewType.calendar;
  bool _isMultiSelectMode = false;
  List<String> _selectedEventIds = [];

  // 滑动相关变量
  double _dragStartX = 0;
  double _dragEndX = 0;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _events = {}; // Initialize with empty map
    _allEvents = []; // Initialize with empty list
    _loadEvents();

    // 监听日程更新事件
    EventBusService().onEvent(EventBusService.eventScheduleUpdated).listen((
      event,
    ) {
      _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    try {
      final storageService = StorageService();
      final allEvents = await storageService.loadScheduleEvents();
      if (allEvents != null) {
        // Save all events including deleted ones
        _allEventsIncludingDeleted = allEvents;

        // Filter out deleted events
        final activeEvents = allEvents
            .where((event) => !event.isDeleted)
            .toList();

        // Rebuild the events map for all dates
        final Map<DateTime, List<ScheduleEvent>> eventsMap = {};

        for (final event in activeEvents) {
          final eventDate = DateTime(
            event.startTime.year,
            event.startTime.month,
            event.startTime.day,
          );
          if (!eventsMap.containsKey(eventDate)) {
            eventsMap[eventDate] = [];
          }
          eventsMap[eventDate]!.add(event);
        }

        setState(() {
          _allEvents = activeEvents;
          _events = eventsMap;

          // Ensure current selected day has an entry
          if (!_events.containsKey(_selectedDay)) {
            _events[_selectedDay] = [];
          }
        });
      } else {
        // If no events found, initialize with empty data
        setState(() {
          _events = {};
          _allEvents = [];
          _allEventsIncludingDeleted = [];

          // Ensure current selected day has an entry
          if (!_events.containsKey(_selectedDay)) {
            _events[_selectedDay] = [];
          }
        });
      }
    } catch (e) {
      // If error occurs, initialize with empty data
      setState(() {
        _events = {};
        _allEvents = [];
        _allEventsIncludingDeleted = [];

        // Ensure current selected day has an entry
        if (!_events.containsKey(_selectedDay)) {
          _events[_selectedDay] = [];
        }
      });
    }
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedEventIds.clear();
      }
    });
  }

  void _toggleEventSelection(String eventId) {
    setState(() {
      if (_selectedEventIds.contains(eventId)) {
        _selectedEventIds.remove(eventId);
      } else {
        _selectedEventIds.add(eventId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      // Create a new list instance to ensure setState detects the change
      _selectedEventIds = [];
      // Exit multi-select mode when clearing selection
      _isMultiSelectMode = false;
    });
  }

  void _toggleEventStarred(ScheduleEvent event) {
    setState(() {
      // 创建一个新的事件对象，切换星标状态
      final updatedEvent = ScheduleEvent(
        id: event.id,
        title: event.title,
        description: event.description,
        startTime: event.startTime,
        endTime: event.endTime,
        type: event.type,
        color: event.color,
        isCompleted: event.isCompleted,
        priority: event.priority,
        location: event.location,
        recurrence: event.recurrence,
        recurrenceEnd: event.recurrenceEnd,
        isDeleted: event.isDeleted,
        deletedAt: event.deletedAt,
        isStarred: !event.isStarred,
      );

      // 更新_events和_allEvents列表
      // 更新_allEvents
      final eventIndex = _allEvents.indexWhere((e) => e.id == event.id);
      if (eventIndex != -1) {
        _allEvents[eventIndex] = updatedEvent;
      }

      // 更新_events
      final normalizedDay = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );

      if (_events.containsKey(normalizedDay)) {
        final dayEventIndex = _events[normalizedDay]!.indexWhere(
          (e) => e.id == event.id,
        );
        if (dayEventIndex != -1) {
          _events[normalizedDay]![dayEventIndex] = updatedEvent;
        }
      }
    });

    // 保存到存储服务
    _saveEvents();
  }

  // 保存事件到存储服务
  Future<void> _saveEvents() async {
    try {
      final storageService = StorageService();

      // 更新_allEventsIncludingDeleted中的事件
      final updatedEvents = _events.values.expand((list) => list).toList();

      // 创建一个包含所有已删除事件和更新后的未删除事件的列表
      final allEvents = <ScheduleEvent>[];

      // 添加所有已删除事件
      allEvents.addAll(
        _allEventsIncludingDeleted.where((event) => event.isDeleted),
      );

      // 添加所有更新后的未删除事件
      allEvents.addAll(updatedEvents);

      await storageService.saveScheduleEvents(allEvents);

      // 更新_allEventsIncludingDeleted
      _allEventsIncludingDeleted = allEvents;

      // 发送日程更新事件
      EventBusService().fireEvent(EventBusService.eventScheduleUpdated);
    } catch (e) {
      // 处理错误
      print('保存事件失败: $e');
    }
  }

  void _showDeleteConfirmationDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get selected events
    final selectedEvents = _allEvents
        .where((event) => _selectedEventIds.contains(event.id))
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        title: Text(
          selectedEvents.length == 1 ? '删除日程' : '批量删除日程',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedEvents.length == 1)
                // Single event details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      selectedEvents[0].title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '确定要删除此日程吗？',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                )
              else
                // Batch delete details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '您正在删除 ${selectedEvents.length} 个日程',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '确定要删除这些日程吗？此操作无法撤销。',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Show a summary of the first 3 events
                    for (
                      int i = 0;
                      i <
                          (selectedEvents.length > 3
                              ? 3
                              : selectedEvents.length);
                      i++
                    )
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: selectedEvents[i].color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedEvents[i].title,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (selectedEvents.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '... 还有 ${selectedEvents.length - 3} 个日程',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              '取消',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog
              Navigator.of(context).pop();

              // Perform delete operation
              final success = await _performDelete(selectedEvents);

              // Show result feedback
              if (success) {
                _showCustomSnackBar(
                  '已成功删除 ${selectedEvents.length} 个日程',
                  isSuccess: true,
                );
                // Exit multi-select mode and clear selection
                setState(() {
                  _isMultiSelectMode = false;
                  _selectedEventIds.clear();
                });
              } else {
                _showCustomSnackBar('删除失败，请稍后重试', isSuccess: false);
              }
            },
            child: Text(
              '确认删除',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _performDelete(List<ScheduleEvent> selectedEvents) async {
    try {
      final storageService = StorageService();
      final eventIds = selectedEvents.map((event) => event.id).toList();

      // Use batch delete
      final success = await storageService.batchDeleteEvents(eventIds);

      if (success) {
        // Reload events to update UI
        await _loadEvents();

        // Send schedule update event to notify other pages
        EventBusService().fireEvent(EventBusService.eventScheduleUpdated);

        // Log the operation (will be implemented later)
        _logDeleteOperation(eventIds, selectedEvents.length);
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  void _showCustomSnackBar(String message, {required bool isSuccess}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      duration: const Duration(seconds: 2), // Auto-dismiss after 2 seconds
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _logDeleteOperation(List<String> eventIds, int count) {
    // In a real app, get user info from authentication system
    // For demo purposes, use default values
    final userId = 'current_user';
    final username = '当前用户';

    final logService = OperationLogService();
    logService.logOperation(
      userId: userId,
      username: username,
      operationType: 'delete_schedule',
      affectedIds: eventIds,
      operationMode: eventIds.length == 1 ? 'single' : 'batch',
      success: true,
    );
  }

  List<ScheduleEvent> _getEventsForDay(DateTime day) {
    // Normalize date to ignore time part
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: _isMultiSelectMode
            ? Text('已选择 ${_selectedEventIds.length} 项')
            : const Text('日程'),
        centerTitle: true,
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
        ),
        actions: [
          if (_isMultiSelectMode)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSelection,
                  tooltip: '清除选择',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _showDeleteConfirmationDialog,
                  tooltip: '删除所选日程',
                ),
              ],
            )
          else
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _currentView == ViewType.calendar
                        ? Icons.list
                        : Icons.calendar_month,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentView = _currentView == ViewType.calendar
                          ? ViewType.list
                          : ViewType.calendar;
                    });
                  },
                  tooltip: '切换视图',
                ),
                IconButton(
                  icon: const Icon(Icons.today),
                  onPressed: () {
                    setState(() {
                      final now = DateTime.now();
                      _focusedDay = now;
                      _selectedDay = now;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: _toggleMultiSelectMode,
                  tooltip: '多选模式',
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, outerConstraints) {
            // 获取实际可用宽度（被 main.dart 中的 ConstrainedBox 约束为 430px）
            final availableWidth = outerConstraints.maxWidth;
            
            return GestureDetector(
              // 添加左右滑动切换日期功能
              onHorizontalDragStart: (details) {
                _dragStartX = details.localPosition.dx;
              },
              onHorizontalDragUpdate: (details) {
                _dragEndX = details.localPosition.dx;
              },
              onHorizontalDragEnd: (details) {
                final dragDistance = _dragEndX - _dragStartX;

                // 设置一个最小滑动距离阈值，确保是有意的滑动操作
                const minDragDistance = 50.0;

                if (dragDistance.abs() > minDragDistance) {
                  setState(() {
                    if (dragDistance > 0) {
                      // 向右滑动 - 切换到前一天
                      _selectedDay = _selectedDay.subtract(
                        const Duration(days: 1),
                      );
                      _focusedDay = _selectedDay;
                    } else {
                      // 向左滑动 - 切换到后一天
                      _selectedDay = _selectedDay.add(const Duration(days: 1));
                      _focusedDay = _selectedDay;
                    }
                  });
                }
              },
              behavior: HitTestBehavior.translucent, // 使用translucent允许子组件接收点击事件
              child: SizedBox(
                width: availableWidth,
                height: outerConstraints.maxHeight,
                child: Column(
                  children: [
                    if (_currentView == ViewType.calendar)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CalendarStrip(
                            focusedDay: _focusedDay,
                            selectedDay: _selectedDay,
                            onDaySelected: (selected, focused) {
                              setState(() {
                                _selectedDay = selected;
                                _focusedDay = focused;
                              });
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _currentView == ViewType.calendar
                          ? TimelineView(
                          events: _getEventsForDay(_selectedDay),
                          onEventTap: (event) {
                            if (_isMultiSelectMode) {
                              _toggleEventSelection(event.id);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${l10n.eventClicked}${event.title}',
                                  ),
                                ),
                              );
                            }
                          },
                          onEventLongPress: (event) {
                            if (!_isMultiSelectMode) {
                              _toggleMultiSelectMode();
                              _toggleEventSelection(event.id);
                            }
                          },
                          onStarTap: (event) {
                            _toggleEventStarred(event);
                          },
                          isMultiSelectMode: _isMultiSelectMode,
                          selectedEventIds: _selectedEventIds,
                        )
                      : _buildListView(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _isMultiSelectMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => VoiceScheduleScreen()),
                );
              },
              backgroundColor: AppColors.modernBlue.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildListView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search and filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索日程...',
              prefixIcon: Icon(
                Icons.search,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                ),
                onPressed: () {
                  // Implement filter functionality later
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
            ),
          ),
        ),
        // List of events
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: _allEvents.length,
            itemBuilder: (context, index) {
              final event = _allEvents[index];
              final isSelected = _selectedEventIds.contains(event.id);

              return EventCard(
                event: event,
                onTap: () {
                  if (_isMultiSelectMode) {
                    _toggleEventSelection(event.id);
                  } else {
                    // Single tap action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('点击了: ${event.title}')),
                    );
                  }
                },
                onLongPress: () {
                  if (!_isMultiSelectMode) {
                    _toggleMultiSelectMode();
                    _toggleEventSelection(event.id);
                  }
                },
                onStarTap: () {
                  _toggleEventStarred(event);
                },
                isSelected: isSelected,
              );
            },
          ),
        ),
      ],
    );
  }
}
