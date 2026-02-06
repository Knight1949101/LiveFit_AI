import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_profile_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../domain/user_profile.dart';
import '../../onboarding/domain/onboarding_state.dart';
import '../../../core/theme/app_colors.dart';

class ProfileEditScreen extends StatefulWidget {
  static const routeName = '/profile/edit';

  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> with SingleTickerProviderStateMixin {
  late UserProfile _profile;
  late AnimationController _staggeredController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Initialize profile data
    try {
      final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      _profile = userProfileProvider.userProfile;
    } catch (_) {
      _profile = UserProfile(
        nickname: 'LifeFit User',
        birthday: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175,
        weight: 70,
        mainGoal: FitnessGoal.muscleBuild,
        experienceLevel: ExperienceLevel.intermediate,
      );
    }

    // Calculate initial calorie data
    _updateCalorieData();

    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _staggeredController.forward();
  }

  // Calculate and update calorie-related data
  void _updateCalorieData() {
    // Calculate age
    final now = DateTime.now();
    int age = now.year - _profile.birthday.year;
    if (now.month < _profile.birthday.month || 
        (now.month == _profile.birthday.month && now.day < _profile.birthday.day)) {
      age--;
    }

    // Mifflin-St Jeor formula for BMR
    double s = _profile.gender == Gender.male ? 5 : -161;
    double bmr = (10 * _profile.weight) + (6.25 * _profile.height) - (5 * age) + s;
    
    // Calculate TDEE using activity multiplier instead of fixed division
    // This provides more realistic values for large body sizes
    double activityMultiplier = 1.2; // Sedentary by default
    double noExerciseTotalConsumption = bmr * activityMultiplier;
    
    // Strength training consumption based on experience level and gender
    double strengthTrainingConsumption;
    switch (_profile.experienceLevel) {
      case ExperienceLevel.beginner:
        strengthTrainingConsumption = _profile.gender == Gender.male ? 150 : 100;
        break;
      case ExperienceLevel.intermediate:
        strengthTrainingConsumption = _profile.gender == Gender.male ? 200 : 150;
        break;
      case ExperienceLevel.advanced:
        strengthTrainingConsumption = _profile.gender == Gender.male ? 250 : 200;
        break;
    }
    
    // Aerobic consumption (simplified, using default weekly 30min running for calculation)
    // Calories burned formula: weight (kg) * MET * time (minutes) * 3.5 / 200
    // Running MET = 9.8, 30 minutes per week → divided by 7 days
    double weeklyAerobicCalories = (_profile.weight * 9.8 * 30 * 3.5) / 200;
    double aerobicConsumption = weeklyAerobicCalories / 7;
    
    // Calculate balance calories
    double strengthTrainingDayBalance = noExerciseTotalConsumption + strengthTrainingConsumption + aerobicConsumption;
    double restDayBalance = noExerciseTotalConsumption + aerobicConsumption;
    
    // Calculate recommended calories
    double strengthTrainingDayShouldEat = strengthTrainingDayBalance * 0.64;
    double restDayShouldEat = restDayBalance * 0.64;
    
    // Calculate daily calorie goal based on workout frequency (assuming 4 strength days per week)
    double dailyCalorieGoal = (strengthTrainingDayShouldEat * 4 + restDayShouldEat * 3) / 7;
    
    // Update profile with new calorie data
    setState(() {
      _profile = _profile.copyWith(
        basalMetabolism: bmr,
        noExerciseTotalConsumption: noExerciseTotalConsumption,
        strengthTrainingConsumption: strengthTrainingConsumption,
        aerobicConsumption: aerobicConsumption,
        strengthTrainingDayBalance: strengthTrainingDayBalance,
        restDayBalance: restDayBalance,
        strengthTrainingDayShouldEat: strengthTrainingDayShouldEat,
        restDayShouldEat: restDayShouldEat,
        dailyCalorieGoal: dailyCalorieGoal.toInt(),
      );
    });
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _getPreferredWorkoutTimeName(PreferredWorkoutTime time) {
    final l10nNullable = AppLocalizations.of(context);
    if (l10nNullable == null) {
      return time.name;
    }
    final l10n = l10nNullable;
    return l10n.getPreferredWorkoutTimeName(_capitalize(time.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10nNullable = AppLocalizations.of(context);
    if (l10nNullable == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final l10n = l10nNullable;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context, isDark),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildAnimatedSection(
                  index: 0,
                  child: _buildBasicInfoSection(l10n),
                ),
                const SizedBox(height: 20),
                _buildAnimatedSection(
                  index: 1,
                  child: _buildPhysiqueSection(l10n),
                ),
                const SizedBox(height: 20),
                _buildAnimatedSection(
                  index: 2,
                  child: _buildGoalsSection(l10n),
                ),
                const SizedBox(height: 20),
                _buildAnimatedSection(
                  index: 3,
                  child: _buildCalorieSummarySection(l10n),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 240.0,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.check, color: isDark ? AppColors.primary : AppColors.primary),
          onPressed: () async {
            final provider = Provider.of<UserProfileProvider>(context, listen: false);
            await provider.updateUserProfile(_profile);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('个人信息已保存')),
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _profile.nickname,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Mesh Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.1),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress Ring
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CircularProgressIndicator(
                      value: 0.85, // Mock completeness
                      strokeWidth: 4,
                      color: AppColors.primary,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Avatar
                  Hero(
                    tag: 'user_avatar',
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFFF5F5F5),
                        child: Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Edit Badge
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return AnimatedBuilder(
      animation: _staggeredController,
      builder: (context, child) {
        final double start = index * 0.1;
        final double end = start + 0.4;
        
        final fade = CurvedAnimation(
          parent: _staggeredController,
          curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.easeOut),
        );
        
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _staggeredController,
          curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.easeOutCubic),
        ));

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: child!,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildBasicInfoSection(AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.basicInfo,
      icon: Icons.person_outline,
      children: [
        _buildInputRow(
          label: l10n.nickname,
          child: TextFormField(
            initialValue: _profile.nickname,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const Divider(),
        _buildInputRow(
          label: l10n.gender,
          child: DropdownButtonFormField<Gender>(
            key: ValueKey('gender_${_profile.gender}'),
            initialValue: _profile.gender,
            isExpanded: true,
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
            items: Gender.values.map((g) => DropdownMenuItem(
              value: g,
              child: Text(l10n.getGenderName(_capitalize(g.name))),
            )).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _profile = _profile.copyWith(gender: val));
            },
          ),
        ),
        const Divider(),
        _buildInputRow(
          label: l10n.birthday,
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _profile.birthday,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _profile = _profile.copyWith(birthday: date));
            },
            child: Row(
              children: [
                Text(
                  '${_profile.birthday.year}-${_profile.birthday.month.toString().padLeft(2, '0')}-${_profile.birthday.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        const Divider(),
        _buildInputRow(
          label: l10n.preferredWorkoutTime,
          child: DropdownButtonFormField<PreferredWorkoutTime>(
            key: ValueKey('preferredWorkoutTime_${_profile.preferredWorkoutTime}'),
            initialValue: _profile.preferredWorkoutTime,
            isExpanded: true,
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
            items: PreferredWorkoutTime.values.map((t) => DropdownMenuItem(
              value: t,
              child: Text(_getPreferredWorkoutTimeName(t)),
            )).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _profile = _profile.copyWith(preferredWorkoutTime: val));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhysiqueSection(AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.physique,
      icon: Icons.accessibility_new,
      children: [
        _buildSliderRow(
          label: l10n.height,
          value: _profile.height,
          unit: 'cm',
          min: 140,
          max: 220,
          onChanged: (val) {
            setState(() => _profile = _profile.copyWith(height: val));
            _updateCalorieData();
          },
        ),
        const Divider(),
        _buildSliderRow(
          label: l10n.weight,
          value: _profile.weight,
          unit: 'kg',
          min: 40,
          max: 150,
          onChanged: (val) {
            setState(() => _profile = _profile.copyWith(weight: val));
            _updateCalorieData();
          },
        ),
        const Divider(),
        _buildInputRow(
          label: l10n.bodyType,
          child: DropdownButtonFormField<Somatotype>(
            key: ValueKey('somatotype_${_profile.somatotype}'),
            initialValue: _profile.somatotype,
            isExpanded: true,
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
            items: Somatotype.values.map((s) => DropdownMenuItem(
              value: s,
              child: Text(l10n.getSomatotypeName(_capitalize(s.name))),
            )).toList(),
            onChanged: (val) { if (val != null) setState(() => _profile = _profile.copyWith(somatotype: val)); },
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSection(AppLocalizations l10n) {
    // Calculate BMI and recommended weight range
    double bmi = _profile.weight / ((_profile.height / 100) * (_profile.height / 100));
    Map<String, double> recommendedRange = _calculateRecommendedWeightRange(_profile.height);
    
    // Calculate target weight relative to recommended range
    double targetWeight = _profile.targetWeight ?? _profile.weight;
    double recommendedMin = recommendedRange['min'] ?? 40;
    double recommendedMax = recommendedRange['max'] ?? 150;
    
    // Ensure target weight stays relative to recommended range when range changes
    // Only adjust if user hasn't manually set a target weight
    if (_profile.targetWeight == null) {
      // If no manual target weight, use current weight as reference
      targetWeight = _profile.weight;
    }
    
    return _SectionCard(
      title: l10n.goals,
      icon: Icons.flag_outlined,
      children: [
        _buildInputRow(
          label: l10n.mainGoal,
          child: DropdownButtonFormField<FitnessGoal>(
            key: ValueKey('goal_${_profile.mainGoal}'),
            initialValue: _profile.mainGoal,
            isExpanded: true,
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
            items: FitnessGoal.values.map((g) => DropdownMenuItem(
              value: g,
              child: Text(l10n.getGoalName(_capitalize(g.name))),
            )).toList(),
            onChanged: (val) { if (val != null) setState(() => _profile = _profile.copyWith(mainGoal: val)); },
          ),
        ),
        const Divider(),
        _buildInputRow(
          label: l10n.experienceLevel,
          child: DropdownButtonFormField<ExperienceLevel>(
            key: ValueKey('exp_${_profile.experienceLevel}'),
            initialValue: _profile.experienceLevel,
            isExpanded: true,
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
            items: ExperienceLevel.values.map((e) => DropdownMenuItem(
              value: e,
              child: Text(l10n.getExperienceLevelName(_capitalize(e.name))),
            )).toList(),
            onChanged: (val) { if (val != null) setState(() => _profile = _profile.copyWith(experienceLevel: val)); },
          ),
        ),
        const Divider(),
        // BMI display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('当前BMI', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            Text(
              bmi.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              _getBMICategory(bmi),
              style: TextStyle(
                color: _getBMIColor(bmi),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Divider(),
        // Recommended weight range with visual indicator
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '健康体重范围',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '基于BMI (18.5-24.0)',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Visual weight range indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.textDisabled.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Recommended range indicator
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        flex: ((recommendedMin - (recommendedMin - 5)) / ((recommendedMax + 5) - (recommendedMin - 5)) * 100).toInt(),
                        child: Container(),
                      ),
                      Expanded(
                        flex: ((recommendedMax - recommendedMin) / ((recommendedMax + 5) - (recommendedMin - 5)) * 100).toInt(),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: (((recommendedMax + 5) - recommendedMax) / ((recommendedMax + 5) - (recommendedMin - 5)) * 100).toInt(),
                        child: Container(),
                      ),
                    ],
                  ),
                ),
                ],
              ),
              const SizedBox(height: 8),
              // Weight range labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${recommendedMin.toStringAsFixed(0)} kg',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${recommendedMax.toStringAsFixed(0)} kg',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildSliderRow(
          label: l10n.targetWeight,
          value: targetWeight,
          unit: 'kg',
          min: recommendedMin - 5,
          max: recommendedMax + 5,
          recommendedMin: recommendedMin,
          recommendedMax: recommendedMax,
          onChanged: (val) {
            setState(() => _profile = _profile.copyWith(targetWeight: val));
          },
        ),
        // Target weight status indicator
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '目标体重状态',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTargetWeightStatusColor(targetWeight, recommendedMin, recommendedMax),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getTargetWeightStatusText(targetWeight, recommendedMin, recommendedMax),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '推荐体重范围: ${recommendedMin.round()} - ${recommendedMax.round()} kg',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getTargetWeightStatusDescription(targetWeight, recommendedMin, recommendedMax),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieSummarySection(AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.calorieSummary,
      icon: Icons.local_fire_department,
      children: [
        // Main Stats Card
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4A6FFF).withValues(alpha: 0.15),
                const Color(0xFF00E676).withValues(alpha: 0.1),
                AppColors.surfaceLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A6FFF).withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                l10n.dailyRecommendedCalories,
                style: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: const [Color(0xFF4A6FFF), Color(0xFF00E676)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      '${(_profile.dailyCalorieGoal ?? 2000).toInt()}',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                l10n.unitKcal,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(l10n.basalMetabolism, '${(_profile.basalMetabolism ?? 1500).toInt()}'),
                  Container(
                    width: 1,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, AppColors.textSecondaryLight.withValues(alpha: 0.3), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  _buildStatItem(l10n.totalConsumption, '${(_profile.noExerciseTotalConsumption ?? 2000).toInt()}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Calorie details
        Text(
          l10n.calorieRequirements,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalorieRow(l10n.basalMetabolicRate, '${(_profile.basalMetabolism ?? 1500).toInt()} ${l10n.caloriesPerDay}'),
              const SizedBox(height: 16),
              _buildCalorieRow(l10n.totalDailyEnergyExpenditure, '${(_profile.noExerciseTotalConsumption ?? 2000).toInt()} ${l10n.caloriesPerDay}'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primaryEnd.withValues(alpha: 0.1),
                      ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.recommendedCalorieIntake,
                        style: TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(_profile.dailyCalorieGoal ?? 2000).toInt()} ${l10n.caloriesPerDay}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Aerobic Exercise Calories
        Text(
          l10n.dailyActivityConsumption,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 16),

        // Total aerobic exercise calories
        _buildInfoCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.weeklyTotalConsumption,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: const [Color(0xFF4A6FFF), Color(0xFF00E676)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(_profile.aerobicConsumption ?? 0).toInt()} ${l10n.unitKcal}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Custom Calorie Data
        Text(
          l10n.calorieDataDetails,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          child: Column(
            children: [
              // Basal Metabolism
              _buildCustomStatItem(l10n.basalMetabolism, '${_profile.basalMetabolism?.toInt() ?? 1500}'),
              const SizedBox(height: 16),
              
              // No Exercise Total Consumption
              _buildCustomStatItem(l10n.totalConsumption, '${(_profile.noExerciseTotalConsumption ?? 2000).toInt()}'),
              const SizedBox(height: 16),
              
              // Strength Training Consumption
              _buildCustomStatItem(l10n.strengthTrainingConsumption, '${(_profile.strengthTrainingConsumption ?? 300).toInt()}'),
              const SizedBox(height: 16),
              
              // Aerobic Consumption
              _buildCustomStatItem(l10n.aerobicConsumption, '${(_profile.aerobicConsumption ?? 200).toInt()}'),
              const SizedBox(height: 24),
              
              // Divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, AppColors.textSecondaryLight.withValues(alpha: 0.3), Colors.transparent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Strength Training Day Balance
              _buildCustomStatItem(l10n.strengthTrainingDayBalance, '${(_profile.strengthTrainingDayBalance ?? 2800).toInt()}'),
              const SizedBox(height: 16),
              
              // Rest Day Balance
              _buildCustomStatItem(l10n.restDayBalance, '${(_profile.restDayBalance ?? 2500).toInt()}'),
              const SizedBox(height: 24),
              
              // Divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, AppColors.textSecondaryLight.withValues(alpha: 0.3), Colors.transparent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Strength Training Day Should Eat
              _buildCustomStatItem(l10n.strengthTrainingDayShouldEat, '${(_profile.strengthTrainingDayShouldEat ?? 1800).toInt()}'),
              const SizedBox(height: 16),
              
              // Rest Day Should Eat
              _buildCustomStatItem(l10n.restDayShouldEat, '${(_profile.restDayShouldEat ?? 1600).toInt()}'),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods for calorie summary
  Widget _buildInfoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCalorieRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label, 
            style: TextStyle(color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            value, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomStatItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: const [Color(0xFF4A6FFF), Color(0xFF00E676)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: const [Color(0xFF4A6FFF), Color(0xFF00E676)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  // Helper methods
  Map<String, double> _calculateRecommendedWeightRange(double height) {
    double heightInMeters = height / 100;
    double minWeight = 18.5 * heightInMeters * heightInMeters;
    double maxWeight = 24.0 * heightInMeters * heightInMeters;
    return <String, double>{'min': minWeight, 'max': maxWeight};
  }
  
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '正常';
    if (bmi < 28) return '超重';
    return '肥胖';
  }
  
  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.yellow;
    if (bmi < 24) return Colors.green;
    if (bmi < 28) return Colors.red;
    return Colors.red;
  }
  
  Color _getTargetWeightStatusColor(double targetWeight, double min, double max) {
    if (targetWeight < min) {
      return Colors.orange.withValues(alpha: 0.8);
    } else if (targetWeight > max) {
      return Colors.red.withValues(alpha: 0.8);
    } else {
      return Colors.green.withValues(alpha: 0.8);
    }
  }
  
  String _getTargetWeightStatusText(double targetWeight, double min, double max) {
    if (targetWeight < min) {
      return '偏轻';
    } else if (targetWeight > max) {
      return '偏重';
    } else {
      return '健康范围';
    }
  }

  String _getTargetWeightStatusDescription(double targetWeight, double min, double max) {
    if (targetWeight < min) {
      return '您的目标体重低于推荐范围，建议适当增加目标体重以保持健康。';
    } else if (targetWeight > max) {
      return '您的目标体重高于推荐范围，建议适当减少目标体重以保持健康。';
    } else {
      return '您的目标体重处于健康范围内，继续保持！';
    }
  }

  Widget _buildInputRow({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required String unit,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    void Function()? onChangeStart,
    void Function(double)? onChangeEnd,
    double? recommendedMin,
    double? recommendedMax,
  }) {
    final TextEditingController controller = TextEditingController(text: value.toStringAsFixed(1));
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        suffixText: unit,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        isDense: true,
                        hintText: '$min-$max',
                        hintStyle: TextStyle(color: AppColors.textDisabled),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      onChanged: (val) {
                        // Do not clamp while user is typing
                      },
                      onEditingComplete: () {
                        final double? numValue = double.tryParse(controller.text);
                        if (numValue != null) {
                          final clampedValue = numValue.clamp(min, max);
                          controller.text = clampedValue.toStringAsFixed(1);
                          controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                          onChanged(clampedValue);
                          onChangeEnd?.call(clampedValue);
                        }
                      },
                      onFieldSubmitted: (val) {
                        final double? numValue = double.tryParse(val);
                        if (numValue != null) {
                          final clampedValue = numValue.clamp(min, max);
                          controller.text = clampedValue.toStringAsFixed(1);
                          controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                          onChanged(clampedValue);
                          onChangeEnd?.call(clampedValue);
                        }
                      },
                    ),
                  ),
            ],
          ),
          // Recommended range indicator
          if (recommendedMin != null && recommendedMax != null) ...[
            const SizedBox(height: 4),
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.textDisabled.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                children: [
                  // Recommended range bar
                  Positioned(
                    left: ((recommendedMin - min) / (max - min)) * 100,
                    right: ((max - recommendedMax) / (max - min)) * 100,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.textDisabled.withValues(alpha: 0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: (newValue) {
                onChanged(newValue);
                controller.text = newValue.toStringAsFixed(1);
              },
              onChangeStart: (val) => onChangeStart?.call(),
              onChangeEnd: onChangeEnd,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
