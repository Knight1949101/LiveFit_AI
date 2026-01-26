import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_fit/src/core/theme/app_colors.dart';

class CalendarStrip extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  
  // 手机屏幕宽度约束（430px - 32px padding = 398px）
  static const double mobileWidth = 398.0;

  const CalendarStrip({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  // 获取一周的日期列表
  List<DateTime> _getWeekDays(DateTime day) {
    final weekDays = <DateTime>[];
    final firstDayOfWeek = day.subtract(Duration(days: day.weekday - 1)); // 周一
    
    for (int i = 0; i < 7; i++) {
      weekDays.add(firstDayOfWeek.add(Duration(days: i)));
    }
    
    return weekDays;
  }

  // 格式化日期显示
  String _formatDay(DateTime day) {
    return DateFormat('d').format(day);
  }

  // 格式化月份显示
  String _formatMonth(BuildContext context, DateTime day) {
    final locale = Localizations.localeOf(context).languageCode;
    
    if (locale == 'zh') {
      // 中文使用 yyyy年MM月 格式
      return DateFormat('yyyy年MM月').format(day);
    } else {
      // 英文使用 MMM yyyy 格式（例如：Jan 2024）
      return DateFormat('MMM yyyy', locale).format(day);
    }
  }

  // 格式化星期显示
  String _formatWeekday(BuildContext context, DateTime day) {
    final locale = Localizations.localeOf(context).languageCode;
    
    if (locale == 'zh') {
      // 中文使用窄格式（一、二、三...）
      final localizations = MaterialLocalizations.of(context);
      return localizations.narrowWeekdays[day.weekday - 1];
    } else {
      // 英文使用缩写格式（Mon, Tue, Wed...）
      return DateFormat('E').format(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final weekDays = _getWeekDays(focusedDay);
    
    // 固定使用手机屏幕宽度，确保7天正确显示
    const cellWidth = mobileWidth / 7;

    return SizedBox(
      width: mobileWidth,
      child: Column(
            children: [
              // 月份标题和导航按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: () {
                      // 切换到上一周
                      final prevWeek = focusedDay.subtract(const Duration(days: 7));
                      onDaySelected(prevWeek, prevWeek);
                    },
                    color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                  ),
                  Text(
                    _formatMonth(context, focusedDay),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: () {
                      // 切换到下一周
                      final nextWeek = focusedDay.add(const Duration(days: 7));
                      onDaySelected(nextWeek, nextWeek);
                    },
                    color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 星期标题行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekDays.map((day) {
                  return SizedBox(
                    width: cellWidth,
                    child: Text(
                      _formatWeekday(context, day),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              
              // 日期行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekDays.map((day) {
                  final isSelected = selectedDay != null && 
                      day.year == selectedDay!.year && 
                      day.month == selectedDay!.month && 
                      day.day == selectedDay!.day;
                  final isToday = DateTime.now().year == day.year && 
                      DateTime.now().month == day.month && 
                      DateTime.now().day == day.day;
                  
                  BoxDecoration decoration;
                  TextStyle textStyle;
                  
                  if (isSelected) {
                    decoration = BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    );
                    textStyle = const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    );
                  } else if (isToday) {
                    decoration = BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondary),
                    );
                    textStyle = TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    );
                  } else {
                    decoration = BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    );
                    textStyle = TextStyle(
                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    );
                  }
                  
                  return SizedBox(
                    width: cellWidth,
                    height: 36,
                    child: GestureDetector(
                      onTap: () {
                        onDaySelected(day, day);
                      },
                      child: Container(
                        decoration: decoration,
                        alignment: Alignment.center,
                        child: Text(
                          _formatDay(day),
                          style: textStyle,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
  }
}
