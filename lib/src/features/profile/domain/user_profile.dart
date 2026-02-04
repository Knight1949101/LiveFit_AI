import '../../onboarding/domain/onboarding_state.dart';

class UserProfile {
  final String? avatarUrl;
  final String nickname;
  final String? bio;
  final Gender gender;
  final DateTime birthday;
  final double height; // cm
  final double weight; // kg
  final Somatotype somatotype;
  final FitnessGoal mainGoal;
  final double? targetWeight;
  final int? dailyCalorieGoal; // User defined or calculated
  final ExperienceLevel experienceLevel;
  final Set<AerobicExerciseType> aerobicExercises;
  final WeeklyExerciseTime weeklyExerciseTime;
  final PreferredWorkoutTime preferredWorkoutTime;
  
  // Calorie data from user input
  final double? basalMetabolism; // 基础代谢(a)
  final double? noExerciseTotalConsumption; // 无运动总消耗(b=a÷0.7)
  final double? strengthTrainingConsumption; // 力训消耗(c)
  final double? aerobicConsumption; // 有氧消耗(d)
  final double? strengthTrainingDayBalance; // 力训日(e1=b+c+d)
  final double? restDayBalance; // 休息日(e2=b+d)
  final double? strengthTrainingDayShouldEat; // 力训日应吃(f1=e1×0.64)
  final double? restDayShouldEat; // 休息日应吃(f2=e2×0.64)

  const UserProfile({
    this.avatarUrl,
    this.nickname = 'User',
    this.bio,
    this.gender = Gender.male,
    required this.birthday,
    this.height = 170.0,
    this.weight = 65.0,
    this.somatotype = Somatotype.mesomorph,
    this.mainGoal = FitnessGoal.keepFit,
    this.targetWeight,
    this.dailyCalorieGoal,
    this.experienceLevel = ExperienceLevel.beginner,
    this.aerobicExercises = const {},
    this.weeklyExerciseTime = WeeklyExerciseTime.thirtyMinutes,
    this.preferredWorkoutTime = PreferredWorkoutTime.morning,
    // Calorie data parameters
    this.basalMetabolism,
    this.noExerciseTotalConsumption,
    this.strengthTrainingConsumption,
    this.aerobicConsumption,
    this.strengthTrainingDayBalance,
    this.restDayBalance,
    this.strengthTrainingDayShouldEat,
    this.restDayShouldEat,
  });

  // Factory to create from OnboardingState (Migration helper)
  factory UserProfile.fromOnboardingState(OnboardingState state) {
    return UserProfile(
      gender: state.gender ?? Gender.male,
      birthday: state.birthday ?? DateTime(1995, 1, 1),
      height: state.height ?? 170.0,
      weight: state.weight ?? 65.0,
      somatotype: state.somatotype ?? Somatotype.mesomorph,
      mainGoal: state.mainGoal ?? FitnessGoal.keepFit,
      targetWeight: state.targetWeight,
      dailyCalorieGoal: state.recommendedCalories, // Initialize with recommended
      experienceLevel: state.experienceLevel ?? ExperienceLevel.beginner,
      aerobicExercises: state.aerobicExercises,
      weeklyExerciseTime: state.weeklyExerciseTime ?? WeeklyExerciseTime.thirtyMinutes,
      preferredWorkoutTime: state.preferredWorkoutTime ?? PreferredWorkoutTime.morning,
      // Calorie data from OnboardingState
      basalMetabolism: state.basalMetabolism,
      noExerciseTotalConsumption: state.noExerciseTotalConsumption,
      strengthTrainingConsumption: state.strengthTrainingConsumption,
      aerobicConsumption: state.aerobicConsumption,
      strengthTrainingDayBalance: state.strengthTrainingDayBalance,
      restDayBalance: state.restDayBalance,
      strengthTrainingDayShouldEat: state.strengthTrainingDayShouldEat,
      restDayShouldEat: state.restDayShouldEat,
    );
  }

  UserProfile copyWith({
    String? avatarUrl,
    String? nickname,
    String? bio,
    Gender? gender,
    DateTime? birthday,
    double? height,
    double? weight,
    Somatotype? somatotype,
    FitnessGoal? mainGoal,
    double? targetWeight,
    int? dailyCalorieGoal,
    ExperienceLevel? experienceLevel,
    Set<AerobicExerciseType>? aerobicExercises,
    WeeklyExerciseTime? weeklyExerciseTime,
    PreferredWorkoutTime? preferredWorkoutTime,
    // Calorie data parameters
    double? basalMetabolism,
    double? noExerciseTotalConsumption,
    double? strengthTrainingConsumption,
    double? aerobicConsumption,
    double? strengthTrainingDayBalance,
    double? restDayBalance,
    double? strengthTrainingDayShouldEat,
    double? restDayShouldEat,
  }) {
    return UserProfile(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nickname: nickname ?? this.nickname,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      somatotype: somatotype ?? this.somatotype,
      mainGoal: mainGoal ?? this.mainGoal,
      targetWeight: targetWeight ?? this.targetWeight,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      aerobicExercises: aerobicExercises ?? this.aerobicExercises,
      weeklyExerciseTime: weeklyExerciseTime ?? this.weeklyExerciseTime,
      preferredWorkoutTime: preferredWorkoutTime ?? this.preferredWorkoutTime,
      // Calorie data copying
      basalMetabolism: basalMetabolism ?? this.basalMetabolism,
      noExerciseTotalConsumption: noExerciseTotalConsumption ?? this.noExerciseTotalConsumption,
      strengthTrainingConsumption: strengthTrainingConsumption ?? this.strengthTrainingConsumption,
      aerobicConsumption: aerobicConsumption ?? this.aerobicConsumption,
      strengthTrainingDayBalance: strengthTrainingDayBalance ?? this.strengthTrainingDayBalance,
      restDayBalance: restDayBalance ?? this.restDayBalance,
      strengthTrainingDayShouldEat: strengthTrainingDayShouldEat ?? this.strengthTrainingDayShouldEat,
      restDayShouldEat: restDayShouldEat ?? this.restDayShouldEat,
    );
  }

  // Derived properties
  int get age {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  double get bmi => weight / ((height / 100) * (height / 100));

  /// 检查个人信息是否完整
  bool get isComplete {
    // 基础信息（身高、体重、生日、性别）在构造函数中已有默认值或必填，
    // 这里主要检查用户是否完成了引导流程中的其他详细设置（如运动习惯、基础代谢数据等）
    return nickname != 'User' && 
           aerobicExercises.isNotEmpty && 
           basalMetabolism != null;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'avatarUrl': avatarUrl,
      'nickname': nickname,
      'bio': bio,
      'gender': gender.toJson(),
      'birthday': birthday.millisecondsSinceEpoch,
      'height': height,
      'weight': weight,
      'somatotype': somatotype.toJson(),
      'mainGoal': mainGoal.toJson(),
      'targetWeight': targetWeight,
      'dailyCalorieGoal': dailyCalorieGoal,
      'experienceLevel': experienceLevel.toJson(),
      'aerobicExercises': aerobicExercises.map((e) => e.toJson()).toList(),
      'weeklyExerciseTime': weeklyExerciseTime.toJson(),
      'preferredWorkoutTime': preferredWorkoutTime.toJson(),
      // Calorie data serialization
      'basalMetabolism': basalMetabolism,
      'noExerciseTotalConsumption': noExerciseTotalConsumption,
      'strengthTrainingConsumption': strengthTrainingConsumption,
      'aerobicConsumption': aerobicConsumption,
      'strengthTrainingDayBalance': strengthTrainingDayBalance,
      'restDayBalance': restDayBalance,
      'strengthTrainingDayShouldEat': strengthTrainingDayShouldEat,
      'restDayShouldEat': restDayShouldEat,
    };
  }

  // JSON deserialization
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final aerobicExercises = <AerobicExerciseType>{};
    if (json['aerobicExercises'] is List) {
      for (var ae in json['aerobicExercises']) {
        final exercise = AerobicExerciseTypeExtension.fromJson(ae);
        if (exercise != null) {
          aerobicExercises.add(exercise);
        }
      }
    }
    
    return UserProfile(
      avatarUrl: json['avatarUrl'],
      nickname: json['nickname'] ?? 'User',
      bio: json['bio'],
      gender: GenderExtension.fromJson(json['gender']) ?? Gender.male,
      birthday: DateTime.fromMillisecondsSinceEpoch(json['birthday'] ?? DateTime(1995, 1, 1).millisecondsSinceEpoch),
      height: json['height'] ?? 170.0,
      weight: json['weight'] ?? 65.0,
      somatotype: SomatotypeExtension.fromJson(json['somatotype']) ?? Somatotype.mesomorph,
      mainGoal: FitnessGoalExtension.fromJson(json['mainGoal']) ?? FitnessGoal.keepFit,
      targetWeight: json['targetWeight'],
      dailyCalorieGoal: json['dailyCalorieGoal'],
      experienceLevel: ExperienceLevelExtension.fromJson(json['experienceLevel']) ?? ExperienceLevel.beginner,
      aerobicExercises: aerobicExercises,
      weeklyExerciseTime: WeeklyExerciseTimeExtension.fromJson(json['weeklyExerciseTime']) ?? WeeklyExerciseTime.thirtyMinutes,
      preferredWorkoutTime: PreferredWorkoutTimeExtension.fromJson(json['preferredWorkoutTime']) ?? PreferredWorkoutTime.morning,
      // Calorie data deserialization
      basalMetabolism: json['basalMetabolism'] as double?,
      noExerciseTotalConsumption: json['noExerciseTotalConsumption'] as double?,
      strengthTrainingConsumption: json['strengthTrainingConsumption'] as double?,
      aerobicConsumption: json['aerobicConsumption'] as double?,
      strengthTrainingDayBalance: json['strengthTrainingDayBalance'] as double?,
      restDayBalance: json['restDayBalance'] as double?,
      strengthTrainingDayShouldEat: json['strengthTrainingDayShouldEat'] as double?,
      restDayShouldEat: json['restDayShouldEat'] as double?,
    );
  }
}
