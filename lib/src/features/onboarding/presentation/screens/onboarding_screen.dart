import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/onboarding_state.dart';
import '../widgets/onboarding_progress_bar.dart';
import 'steps/identity_step.dart';
import 'steps/basic_info_step.dart';
import 'steps/goal_step.dart';
import 'steps/diet_step.dart';
import 'steps/context_step.dart';
import 'steps/preference_step.dart';
import 'steps/summary_step.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import 'package:life_fit/src/features/profile/presentation/providers/user_profile_provider.dart';
import '../../../authentication/presentation/login_screen.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  OnboardingState _state = OnboardingState();
  int _currentPage = 0;
  final StorageService _storageService = StorageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    try {
      // 清除之前的存储数据，强制从第一个页面开始（仅用于开发调试）
      await _storageService.clearOnboardingData();
      
      final savedState = await _storageService.loadOnboardingState();
      if (savedState != null) {
        setState(() {
          _state = savedState;
          // Calculate current page based on completed steps
          _currentPage = _calculateCurrentPage(savedState);
          _pageController.jumpToPage(_currentPage);
          _isLoading = false;
        });
      } else {
        setState(() {
          _state = OnboardingState();
          _currentPage = 0; // 强制从第一个页面开始
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error loading saved state
      // Log error silently - production ready
      setState(() {
        _state = OnboardingState();
        _currentPage = 0;
        _isLoading = false;
      });
    }
  }

  int _calculateCurrentPage(OnboardingState state) {
    // Determine current page based on completed information
    if (state.gender != null && state.birthday != null) {
      return 1; // Basic info step (索引1)
    } else if (state.persona != null) {
      return 0; // Identity step (索引0)
    }
    return 0;
  }

  Future<void> _saveState() async {
    final success = await _storageService.saveOnboardingState(_state);
    if (!success) {
      // Optional: Show error message to user
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _state.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Skip validation for the last page (summary step)
    if (_currentPage < 1 && !_state.isValid(_currentPage)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请完成当前页面的所有问题'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Save state before moving to next page
    _saveState();

    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    // Onboarding completed (either fully or partially with basic info)
    _storageService.setOnboardingCompleted(true);
    context.read<UserProfileProvider>().updateFromOnboarding(_state);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _state,
          builder: (context, child) {
            return Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    children: [
                      _buildBackButton(isDark),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step ${_currentPage + 1} / 2',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OnboardingProgressBar(
                              currentStep: _currentPage,
                              totalSteps: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Enforce validation
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);

                    },
                    children: [
                      // 直接显示IdentityStep，不使用CustomScrollView嵌套
                      IdentityStep(state: _state),
                      BasicInfoStep(state: _state),
                    ],
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black, // High contrast text on Neon Green
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        _currentPage == 1 ? '开启 LifeFit 之旅' : '下一步',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackButton(bool isDark) {
    return InkWell(
      onTap: _prevPage,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
          size: 20,
        ),
      ),
    );
  }
}
