import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class VoiceRecognitionResult extends StatelessWidget {
  final String result;
  final String? partialResult;
  final bool isListening;
  final bool isCompleted;
  final Function(String) onResultChanged;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  const VoiceRecognitionResult({
    super.key,
    required this.result,
    this.partialResult,
    required this.isListening,
    required this.isCompleted,
    required this.onResultChanged,
    required this.onConfirm,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCompleted ? '识别结果' : '实时识别',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          // 识别结果显示
          TextField(
            controller: TextEditingController(
              text: result.isNotEmpty ? result : partialResult ?? '',
            ),
            onChanged: onResultChanged,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              hintText: '识别结果将显示在这里',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[400],
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // 操作按钮
          if (isCompleted)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('重新识别'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1),
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
                  onPressed: onConfirm,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('确认结果'),
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
              ],
            ),
        ],
      ),
    );
  }
}
