import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OfflineLanguagePackManager extends StatefulWidget {
  final List<LanguagePack> availablePacks;
  final List<LanguagePack> downloadedPacks;
  final Function(LanguagePack) onDownload;
  final Function(LanguagePack) onDelete;
  final Function(LanguagePack) onCheckStatus;
  final Map<String, double> downloadProgress;

  const OfflineLanguagePackManager({
    super.key,
    required this.availablePacks,
    required this.downloadedPacks,
    required this.onDownload,
    required this.onDelete,
    required this.onCheckStatus,
    required this.downloadProgress,
  });

  @override
  State<OfflineLanguagePackManager> createState() =>
      _OfflineLanguagePackManagerState();
}

class _OfflineLanguagePackManagerState
    extends State<OfflineLanguagePackManager> {
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
            '离线语言包管理',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '下载语言包后可在无网络环境下使用语音识别',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // 已下载的语言包
          if (widget.downloadedPacks.isNotEmpty) ...[
            Text(
              '已下载语言包',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.downloadedPacks.map((pack) {
              return _buildLanguagePackItem(
                context,
                pack,
                true,
                widget.onDelete,
                0.0,
              );
            }).toList(),
            const SizedBox(height: 20),
          ],

          // 可用语言包
          Text(
            '可用语言包',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.availablePacks
              .where(
                (pack) =>
                    !widget.downloadedPacks.any((p) => p.code == pack.code),
              )
              .map((pack) {
                final progress = widget.downloadProgress[pack.code] ?? 0.0;
                return _buildLanguagePackItem(
                  context,
                  pack,
                  false,
                  widget.onDownload,
                  progress,
                );
              })
              .toList(),
        ],
      ),
    );
  }

  Widget _buildLanguagePackItem(
    BuildContext context,
    LanguagePack pack,
    bool isDownloaded,
    Function(LanguagePack) onAction,
    double progress,
  ) {
    progress = progress ?? 0.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDownloading = progress > 0 && progress < 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '大小: ${pack.size}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isDownloading ? null : () => onAction(pack),
                child: isDownloaded
                    ? const Text('删除')
                    : isDownloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('下载'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDownloaded
                      ? Colors.red.withOpacity(0.8)
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: const Size(80, 32),
                ),
              ),
            ],
          ),
          if (isDownloading) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 11, color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LanguagePack {
  final String code;
  final String name;
  final String size;
  final String description;

  const LanguagePack({
    required this.code,
    required this.name,
    required this.size,
    required this.description,
  });
}

// 预定义的语言包列表
const List<LanguagePack> predefinedLanguagePacks = [
  LanguagePack(
    code: 'zh_cn',
    name: '中文(简体)',
    size: '45MB',
    description: '支持中文普通话识别',
  ),
  LanguagePack(
    code: 'zh_cn_cantonese',
    name: '中文(粤语)',
    size: '38MB',
    description: '支持粤语识别',
  ),
  LanguagePack(
    code: 'en_us',
    name: '英语(美国)',
    size: '32MB',
    description: '支持美式英语识别',
  ),
  LanguagePack(code: 'ja_jp', name: '日语', size: '28MB', description: '支持日语识别'),
  LanguagePack(code: 'ko_kr', name: '韩语', size: '25MB', description: '支持韩语识别'),
];
