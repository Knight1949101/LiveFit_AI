import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class IFlytekVoiceAnimation extends StatefulWidget {
  final bool isListening;
  final double? soundLevel;

  const IFlytekVoiceAnimation({
    super.key,
    required this.isListening,
    this.soundLevel,
  });

  @override
  State<IFlytekVoiceAnimation> createState() => _IFlytekVoiceAnimationState();
}

class _IFlytekVoiceAnimationState extends State<IFlytekVoiceAnimation> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final int _barCount = 7;
  final double _maxBarHeight = 60;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _barCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200 + (index * 150)),
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isListening) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: _maxBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_barCount, (index) {
              final baseHeight = 10.0;
              final soundLevelFactor = widget.soundLevel ?? 0.5;
              final animationValue = _controllers[index].value;
              
              // 根据声音强度和动画值计算柱子高度
              final height = baseHeight + 
                (_maxBarHeight - baseHeight) * 
                animationValue * 
                soundLevelFactor;

              return AnimatedBuilder(
                animation: _controllers[index],
                builder: (context, child) {
                  return Container(
                    width: 6,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '正在识别...',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
