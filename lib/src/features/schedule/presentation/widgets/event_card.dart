import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_fit/src/features/schedule/domain/models/schedule_event.dart';
import 'package:life_fit/src/core/theme/app_colors.dart';

class EventCard extends StatelessWidget {
  final ScheduleEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onStarTap;
  final bool isSelected;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onLongPress,
    this.onStarTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Check if the event has passed
    final isPastEvent = DateTime.now().isAfter(event.endTime);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? event.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              if (isSelected)
                BoxShadow(
                  color: event.color.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
          ],
        ),
        child: Row(
          children: [
            // Color Bar - 使用星标颜色
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: isPastEvent ? event.starredColor.withValues(alpha: 0.5) : event.starredColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Star Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isPastEvent
                                ? (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight).withValues(alpha: 0.6)
                                : (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
                            decoration: isPastEvent ? TextDecoration.lineThrough : TextDecoration.none,
                            decorationColor: isPastEvent
                                ? (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight).withValues(alpha: 0.8)
                                : Colors.transparent,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                      // Star Icon Button - 使用Material+InkWell提供点击反馈
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onStarTap,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              event.isStarred ? Icons.star : Icons.star_border,
                              color: event.isStarred ? Colors.amber : Colors.grey,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isPastEvent
                            ? (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight).withValues(alpha: 0.5)
                            : (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
                        decoration: isPastEvent ? TextDecoration.lineThrough : TextDecoration.none,
                        decorationColor: isPastEvent
                            ? (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight).withValues(alpha: 0.7)
                            : Colors.transparent,
                        decorationThickness: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Duration / End Time Hint
                  Row(
                    children: [
                      Icon(Icons.access_time, 
                        size: 12, 
                        color: isPastEvent ? AppColors.textDisabled.withValues(alpha: 0.5) : AppColors.textDisabled),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isPastEvent ? AppColors.textDisabled.withValues(alpha: 0.5) : AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // Type Icon - 使用星标颜色
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPastEvent 
                    ? event.starredColor.withValues(alpha: 0.05) 
                    : event.starredColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(event.type),
                color: isPastEvent ? event.starredColor.withValues(alpha: 0.5) : event.starredColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(EventType type) {
    switch (type) {
      case EventType.workout:
        return Icons.fitness_center;
      case EventType.work:
        return Icons.work_outline;
      case EventType.life:
        return Icons.coffee;
      case EventType.rest:
        return Icons.bed_outlined;
    }
  }
}
