import 'package:flutter/material.dart';

// Enums
enum UserPersona {
  busyProfessional, // Busy professional
  student, // College student
  adaptiveAthlete, // Advanced fitness enthusiast
  beginner, // Beginner
  everydayPerson, // Regular person
  senior, // Senior citizen
}

enum Gender { male, female }

enum Somatotype {
  ectomorph, // Ectomorph (Lean)
  mesomorph, // Mesomorph (Muscular)
  endomorph, // Endomorph (Round)
}

enum FitnessGoal {
  weightLoss, // Weight loss
  muscleBuild, // Muscle building
  keepFit, // Keep fit
  endurance, // Endurance
}

enum DietPreference {
  standard, // Standard
  lowCarb, // Low carb
  highProtein, // High protein
  vegetarian, // Vegetarian
}

enum ExperienceLevel {
  beginner, // Beginner
  intermediate, // Intermediate
  advanced, // Advanced
}

enum WorkoutEnvironment {
  home, // Home
  gym, // Gym
  dorm, // Dorm
  office, // Office
  outdoor, // Outdoor
}

enum Equipment {
  none, // No equipment
  dumbbells, // Dumbbells
  resistanceBands, // Resistance bands
  yogaMat, // Yoga mat
  fullGym, // Full gym
}

enum AerobicExerciseType {
  // Running
  running, // Running
  jogging, // Jogging
  walking, // Walking
  
  // Cycling
  cycling, // Cycling
  stationaryBike, // Stationary bike
  
  // Swimming
  swimming, // Swimming
  
  //球类
  basketball, // Basketball
  football, // Football
  tennis, // Tennis
  badminton, // Badminton
  volleyball, // Volleyball
  
  // 其他
  aerobics, // Aerobics
  dancing, // Dancing
  jumpingRope, // Jumping rope
  hiking, // Hiking
  
  // 水上运动
  waterAerobics, // Water aerobics
  
  // 冬季运动
  skiing, // Skiing
  skating, // Skating
}

enum WeeklyExerciseTime {
  lessThan30Minutes, // Less than 30 minutes
  thirtyMinutes, // 30 minutes
  oneHour, // 1 hour
  oneAndHalfHours, // 1.5 hours
  twoHours, // 2 hours
  moreThanTwoHours, // More than 2 hours
}

enum PreferredWorkoutTime {
  earlyMorning, // 凌晨
  morning, // 早晨
  noon, // 中午
  evening, // 傍晚
  midnight, // 午夜
}

// Aerobic exercise data class with MET values
class AerobicExercise {
  final AerobicExerciseType type;
  final double met; // Metabolic Equivalent of Task
  
  const AerobicExercise(this.type, String name, this.met);
}

// Aerobic exercise data with MET values
const Map<AerobicExerciseType, AerobicExercise> aerobicExercisesData = {
  // Running
  AerobicExerciseType.running: AerobicExercise(AerobicExerciseType.running, 'Running', 9.8),
  AerobicExerciseType.jogging: AerobicExercise(AerobicExerciseType.jogging, 'Jogging', 7.2),
  AerobicExerciseType.walking: AerobicExercise(AerobicExerciseType.walking, 'Walking', 3.8),
  
  // Cycling
  AerobicExerciseType.cycling: AerobicExercise(AerobicExerciseType.cycling, 'Cycling', 6.8),
  AerobicExerciseType.stationaryBike: AerobicExercise(AerobicExerciseType.stationaryBike, 'StationaryBike', 6.8),
  
  // Swimming
  AerobicExerciseType.swimming: AerobicExercise(AerobicExerciseType.swimming, 'Swimming', 8.3),
  
  // Ball Sports
  AerobicExerciseType.basketball: AerobicExercise(AerobicExerciseType.basketball, 'Basketball', 6.1),
  AerobicExerciseType.football: AerobicExercise(AerobicExerciseType.football, 'Football', 7.0),
  AerobicExerciseType.tennis: AerobicExercise(AerobicExerciseType.tennis, 'Tennis', 8.9),
  AerobicExerciseType.badminton: AerobicExercise(AerobicExerciseType.badminton, 'Badminton', 7.4),
  AerobicExerciseType.volleyball: AerobicExercise(AerobicExerciseType.volleyball, 'Volleyball', 4.1),
  
  // Other
  AerobicExerciseType.aerobics: AerobicExercise(AerobicExerciseType.aerobics, 'Aerobics', 5.0),
  AerobicExerciseType.dancing: AerobicExercise(AerobicExerciseType.dancing, 'Dancing', 4.5),
  AerobicExerciseType.jumpingRope: AerobicExercise(AerobicExerciseType.jumpingRope, 'JumpingRope', 10.0),
  AerobicExerciseType.hiking: AerobicExercise(AerobicExerciseType.hiking, 'Hiking', 5.0),
  
  // Water Sports
  AerobicExerciseType.waterAerobics: AerobicExercise(AerobicExerciseType.waterAerobics, 'WaterAerobics', 4.0),
  
  // Winter Sports
  AerobicExerciseType.skiing: AerobicExercise(AerobicExerciseType.skiing, 'Skiing', 6.8),
  AerobicExerciseType.skating: AerobicExercise(AerobicExerciseType.skating, 'Skating', 5.5),
};

// Get weekly exercise time in minutes
int getWeeklyExerciseTimeInMinutes(WeeklyExerciseTime time) {
  switch (time) {
    case WeeklyExerciseTime.lessThan30Minutes:
      return 15;
    case WeeklyExerciseTime.thirtyMinutes:
      return 30;
    case WeeklyExerciseTime.oneHour:
      return 60;
    case WeeklyExerciseTime.oneAndHalfHours:
      return 90;
    case WeeklyExerciseTime.twoHours:
      return 120;
    case WeeklyExerciseTime.moreThanTwoHours:
      return 150;
  }
}

// Enum extension methods for serialization
extension UserPersonaExtension on UserPersona {
  String toJson() => name;
  static UserPersona? fromJson(String? value) => value != null ? UserPersona.values.byName(value) : null;
}

extension GenderExtension on Gender {
  String toJson() => name;
  static Gender? fromJson(String? value) => value != null ? Gender.values.byName(value) : null;
}

extension SomatotypeExtension on Somatotype {
  String toJson() => name;
  static Somatotype? fromJson(String? value) => value != null ? Somatotype.values.byName(value) : null;
}

extension FitnessGoalExtension on FitnessGoal {
  String toJson() => name;
  static FitnessGoal? fromJson(String? value) => value != null ? FitnessGoal.values.byName(value) : null;
}

extension DietPreferenceExtension on DietPreference {
  String toJson() => name;
  static DietPreference? fromJson(String? value) => value != null ? DietPreference.values.byName(value) : null;
}

extension ExperienceLevelExtension on ExperienceLevel {
  String toJson() => name;
  static ExperienceLevel? fromJson(String? value) => value != null ? ExperienceLevel.values.byName(value) : null;
}

extension WorkoutEnvironmentExtension on WorkoutEnvironment {
  String toJson() => name;
  static WorkoutEnvironment? fromJson(String? value) => value != null ? WorkoutEnvironment.values.byName(value) : null;
}

extension EquipmentExtension on Equipment {
  String toJson() => name;
  static Equipment? fromJson(String? value) => value != null ? Equipment.values.byName(value) : null;
}

extension AerobicExerciseTypeExtension on AerobicExerciseType {
  String toJson() => name;
  static AerobicExerciseType? fromJson(String? value) => value != null ? AerobicExerciseType.values.byName(value) : null;
}

extension WeeklyExerciseTimeExtension on WeeklyExerciseTime {
  String toJson() => name;
  static WeeklyExerciseTime? fromJson(String? value) => value != null ? WeeklyExerciseTime.values.byName(value) : null;
}

extension PreferredWorkoutTimeExtension on PreferredWorkoutTime {
  String toJson() => name;
  static PreferredWorkoutTime? fromJson(String? value) => value != null ? PreferredWorkoutTime.values.byName(value) : null;
}

class OnboardingState extends ChangeNotifier {
  // Constructor
  OnboardingState();

  // Step 1: Identity
  UserPersona? _persona;
  UserPersona? get persona => _persona;
  
  // Step 2: Basic Info
  Gender? _gender;
  DateTime? _birthday;
  Gender? get gender => _gender;
  DateTime? get birthday => _birthday;

  // Step 3: Physique
  double? _height; // cm
  double? _weight; // kg
  Somatotype? _somatotype;
  double? get height => _height;
  double? get weight => _weight;
  Somatotype? get somatotype => _somatotype;

  // Step 4: Goals
  FitnessGoal? _mainGoal;
  double? _targetWeight;
  FitnessGoal? get mainGoal => _mainGoal;
  double? get targetWeight => _targetWeight;

  // Step 5: Diet
  DietPreference? _dietPreference;
  DietPreference? get dietPreference => _dietPreference;

  // Step 6: Context
  ExperienceLevel? _experienceLevel;
  final Set<WorkoutEnvironment> _environments = {};
  final Set<Equipment> _equipment = {};
  
  // Step 7: Aerobic Exercise
  final Set<AerobicExerciseType> _aerobicExercises = {};
  final Map<AerobicExerciseType, int> _aerobicExerciseTimes = {}; // 每种有氧运动的每周时间（分钟）
  WeeklyExerciseTime? _weeklyExerciseTime;
  
  // Step 8: Calorie Data
  double? _basalMetabolism; // 基础代谢(a)
  double? _noExerciseTotalConsumption; // 无运动总消耗(b=a÷0.7)
  double? _strengthTrainingConsumption; // 力训消耗(c)
  double? _aerobicConsumption; // 有氧消耗(d)
  double? _strengthTrainingDayBalance; // 力训日(e1=b+c+d)
  double? _restDayBalance; // 休息日(e2=b+d)
  double? _strengthTrainingDayShouldEat; // 力训日应吃(f1=e1×0.64)
  double? _restDayShouldEat; // 休息日应吃(f2=e2×0.64)
  
  // Step 9: Preferred Workout Time
  PreferredWorkoutTime? _preferredWorkoutTime;
  PreferredWorkoutTime? get preferredWorkoutTime => _preferredWorkoutTime;
  
  ExperienceLevel? get experienceLevel => _experienceLevel;
  Set<WorkoutEnvironment> get environments => _environments;
  Set<Equipment> get equipment => _equipment;
  Set<AerobicExerciseType> get aerobicExercises => _aerobicExercises;
  Map<AerobicExerciseType, int> get aerobicExerciseTimes => _aerobicExerciseTimes;
  WeeklyExerciseTime? get weeklyExerciseTime => _weeklyExerciseTime;
  
  double? get basalMetabolism => _basalMetabolism;
  double? get noExerciseTotalConsumption => _noExerciseTotalConsumption;
  double? get strengthTrainingConsumption => _strengthTrainingConsumption;
  double? get aerobicConsumption => _aerobicConsumption;
  double? get strengthTrainingDayBalance => _strengthTrainingDayBalance;
  double? get restDayBalance => _restDayBalance;
  double? get strengthTrainingDayShouldEat => _strengthTrainingDayShouldEat;
  double? get restDayShouldEat => _restDayShouldEat;

  // Validation
  bool isBasicInfoValid() {
    return _gender != null && _birthday != null && _height != null && _weight != null;
  }

  bool isValid(int step) {
    switch (step) {
      case 0: // Identity
        return _persona != null;
      case 1: // Basic Info
        return isBasicInfoValid();
      default:
        return false;
    }
  }

  // Setters
  void setPersona(UserPersona p) { _persona = p; notifyListeners(); }
  void setGender(Gender g) { _gender = g; notifyListeners(); }
  void setBirthday(DateTime d) { _birthday = d; notifyListeners(); }
  void setHeight(double h) { _height = h; notifyListeners(); }
  void setWeight(double w) { _weight = w; notifyListeners(); }
  void setSomatotype(Somatotype s) { _somatotype = s; notifyListeners(); }
  void setMainGoal(FitnessGoal g) { _mainGoal = g; notifyListeners(); }
  void setTargetWeight(double? w) { _targetWeight = w; notifyListeners(); }
  void setDietPreference(DietPreference d) { _dietPreference = d; notifyListeners(); }
  void setExperienceLevel(ExperienceLevel e) { _experienceLevel = e; notifyListeners(); }
  
  void toggleExperienceLevel(ExperienceLevel e) {
    if (_experienceLevel == e) {
      _experienceLevel = null;
    } else {
      _experienceLevel = e;
    }
    notifyListeners();
  }
  void setWeeklyExerciseTime(WeeklyExerciseTime time) { _weeklyExerciseTime = time; notifyListeners(); }
  
  void toggleEnvironment(WorkoutEnvironment e) {
    if (_environments.contains(e)) {
      _environments.remove(e);
    } else {
      _environments.add(e);
    }
    notifyListeners();
  }

  void toggleEquipment(Equipment e) {
    if (_equipment.contains(e)) {
      _equipment.remove(e);
    } else {
      _equipment.add(e);
    }
    notifyListeners();
  }
  
  void toggleAerobicExercise(AerobicExerciseType e) {
    if (_aerobicExercises.contains(e)) {
      _aerobicExercises.remove(e);
      _aerobicExerciseTimes.remove(e);
    } else {
      _aerobicExercises.add(e);
      _aerobicExerciseTimes[e] = 30; // 默认时间为 30 分钟
    }
    notifyListeners();
  }
  
  void setAerobicExerciseTime(AerobicExerciseType e, int minutes) {
    if (_aerobicExercises.contains(e)) {
      _aerobicExerciseTimes[e] = minutes;
      notifyListeners();
    }
  }
  
  // Setters for calorie data
  void setBasalMetabolism(double value) {
    _basalMetabolism = value;
    notifyListeners();
  }
  
  void setNoExerciseTotalConsumption(double value) {
    _noExerciseTotalConsumption = value;
    notifyListeners();
  }
  
  void setStrengthTrainingConsumption(double value) {
    _strengthTrainingConsumption = value;
    notifyListeners();
  }
  
  void setAerobicConsumption(double value) {
    _aerobicConsumption = value;
    notifyListeners();
  }
  
  void setStrengthTrainingDayBalance(double value) {
    _strengthTrainingDayBalance = value;
    notifyListeners();
  }
  
  void setRestDayBalance(double value) {
    _restDayBalance = value;
    notifyListeners();
  }
  
  void setStrengthTrainingDayShouldEat(double value) {
    _strengthTrainingDayShouldEat = value;
    notifyListeners();
  }
  
  void setRestDayShouldEat(double value) {
    _restDayShouldEat = value;
    notifyListeners();
  }
  
  void setPreferredWorkoutTime(PreferredWorkoutTime time) {
    _preferredWorkoutTime = time;
    notifyListeners();
  }

  // Calculations
  int get age {
    if (_birthday == null) return 0;
    final now = DateTime.now();
    int age = now.year - _birthday!.year;
    if (now.month < _birthday!.month || (now.month == _birthday!.month && now.day < _birthday!.day)) {
      age--;
    }
    return age;
  }

  double get bmi {
    if (_weight == null || _height == null) return 0.0;
    return _weight! / ((_height! / 100) * (_height! / 100));
  }

  int get bmr {
    if (_weight == null || _height == null || _birthday == null) return 0;
    // Mifflin-St Jeor
    double s = _gender == Gender.male ? 5 : -161;
    return ((10 * _weight!) + (6.25 * _height!) - (5 * age) + s).round();
  }

  // Calculate aerobic calories burned per week
  int get weeklyAerobicCaloriesBurned {
    if (_weight == null || _aerobicExercises.isEmpty || _aerobicExerciseTimes.isEmpty) return 0;
    
    int totalCalories = 0;
    
    // For each selected exercise, calculate calories burned based on its MET and time
    for (final exerciseType in _aerobicExercises) {
      final exercise = aerobicExercisesData[exerciseType];
      final minutes = _aerobicExerciseTimes[exerciseType];
      
      if (exercise != null && minutes != null && minutes > 0) {
        // Calories burned formula: weight (kg) * MET * time (minutes) * 3.5 / 200
        double calories = (_weight! * exercise.met * minutes * 3.5) / 200;
        
        // Apply weight adjustment: from 80kg, every 5kg increase decreases calorie burn by 3%
        if (_weight! >= 80) {
          int weightAbove80 = (_weight! - 80).round();
          int decrementSteps = weightAbove80 ~/ 5;
          double weightAdjustment = 1.0 - (decrementSteps * 0.03);
          calories *= weightAdjustment;
        }
        
        totalCalories += calories.round();
      }
    }
    
    return totalCalories;
  }
  
  // Calculate calories burned for a specific exercise
  int calculateCaloriesForExercise(AerobicExerciseType exerciseType) {
    if (_weight == null) return 0;
    
    final exercise = aerobicExercisesData[exerciseType];
    final minutes = _aerobicExerciseTimes[exerciseType];
    
    if (exercise != null && minutes != null && minutes > 0) {
      double calories = (_weight! * exercise.met * minutes * 3.5) / 200;
      
      // Apply weight adjustment: from 80kg, every 5kg increase decreases calorie burn by 3%
      if (_weight! >= 80) {
        int weightAbove80 = (_weight! - 80).round();
        int decrementSteps = weightAbove80 ~/ 5;
        double weightAdjustment = 1.0 - (decrementSteps * 0.03);
        calories *= weightAdjustment;
      }
      
      return calories.round();
    }
    
    return 0;
  }
  
  // Update TDEE to include aerobic exercise
  int get tdee {
    double multiplier = 1.2;
    // Base multiplier on Persona/Experience for now
    switch (_persona) {
      case UserPersona.busyProfessional:
      case UserPersona.student:
      case UserPersona.beginner:
        multiplier = 1.2; // Sedentary
        break;
      case UserPersona.everydayPerson:
        multiplier = 1.375; // Lightly active
        break;
      case UserPersona.adaptiveAthlete:
        multiplier = 1.55; // Moderately active
        break;
      default:
        multiplier = 1.2;
    }
    
    // Calculate total weekly aerobic exercise time
    int totalMinutes = 0;
    for (final minutes in _aerobicExerciseTimes.values) {
      totalMinutes += minutes;
    }
    
    // Adjust multiplier based on total weekly exercise time
    if (totalMinutes > 0) {
      if (totalMinutes < 30) {
        multiplier = 1.375; // Lightly active
      } else if (totalMinutes < 90) {
        multiplier = 1.55; // Moderately active
      } else if (totalMinutes < 150) {
        multiplier = 1.725; // Very active
      } else {
        multiplier = 1.9; // Extra active
      }
    }
    
    return (bmr * multiplier).round();
  }
  
  int get recommendedCalories {
    int maintenance = tdee;
    switch (_mainGoal) {
      case FitnessGoal.weightLoss:
        return maintenance - 500;
      case FitnessGoal.muscleBuild:
        return maintenance + 300;
      default:
        return maintenance;
    }
  }

  // Calculate recommended weight range based on BMI
  Map<String, double> calculateRecommendedWeightRange() {
    if (_height == null) {
      return {'min': 40.0, 'max': 100.0};
    }
    
    double heightInMeters = _height! / 100;
    double minWeight = 18.5 * heightInMeters * heightInMeters;
    double maxWeight = 24.0 * heightInMeters * heightInMeters;
    
    return {'min': minWeight, 'max': maxWeight};
  }

  // Get recommended target weight based on fitness goal
  double getRecommendedTargetWeight() {
    if (_height == null) return _weight ?? 65.0;
    
    Map<String, double> range = calculateRecommendedWeightRange();
    
    switch (_mainGoal) {
      case FitnessGoal.weightLoss:
        // For weight loss, recommend towards the lower end of healthy range
        return range['min']! + (range['max']! - range['min']!) * 0.2;
      case FitnessGoal.muscleBuild:
        // For muscle building, recommend towards the upper end of healthy range
        return range['min']! + (range['max']! - range['min']!) * 0.8;
      case FitnessGoal.keepFit:
      case FitnessGoal.endurance:
      default:
        // For maintenance, recommend middle of healthy range
        return range['min']! + (range['max']! - range['min']!) * 0.5;
    }
  }
  
  // Custom calorie calculations based on user's formula
  
  // 基础代谢(a) - 使用现有的bmr计算
  double get customBasalMetabolism => bmr.toDouble();
  
  // 无运动总消耗(b) - 使用活动系数计算TDEE，更适合大体重用户
  double get customNoExerciseTotalConsumption => customBasalMetabolism * 1.2; // 久坐不动活动系数
  
  // 力训消耗(c) - 默认值，根据经验水平调整
  double get customStrengthTrainingConsumption {
    switch (_experienceLevel) {
      case ExperienceLevel.beginner:
        return _gender == Gender.male ? 150 : 100;
      case ExperienceLevel.intermediate:
        return _gender == Gender.male ? 200 : 150;
      case ExperienceLevel.advanced:
        return _gender == Gender.male ? 250 : 200;
      default:
        return _gender == Gender.male ? 150 : 100;
    }
  }
  
  // 有氧消耗(d) - 每周有氧消耗除以7
  double get customAerobicConsumption => weeklyAerobicCaloriesBurned / 7;
  
  // 力训日平衡热量(e1=b+c+d)
  double get customStrengthTrainingDayBalance {
    return customNoExerciseTotalConsumption + customStrengthTrainingConsumption + customAerobicConsumption;
  }
  
  // 休息日平衡热量(e2=b+d)
  double get customRestDayBalance {
    return customNoExerciseTotalConsumption + customAerobicConsumption;
  }
  
  // 力训日应吃热量(f1=e1×0.64)
  double get customStrengthTrainingDayShouldEat {
    return customStrengthTrainingDayBalance * 0.64;
  }
  
  // 休息日应吃热量(f2=e2×0.64)
  double get customRestDayShouldEat {
    return customRestDayBalance * 0.64;
  }

  // Get BMI category
  String getBMICategory() {
    if (_bmi < 18.5) return '偏瘦';
    if (_bmi < 24) return '正常';
    if (_bmi < 28) return '超重';
    return '肥胖';
  }

  // Get BMI color
  Color getBMIColor() {
    if (_bmi < 18.5) return const Color(0xFFFFAB40); // 更柔和的橙黄色
    if (_bmi < 24) return Colors.green;
    if (_bmi < 28) return Colors.red; // 红色表示超重
    return Colors.red; // 红色表示肥胖
  }

  // Private BMI getter for internal use
  double get _bmi {
    if (_weight == null || _height == null) return 0.0;
    return _weight! / ((_height! / 100) * (_height! / 100));
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'persona': _persona?.toJson(),
      'gender': _gender?.toJson(),
      'birthday': _birthday?.millisecondsSinceEpoch,
      'height': _height,
      'weight': _weight,
      'somatotype': _somatotype?.toJson(),
      'mainGoal': _mainGoal?.toJson(),
      'targetWeight': _targetWeight,
      'dietPreference': _dietPreference?.toJson(),
      'experienceLevel': _experienceLevel?.toJson(),
      'environments': _environments.map((e) => e.toJson()).toList(),
      'equipment': _equipment.map((e) => e.toJson()).toList(),
      'aerobicExercises': _aerobicExercises.map((e) => e.toJson()).toList(),
      'aerobicExerciseTimes': _aerobicExerciseTimes.map((e, t) => MapEntry(e.toJson(), t)),
      'weeklyExerciseTime': _weeklyExerciseTime?.toJson(),
      'preferredWorkoutTime': _preferredWorkoutTime?.toJson(),
      // Calorie data
      'basalMetabolism': _basalMetabolism,
      'noExerciseTotalConsumption': _noExerciseTotalConsumption,
      'strengthTrainingConsumption': _strengthTrainingConsumption,
      'aerobicConsumption': _aerobicConsumption,
      'strengthTrainingDayBalance': _strengthTrainingDayBalance,
      'restDayBalance': _restDayBalance,
      'strengthTrainingDayShouldEat': _strengthTrainingDayShouldEat,
      'restDayShouldEat': _restDayShouldEat,
    };
  }

  // JSON deserialization
  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    final state = OnboardingState();
    
    state._persona = UserPersonaExtension.fromJson(json['persona']);
    state._gender = GenderExtension.fromJson(json['gender']);
    
    if (json['birthday'] != null) {
      state._birthday = DateTime.fromMillisecondsSinceEpoch(json['birthday']);
    }
    
    state._height = json['height'];
    state._weight = json['weight'];
    state._somatotype = SomatotypeExtension.fromJson(json['somatotype']);
    state._mainGoal = FitnessGoalExtension.fromJson(json['mainGoal']);
    state._targetWeight = json['targetWeight'];
    state._dietPreference = DietPreferenceExtension.fromJson(json['dietPreference']);
    state._experienceLevel = ExperienceLevelExtension.fromJson(json['experienceLevel']);
    state._weeklyExerciseTime = WeeklyExerciseTimeExtension.fromJson(json['weeklyExerciseTime']);
    state._preferredWorkoutTime = PreferredWorkoutTimeExtension.fromJson(json['preferredWorkoutTime']);
    
    if (json['environments'] is List) {
      for (var env in json['environments']) {
        final environment = WorkoutEnvironmentExtension.fromJson(env);
        if (environment != null) {
          state._environments.add(environment);
        }
      }
    }
    
    if (json['equipment'] is List) {
      for (var eq in json['equipment']) {
        final equipment = EquipmentExtension.fromJson(eq);
        if (equipment != null) {
          state._equipment.add(equipment);
        }
      }
    }
    
    if (json['aerobicExercises'] is List) {
      for (var ae in json['aerobicExercises']) {
        final aerobicExercise = AerobicExerciseTypeExtension.fromJson(ae);
        if (aerobicExercise != null) {
          state._aerobicExercises.add(aerobicExercise);
          state._aerobicExerciseTimes[aerobicExercise] = 30; // 默认时间为 30 分钟
        }
      }
    }
    
    if (json['aerobicExerciseTimes'] is Map) {
      final exerciseTimesMap = json['aerobicExerciseTimes'] as Map;
      exerciseTimesMap.forEach((key, value) {
        final exercise = AerobicExerciseTypeExtension.fromJson(key as String);
        if (exercise != null && value is int) {
          state._aerobicExerciseTimes[exercise] = value;
        }
      });
    }
    
    // Calorie data deserialization
    state._basalMetabolism = json['basalMetabolism'] as double?;
    state._noExerciseTotalConsumption = json['noExerciseTotalConsumption'] as double?;
    state._strengthTrainingConsumption = json['strengthTrainingConsumption'] as double?;
    state._aerobicConsumption = json['aerobicConsumption'] as double?;
    state._strengthTrainingDayBalance = json['strengthTrainingDayBalance'] as double?;
    state._restDayBalance = json['restDayBalance'] as double?;
    state._strengthTrainingDayShouldEat = json['strengthTrainingDayShouldEat'] as double?;
    state._restDayShouldEat = json['restDayShouldEat'] as double?;
    
    return state;
  }
}
