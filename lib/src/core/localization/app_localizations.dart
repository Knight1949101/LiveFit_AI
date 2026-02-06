import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'LifeFit AI',
      'loginTitle': 'Welcome Back',
      'loginSubtitle': 'Sign in to continue',
      'emailHint': 'Email',
      'passwordHint': 'Password',
      'forgotPassword': 'Forgot Password?',
      'loginButton': 'Login',
      'orLoginWith': 'Or login with',
      'dontHaveAccount': 'Don\'t have an account?',
      'register': 'Register',
      'settings': 'Settings',
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'notifications': 'Notifications',
      'accountSecurity': 'Account Security',
      'changePassword': 'Change Password',
      'bindPhone': 'Bind Phone',
      'about': 'About',
      'privacyPolicy': 'Privacy Policy',
      'userAgreement': 'User Agreement',
      'aboutUs': 'About Us',
      'logout': 'Logout',
      'general': 'General',
      'userHabits': 'User Habits',
      'aerobicExerciseHabits': 'Aerobic Exercise Habits',
      'switchingLanguage': 'Language switched to English',
      'statistics': 'Statistics',
      'week': 'Week',
      'month': 'Month',
      'year': 'Year',
      'time': 'Time',
      'calories': 'Calories',
      'workouts': 'Workouts',
      'unitHours': 'hours',
      'unitKcal': 'kcal',
      'unitCount': 'count',
      'navHome': 'Home',
      'navSchedule': 'Schedule',
      'navAi': 'AI',
      'navProfile': 'Profile',
      'activityTrend': 'Activity Trend',
      'weeklyTarget': 'Weekly Target',
      'workoutDistribution': 'Workout Distribution',
      'cardio': 'Cardio',
      'strength': 'Strength',
      'flexibility': 'Flexibility',
      'balance': 'Balance',
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',
      'eventClicked': 'Clicked: ',
      'addSchedule': 'Add Schedule',
      'scheduleTitleLabel': 'Title',
      'scheduleTitleHint': 'e.g., Morning Run, Team Meeting',
      'type': 'Type',
      'date': 'Date',
      'startTime': 'Start Time',
      'endTime': 'End Time',
      'note': 'Note',
      'noteHint': 'Add details...',
      'saveSchedule': 'Save Schedule',
      'voiceAdd': 'Voice Add',
      'experienceLevel': 'Experience',
      'experienceLevelBeginner': 'Beginner',
      'experienceLevelIntermediate': 'Intermediate',
      'experienceLevelAdvanced': 'Advanced',
      'typeWorkout': 'Workout',
      'typeWork': 'Work',
      'typeLife': 'Life',
      'typeRest': 'Rest',
      'typeOther': 'Other',
      'todayStarredEvents': 'Today\'s Important Events',
      'noStarredEventsToday': 'No important starred events today',
      // Preferred Workout Time
      'preferredWorkoutTime': 'Preferred Workout Time',
      'preferredWorkoutTimeEarlyMorning': 'Early Morning',
      'preferredWorkoutTimeMorning': 'Morning',
      'preferredWorkoutTimeNoon': 'Noon',
      'preferredWorkoutTimeEvening': 'Evening',
      'preferredWorkoutTimeMidnight': 'Midnight',
      // Aerobic Exercise Types
      'aerobicExerciseRunning': 'Running',
      'aerobicExerciseJogging': 'Jogging',
      'aerobicExerciseWalking': 'Walking',
      'aerobicExerciseCycling': 'Cycling',
      'aerobicExerciseStationaryBike': 'Stationary Bike',
      'aerobicExerciseSwimming': 'Swimming',
      'aerobicExerciseBasketball': 'Basketball',
      'aerobicExerciseFootball': 'Football',
      'aerobicExerciseTennis': 'Tennis',
      'aerobicExerciseBadminton': 'Badminton',
      'aerobicExerciseVolleyball': 'Volleyball',
      'aerobicExerciseAerobics': 'Aerobics',
      'aerobicExerciseDancing': 'Dancing',
      'aerobicExerciseJumpingRope': 'Jumping Rope',
      'aerobicExerciseHiking': 'Hiking',
      'aerobicExerciseWaterAerobics': 'Water Aerobics',
      'aerobicExerciseSkiing': 'Skiing',
      'aerobicExerciseSkating': 'Skating',
      // Aerobic Exercise Habits Page
      'aerobicHabitsTitle': 'Edit Aerobic Exercise Habits',
      'aerobicHabitsSectionTitle': 'Daily Activity Habits (Multiple Choice)',
      'aerobicHabitsDescription': 'Select the aerobic exercises you regularly do and set weekly time',
      'aerobicCategoryRunning': 'Running',
      'aerobicCategoryCycling': 'Cycling',
      'aerobicCategorySwimming': 'Swimming',
      'aerobicCategoryBallSports': 'Ball Sports',
      'aerobicCategoryOther': 'Other',
      'aerobicWeeklyTime': 'Weekly Time: ',
      'minutes': 'minutes',
      // Login Page
      'agreeToPrivacy': 'Please read and agree to the user agreement and privacy policy',
      'sampleProtocol': 'This is sample protocol content...',
      'iUnderstand': 'I understand',
      'wechatLogin': 'WeChat Login',
      'qqLogin': 'QQ Login',
      'appleLogin': 'Apple Login',
      'exploreAsGuest': 'Explore as guest',
      // Error Messages
      'errorMessage': 'Error: ',
      'errorNavigating': 'Error navigating to ProfileEditScreen',
      // Profile Edit
      'save': 'Save',
      'basicInfo': 'Basic Info',
      'nickname': 'Nickname',
      'gender': 'Gender',
      'birthday': 'Birthday',
      'physique': 'Physique',
      'height': 'Height',
      'weight': 'Weight',
      'bodyType': 'Body Type',
      'selectBodyType': 'Select your body type',
      'goals': 'Fitness Goals',
      'mainGoal': 'Main Goal',
      'targetWeight': 'Target Weight',
      // Gender Enum
      'genderMale': 'Male',
      'genderFemale': 'Female',
      // Somatotype Enum
      'somatotypeEctomorph': 'Ectomorph (Lean)',
      'somatotypeMesomorph': 'Mesomorph (Muscular)',
      'somatotypeEndomorph': 'Endomorph (Round)',
      // FitnessGoal Enum
      'goalWeightLoss': 'Weight Loss',
      'goalMuscleBuild': 'Muscle Build',
      'goalKeepFit': 'Keep Fit',
      'goalEndurance': 'Endurance',
      // Greetings
      'greetingNight': 'Good night,',
      'greetingMorning': 'Good morning,',
      'greetingAfternoon': 'Good afternoon,',
      'greetingEvening': 'Good evening,',
      // Calorie Summary
      'calorieSummary': 'Calorie Summary',
      'dailyRecommendedCalories': 'Daily Calories',
      'basalMetabolism': 'BMR',
      'totalConsumption': 'Total Cals',
      'calorieRequirements': 'Calorie Needs',
      'basalMetabolicRate': 'BMR',
      'totalDailyEnergyExpenditure': 'TDEE',
      'recommendedCalorieIntake': 'Recommended Intake',
      'caloriesPerDay': 'cal/day',
      'dailyActivityConsumption': 'Daily Activity',
      'weeklyTotalConsumption': 'Weekly Total',
      'calorieDataDetails': 'Calorie Details',
      'strengthTrainingConsumption': 'Strength Training',
      'aerobicConsumption': 'Aerobic',
      'strengthTrainingDayBalance': 'Strength Day Balance',
      'restDayBalance': 'Rest Day Balance',
      'strengthTrainingDayShouldEat': 'Strength Day Intake',
      'restDayShouldEat': 'Rest Day Intake',
      // Dashboard
      'aiSuggestion': 'AI Smart Suggestion',
      'noSuggestion': 'No suggestions',
      'refreshToGetSuggestion': 'Tap refresh to get suggestions',
      'positionSwitchInDevelopment': 'Position switching feature in development',
      'exerciseRecommendation': 'Exercise Recommendation',
      'recommendedSports': 'Recommended Sports:',
      'notRecommended': 'Not Recommended:',
      'suggestOutdoorActivity': 'Recommend outdoor activities',
      'suggestIndoorActivity': 'Recommend indoor activities',
      'todaySchedule': 'Today\'s Schedule',
      'noScheduleToday': 'No schedule today',
      'clickToAddTask': 'Click + to add a new task',
      // Weather Recommendations
      'weatherRecommendationVerySuitable': 'Perfect weather for outdoor activities!',
      'weatherRecommendationSuitable': 'Good weather for outdoor activities.',
      'weatherRecommendationModeratelySuitable': 'Moderate weather for exercise, consider adjusting intensity.',
      'weatherRecommendationUnsuitable': 'Not suitable for outdoor activities, try indoor exercises.',
      // Weather Alerts
      'weatherAlertRain': 'Rainy weather, not suitable for outdoor activities.',
      'weatherAlertSnow': 'Snowy weather, not suitable for outdoor activities.',
      'weatherAlertLowVisibility': 'Low visibility, not suitable for outdoor activities.',
      'weatherAlertLowTemp': 'Low temperature, not suitable for outdoor activities.',
      'weatherAlertHighTemp': 'High temperature, not suitable for outdoor activities.',
      'weatherAlertHighWind': 'Strong winds, not suitable for outdoor activities.',
      // Exercise Types
      'weatherExerciseLightRunning': 'Light Running',
      'weatherExerciseHighIntensity': 'High Intensity Interval Training',
      'weatherExerciseLongOutdoor': 'Long Outdoor Exercise',
      'weatherExerciseIndoorRunning': 'Indoor Running',
      'weatherExerciseStrengthTraining': 'Strength Training',
      'weatherExerciseAllOutdoor': 'All Outdoor Exercises',
      // Weather Suitability
      'weatherSuitabilityVerySuitable': 'Very Suitable',
      'weatherSuitabilitySuitable': 'Suitable',
      'weatherSuitabilityModeratelySuitable': 'Moderately Suitable',
      'weatherSuitabilityUnsuitable': 'Unsuitable',
      'aerobicExerciseYoga': 'Yoga',
      // Voice Schedule
      'customizeSchedule': 'Customize Schedule',
      'processingYourPlan': 'Processing your plan...',
      'listening': 'Listening...',
      'clickMicToSpeak': 'Click the microphone and say your plan',
      'exampleVoiceInput': 'e.g., "Help me schedule a gym session tomorrow at 6 PM"',
      'editSchedule': 'Edit Schedule',
      'health': 'Health',
      'work': 'Work',
      'pleaseEnterScheduleTitle': 'Please enter a schedule title',
      'endTimeCannotBeEarlier': 'End time cannot be earlier than start time',
      'cancel': 'Cancel',
      'clearData': 'Clear Data',
      'clearDataConfirmTitle': 'Clear All Data',
      'clearDataConfirmMessage': 'Are you sure you want to clear all user data? This action cannot be undone.',
      'confirm': 'Confirm',
      'clearDataSuccess': 'All data has been cleared',
      'clearDataFailed': 'Failed to clear data, please try again',
    },
    'zh': {
      'appTitle': 'LifeFit AI',
      'loginTitle': '欢迎回来',
      'loginSubtitle': '登录以继续',
      'emailHint': '邮箱',
      'passwordHint': '密码',
      'forgotPassword': '忘记密码？',
      'loginButton': '登录',
      'orLoginWith': '其他登录方式',
      'dontHaveAccount': '还没有账号？',
      'register': '立即注册',
      'settings': '设置',
      'darkMode': '深色模式',
      'language': '多语言',
      'notifications': '通知提醒',
      'accountSecurity': '账号安全',
      'changePassword': '修改密码',
      'bindPhone': '绑定手机',
      'about': '关于',
      'privacyPolicy': '隐私政策',
      'userAgreement': '用户协议',
      'aboutUs': '关于我们',
      'logout': '退出登录',
      'general': '常规',
      'userHabits': '用户习惯',
      'aerobicExerciseHabits': '有氧运动习惯',
      'switchingLanguage': '已切换至简体中文',
      'statistics': '统计',
      'week': '周',
      'month': '月',
      'year': '年',
      'time': '总时间',
      'calories': '卡路里',
      'workouts': '运动次数',
      'unitHours': '小时',
      'unitKcal': '千卡',
      'unitCount': '次',
      'navHome': '首页',
      'navSchedule': '日程',
      'navAi': 'AI',
      'navProfile': '我的',
      'activityTrend': '活动趋势',
      'weeklyTarget': '每周目标',
      'workoutDistribution': '运动分布',
      'cardio': '有氧',
      'strength': '力量',
      'flexibility': '柔韧',
      'balance': '平衡',
      'mon': '周一',
      'tue': '周二',
      'wed': '周三',
      'thu': '周四',
      'fri': '周五',
      'sat': '周六',
      'sun': '周日',
      'todayStarredEvents': '今日重要日程',
      'noStarredEventsToday': '今天没有重要标星日程',
      // Preferred Workout Time
      'preferredWorkoutTime': '偏好运动时间',
      'preferredWorkoutTimeEarlyMorning': '凌晨',
      'preferredWorkoutTimeMorning': '早晨',
      'preferredWorkoutTimeNoon': '中午',
      'preferredWorkoutTimeEvening': '傍晚',
      'preferredWorkoutTimeMidnight': '午夜',
      // Aerobic Exercise Types
      'aerobicExerciseRunning': '跑步',
      'aerobicExerciseJogging': '慢跑',
      'aerobicExerciseWalking': '步行',
      'aerobicExerciseCycling': '骑行',
      'aerobicExerciseStationaryBike': '固定自行车',
      'aerobicExerciseSwimming': '游泳',
      'aerobicExerciseBasketball': '篮球',
      'aerobicExerciseFootball': '足球',
      'aerobicExerciseTennis': '网球',
      'aerobicExerciseBadminton': '羽毛球',
      'aerobicExerciseVolleyball': '排球',
      'aerobicExerciseAerobics': '有氧操',
      'aerobicExerciseDancing': '跳舞',
      'aerobicExerciseJumpingRope': '跳绳',
      'aerobicExerciseHiking': '徒步',
      'aerobicExerciseWaterAerobics': '水中有氧',
      'aerobicExerciseSkiing': '滑雪',
      'aerobicExerciseSkating': '滑冰',
      // Aerobic Exercise Habits Page
      'aerobicHabitsTitle': '修改有氧运动习惯',
      'aerobicHabitsSectionTitle': '日常活动习惯 (多选)',
      'aerobicHabitsDescription': '选择你经常进行的有氧运动，并设置每周时间',
      'aerobicCategoryRunning': '跑步类',
      'aerobicCategoryCycling': '骑行类',
      'aerobicCategorySwimming': '游泳类',
      'aerobicCategoryBallSports': '球类',
      'aerobicCategoryOther': '其他',
      'aerobicWeeklyTime': '每周时间: ',
      'minutes': '分钟',
      // Login Page
      'agreeToPrivacy': '请阅读并同意用户协议和隐私政策',
      'sampleProtocol': '这是协议样本内容...',
      'iUnderstand': '我知道了',
      'wechatLogin': '微信登录',
      'qqLogin': 'QQ登录',
      'appleLogin': 'Apple登录',
      'exploreAsGuest': '游客模式探索',
      // Error Messages
      'errorMessage': '错误：',
      'errorNavigating': '导航到个人资料编辑页面时出错',
      // Profile Edit
      'save': '保存',
      'basicInfo': '基本信息',
      'nickname': '昵称',
      'gender': '性别',
      'birthday': '生日',
      'physique': '身体数据',
      'height': '身高',
      'weight': '体重',
      'bodyType': '体型',
      'selectBodyType': '选择你的体型',
      'goals': '健身目标',
      'mainGoal': '主要目标',
      'targetWeight': '目标体重',
      // Gender Enum
      'genderMale': '男',
      'genderFemale': '女',
      // Somatotype Enum
      'somatotypeEctomorph': '外胚型 (瘦长)',
      'somatotypeMesomorph': '中胚型 (健壮)',
      'somatotypeEndomorph': '内胚型 (圆润)',
      // FitnessGoal Enum
      'goalWeightLoss': '减脂',
      'goalMuscleBuild': '增肌',
      'goalKeepFit': '保持健康',
      'goalEndurance': '增强体能',
      // ExperienceLevel Enum
      'experienceLevel': '力训经验',
      'experienceLevelBeginner': '初级',
      'experienceLevelIntermediate': '中级',
      'experienceLevelAdvanced': '高级',
      // Greetings
      'greetingNight': '晚安，',
      'greetingMorning': '早上好，',
      'greetingAfternoon': '下午好，',
      'greetingEvening': '晚上好，',
      'typeWorkout': '运动',
      'typeWork': '工作',
      'typeLife': '生活',
      'typeRest': '休息',
      'typeOther': '其他',
      // Calorie Summary
      'calorieSummary': '热量总结',
      'dailyRecommendedCalories': '每日热量',
      'basalMetabolism': '基础代谢',
      'totalConsumption': '总消耗',
      'calorieRequirements': '热量需求',
      'basalMetabolicRate': 'BMR',
      'totalDailyEnergyExpenditure': 'TDEE',
      'recommendedCalorieIntake': '推荐摄入',
      'caloriesPerDay': '卡/天',
      'dailyActivityConsumption': '日常活动',
      'weeklyTotalConsumption': '每周总消耗',
      'calorieDataDetails': '热量详情',
      'strengthTrainingConsumption': '力量训练',
      'aerobicConsumption': '有氧训练',
      'strengthTrainingDayBalance': '训练日平衡',
      'restDayBalance': '休息日平衡',
      'strengthTrainingDayShouldEat': '训练日摄入',
      'restDayShouldEat': '休息日摄入',
      // Dashboard
      'aiSuggestion': 'AI 智能建议',
      'noSuggestion': '暂无建议',
      'refreshToGetSuggestion': '点击刷新获取建议',
      'positionSwitchInDevelopment': '位置切换功能开发中',
      'exerciseRecommendation': '锻炼建议',
      'recommendedSports': '推荐运动:',
      'notRecommended': '不推荐:',
      'suggestOutdoorActivity': '建议户外活动',
      'suggestIndoorActivity': '建议室内活动',
      'todaySchedule': '今日日程',
      'noScheduleToday': '今天没有安排日程',
      'clickToAddTask': '点击 + 添加新任务',
      // Weather Recommendations
      'weatherRecommendationVerySuitable': '天气非常适宜户外运动！',
      'weatherRecommendationSuitable': '天气适宜户外运动。',
      'weatherRecommendationModeratelySuitable': '天气较适宜运动，建议适当调整运动强度。',
      'weatherRecommendationUnsuitable': '天气不适宜户外运动，建议选择室内运动。',
      // Weather Alerts
      'weatherAlertRain': '当前有降雨，不适宜户外运动。',
      'weatherAlertSnow': '当前有降雪，不适宜户外运动。',
      'weatherAlertLowVisibility': '当前能见度低，不适宜户外运动。',
      'weatherAlertLowTemp': '当前温度过低，不适宜户外运动。',
      'weatherAlertHighTemp': '当前温度过高，不适宜户外运动。',
      'weatherAlertHighWind': '当前风力较大，不适宜户外运动。',
      // Exercise Types
      'weatherExerciseLightRunning': '轻度跑步',
      'weatherExerciseHighIntensity': '高强度间歇训练',
      'weatherExerciseLongOutdoor': '长时间户外运动',
      'weatherExerciseIndoorRunning': '室内跑步',
      'weatherExerciseStrengthTraining': '力量训练',
      'weatherExerciseAllOutdoor': '所有户外运动',
      // Suitability Text
      'weatherSuitabilityVerySuitable': '非常适宜',
      'weatherSuitabilitySuitable': '适宜',
      'weatherSuitabilityModeratelySuitable': '较适宜',
      'weatherSuitabilityUnsuitable': '不适宜',
      'aerobicExerciseYoga': '瑜伽',
      // Voice Schedule
      'customizeSchedule': '定制日程',
      'processingYourPlan': '正在解析您的计划...',
      'listening': '正在聆听...',
      'clickMicToSpeak': '点击麦克风，说出你的计划',
      'exampleVoiceInput': '例如："帮我安排明天下午6点去健身房"',
      'editSchedule': '编辑日程',
      'health': '健康',
      'work': '工作',
      'pleaseEnterScheduleTitle': '请输入日程标题',
      'endTimeCannotBeEarlier': '结束时间不能早于开始时间',
      'cancel': '取消',
      'clearData': '清除数据',
      'clearDataConfirmTitle': '清除所有数据',
      'clearDataConfirmMessage': '确定要清除所有用户数据吗？此操作不可撤销。',
      'confirm': '确认',
      'clearDataSuccess': '已清除所有数据',
      'clearDataFailed': '清除数据失败，请重试',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get loginTitle => _localizedValues[locale.languageCode]!['loginTitle']!;
  String get loginSubtitle => _localizedValues[locale.languageCode]!['loginSubtitle']!;
  String get emailHint => _localizedValues[locale.languageCode]!['emailHint']!;
  String get passwordHint => _localizedValues[locale.languageCode]!['passwordHint']!;
  String get forgotPassword => _localizedValues[locale.languageCode]!['forgotPassword']!;
  String get loginButton => _localizedValues[locale.languageCode]!['loginButton']!;
  String get orLoginWith => _localizedValues[locale.languageCode]!['orLoginWith']!;
  String get dontHaveAccount => _localizedValues[locale.languageCode]!['dontHaveAccount']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get darkMode => _localizedValues[locale.languageCode]!['darkMode']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get accountSecurity => _localizedValues[locale.languageCode]!['accountSecurity']!;
  String get changePassword => _localizedValues[locale.languageCode]!['changePassword']!;
  String get bindPhone => _localizedValues[locale.languageCode]!['bindPhone']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get privacyPolicy => _localizedValues[locale.languageCode]!['privacyPolicy']!;
  String get userAgreement => _localizedValues[locale.languageCode]!['userAgreement']!;
  String get aboutUs => _localizedValues[locale.languageCode]!['aboutUs']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get general => _localizedValues[locale.languageCode]!['general']!;
  String get userHabits => _localizedValues[locale.languageCode]!['userHabits']!;
  String get aerobicExerciseHabits => _localizedValues[locale.languageCode]!['aerobicExerciseHabits']!;
  String get switchingLanguage => _localizedValues[locale.languageCode]!['switchingLanguage']!;
  String get statistics => _localizedValues[locale.languageCode]!['statistics']!;
  String get week => _localizedValues[locale.languageCode]!['week']!;
  String get month => _localizedValues[locale.languageCode]!['month']!;
  String get year => _localizedValues[locale.languageCode]!['year']!;
  String get time => _localizedValues[locale.languageCode]!['time']!;
  String get calories => _localizedValues[locale.languageCode]!['calories']!;
  String get workouts => _localizedValues[locale.languageCode]!['workouts']!;
  String get unitHours => _localizedValues[locale.languageCode]!['unitHours']!;
  String get unitKcal => _localizedValues[locale.languageCode]!['unitKcal']!;
  String get unitCount => _localizedValues[locale.languageCode]!['unitCount']!;
  String get navHome => _localizedValues[locale.languageCode]!['navHome']!;
  String get navSchedule => _localizedValues[locale.languageCode]!['navSchedule']!;
  String get navAi => _localizedValues[locale.languageCode]!['navAi']!;
  String get navProfile => _localizedValues[locale.languageCode]!['navProfile']!;
  String get activityTrend => _localizedValues[locale.languageCode]!['activityTrend']!;
  String get weeklyTarget => _localizedValues[locale.languageCode]!['weeklyTarget']!;
  String get workoutDistribution => _localizedValues[locale.languageCode]!['workoutDistribution']!;
  String get cardio => _localizedValues[locale.languageCode]!['cardio']!;
  String get strength => _localizedValues[locale.languageCode]!['strength']!;
  String get flexibility => _localizedValues[locale.languageCode]!['flexibility']!;
  String get balance => _localizedValues[locale.languageCode]!['balance']!;
  String get mon => _localizedValues[locale.languageCode]!['mon']!;
  String get tue => _localizedValues[locale.languageCode]!['tue']!;
  String get wed => _localizedValues[locale.languageCode]!['wed']!;
  String get thu => _localizedValues[locale.languageCode]!['thu']!;
  String get fri => _localizedValues[locale.languageCode]!['fri']!;
  String get sat => _localizedValues[locale.languageCode]!['sat']!;
  String get sun => _localizedValues[locale.languageCode]!['sun']!;
  
  String get voiceAdd => _localizedValues[locale.languageCode]!['voiceAdd']!;
  String get typeWorkout => _localizedValues[locale.languageCode]!['typeWorkout']!;
  String get typeWork => _localizedValues[locale.languageCode]!['typeWork']!;
  String get typeLife => _localizedValues[locale.languageCode]!['typeLife']!;
  String get typeRest => _localizedValues[locale.languageCode]!['typeRest']!;
  String get typeOther => _localizedValues[locale.languageCode]!['typeOther']!;
  String get eventClicked => _localizedValues[locale.languageCode]!['eventClicked']!;

  // Profile Edit
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get basicInfo => _localizedValues[locale.languageCode]?['basicInfo'] ?? 'Basic Info';
  String get nickname => _localizedValues[locale.languageCode]?['nickname'] ?? 'Nickname';
  String get gender => _localizedValues[locale.languageCode]?['gender'] ?? 'Gender';
  String get birthday => _localizedValues[locale.languageCode]?['birthday'] ?? 'Birthday';
  String get physique => _localizedValues[locale.languageCode]?['physique'] ?? 'Physique';
  String get height => _localizedValues[locale.languageCode]?['height'] ?? 'Height';
  String get weight => _localizedValues[locale.languageCode]?['weight'] ?? 'Weight';
  String get bodyType => _localizedValues[locale.languageCode]?['bodyType'] ?? 'Body Type';
  String get selectBodyType => _localizedValues[locale.languageCode]?['selectBodyType'] ?? 'Select body type';
  String get goals => _localizedValues[locale.languageCode]?['goals'] ?? 'Goals';
  String get mainGoal => _localizedValues[locale.languageCode]?['mainGoal'] ?? 'Main Goal';
  String get targetWeight => _localizedValues[locale.languageCode]?['targetWeight'] ?? 'Target Weight';
  String get goalEndurance => _localizedValues[locale.languageCode]?['goalEndurance'] ?? 'Endurance';
  String get experienceLevel => _localizedValues[locale.languageCode]?['experienceLevel'] ?? 'Experience';
  // Login Page
  String get agreeToPrivacy => _localizedValues[locale.languageCode]?['agreeToPrivacy'] ?? 'Please read and agree to the user agreement and privacy policy';
  String get sampleProtocol => _localizedValues[locale.languageCode]?['sampleProtocol'] ?? 'This is sample protocol content...';
  String get iUnderstand => _localizedValues[locale.languageCode]?['iUnderstand'] ?? 'I understand';
  String get wechatLogin => _localizedValues[locale.languageCode]?['wechatLogin'] ?? 'WeChat Login';
  String get qqLogin => _localizedValues[locale.languageCode]?['qqLogin'] ?? 'QQ Login';
  String get appleLogin => _localizedValues[locale.languageCode]?['appleLogin'] ?? 'Apple Login';
  String get exploreAsGuest => _localizedValues[locale.languageCode]?['exploreAsGuest'] ?? 'Explore as guest';
  // Error Messages
  String get errorMessage => _localizedValues[locale.languageCode]?['errorMessage'] ?? 'Error: ';
  String get errorNavigating => _localizedValues[locale.languageCode]?['errorNavigating'] ?? 'Error navigating to ProfileEditScreen';
  
  // Greetings
  String get greetingNight => _localizedValues[locale.languageCode]!['greetingNight']!;
  String get greetingMorning => _localizedValues[locale.languageCode]!['greetingMorning']!;
  String get greetingAfternoon => _localizedValues[locale.languageCode]!['greetingAfternoon']!;
  String get greetingEvening => _localizedValues[locale.languageCode]!['greetingEvening']!;
  
  // Enum Helpers
  String getGenderName(String key) => _localizedValues[locale.languageCode]?['gender$key'] ?? key;
  String getSomatotypeName(String key) => _localizedValues[locale.languageCode]?['somatotype$key'] ?? key;
  String getGoalName(String key) => _localizedValues[locale.languageCode]?['goal$key'] ?? key;
  String getExperienceLevelName(String key) => _localizedValues[locale.languageCode]?['experienceLevel$key'] ?? key;
  String getPreferredWorkoutTimeName(String key) => _localizedValues[locale.languageCode]?['preferredWorkoutTime$key'] ?? key;
  String getAerobicExerciseTypeName(String key) => _localizedValues[locale.languageCode]?['aerobicExercise$key'] ?? key;

  String get addSchedule => _localizedValues[locale.languageCode]!['addSchedule']!;
  String get scheduleTitleLabel => _localizedValues[locale.languageCode]!['scheduleTitleLabel']!;
  String get scheduleTitleHint => _localizedValues[locale.languageCode]!['scheduleTitleHint']!;
  String get type => _localizedValues[locale.languageCode]!['type']!;
  String get date => _localizedValues[locale.languageCode]!['date']!;
  String get startTime => _localizedValues[locale.languageCode]!['startTime']!;
  String get endTime => _localizedValues[locale.languageCode]!['endTime']!;
  String get note => _localizedValues[locale.languageCode]!['note']!;
  String get noteHint => _localizedValues[locale.languageCode]!['noteHint']!;
  String get saveSchedule => _localizedValues[locale.languageCode]!['saveSchedule']!;
  
  // Preferred Workout Time
  String get preferredWorkoutTime => _localizedValues[locale.languageCode]!['preferredWorkoutTime']!;
  String get preferredWorkoutTimeEarlyMorning => _localizedValues[locale.languageCode]!['preferredWorkoutTimeEarlyMorning']!;
  String get preferredWorkoutTimeMorning => _localizedValues[locale.languageCode]!['preferredWorkoutTimeMorning']!;
  String get preferredWorkoutTimeNoon => _localizedValues[locale.languageCode]!['preferredWorkoutTimeNoon']!;
  String get preferredWorkoutTimeEvening => _localizedValues[locale.languageCode]!['preferredWorkoutTimeEvening']!;
  String get preferredWorkoutTimeMidnight => _localizedValues[locale.languageCode]!['preferredWorkoutTimeMidnight']!;
  
  // Calorie Summary Getters
  String get calorieSummary => _localizedValues[locale.languageCode]!['calorieSummary']!;
  String get dailyRecommendedCalories => _localizedValues[locale.languageCode]!['dailyRecommendedCalories']!;
  String get basalMetabolism => _localizedValues[locale.languageCode]!['basalMetabolism']!;
  String get totalConsumption => _localizedValues[locale.languageCode]!['totalConsumption']!;
  String get calorieRequirements => _localizedValues[locale.languageCode]!['calorieRequirements']!;
  String get basalMetabolicRate => _localizedValues[locale.languageCode]!['basalMetabolicRate']!;
  String get totalDailyEnergyExpenditure => _localizedValues[locale.languageCode]!['totalDailyEnergyExpenditure']!;
  String get recommendedCalorieIntake => _localizedValues[locale.languageCode]!['recommendedCalorieIntake']!;
  String get caloriesPerDay => _localizedValues[locale.languageCode]!['caloriesPerDay']!;
  String get dailyActivityConsumption => _localizedValues[locale.languageCode]!['dailyActivityConsumption']!;
  String get weeklyTotalConsumption => _localizedValues[locale.languageCode]!['weeklyTotalConsumption']!;
  String get calorieDataDetails => _localizedValues[locale.languageCode]!['calorieDataDetails']!;
  String get strengthTrainingConsumption => _localizedValues[locale.languageCode]!['strengthTrainingConsumption']!;
  String get aerobicConsumption => _localizedValues[locale.languageCode]!['aerobicConsumption']!;
  String get strengthTrainingDayBalance => _localizedValues[locale.languageCode]!['strengthTrainingDayBalance']!;
  String get restDayBalance => _localizedValues[locale.languageCode]!['restDayBalance']!;
  String get strengthTrainingDayShouldEat => _localizedValues[locale.languageCode]!['strengthTrainingDayShouldEat']!;
  String get restDayShouldEat => _localizedValues[locale.languageCode]!['restDayShouldEat']!;
  
  // Dashboard
  String get aiSuggestion => _localizedValues[locale.languageCode]!['aiSuggestion']!;
  String get noSuggestion => _localizedValues[locale.languageCode]!['noSuggestion']!;
  String get refreshToGetSuggestion => _localizedValues[locale.languageCode]!['refreshToGetSuggestion']!;
  String get positionSwitchInDevelopment => _localizedValues[locale.languageCode]!['positionSwitchInDevelopment']!;
  String get exerciseRecommendation => _localizedValues[locale.languageCode]!['exerciseRecommendation']!;
  String get recommendedSports => _localizedValues[locale.languageCode]!['recommendedSports']!;
  String get notRecommended => _localizedValues[locale.languageCode]!['notRecommended']!;
  String get suggestOutdoorActivity => _localizedValues[locale.languageCode]!['suggestOutdoorActivity']!;
  String get suggestIndoorActivity => _localizedValues[locale.languageCode]!['suggestIndoorActivity']!;
  String get todaySchedule => _localizedValues[locale.languageCode]!['todaySchedule']!;
  String get noScheduleToday => _localizedValues[locale.languageCode]!['noScheduleToday']!;
  String get clickToAddTask => _localizedValues[locale.languageCode]!['clickToAddTask']!;
  
  // Weather Suitability
  String get weatherSuitabilityVerySuitable => _localizedValues[locale.languageCode]!['weatherSuitabilityVerySuitable']!;
  String get weatherSuitabilitySuitable => _localizedValues[locale.languageCode]!['weatherSuitabilitySuitable']!;
  String get weatherSuitabilityModeratelySuitable => _localizedValues[locale.languageCode]!['weatherSuitabilityModeratelySuitable']!;
  String get weatherSuitabilityUnsuitable => _localizedValues[locale.languageCode]!['weatherSuitabilityUnsuitable']!;
  
  // Yoga
  String get aerobicExerciseYoga => _localizedValues[locale.languageCode]!['aerobicExerciseYoga']!;
  
  // Aerobic Exercise Habits Page
  String get aerobicHabitsTitle => _localizedValues[locale.languageCode]!['aerobicHabitsTitle']!;
  String get aerobicHabitsSectionTitle => _localizedValues[locale.languageCode]!['aerobicHabitsSectionTitle']!;
  String get aerobicHabitsDescription => _localizedValues[locale.languageCode]!['aerobicHabitsDescription']!;
  String get aerobicCategoryRunning => _localizedValues[locale.languageCode]!['aerobicCategoryRunning']!;
  String get aerobicCategoryCycling => _localizedValues[locale.languageCode]!['aerobicCategoryCycling']!;
  String get aerobicCategorySwimming => _localizedValues[locale.languageCode]!['aerobicCategorySwimming']!;
  String get aerobicCategoryBallSports => _localizedValues[locale.languageCode]!['aerobicCategoryBallSports']!;
  String get aerobicCategoryOther => _localizedValues[locale.languageCode]!['aerobicCategoryOther']!;
  String get aerobicWeeklyTime => _localizedValues[locale.languageCode]!['aerobicWeeklyTime']!;
  String get minutes => _localizedValues[locale.languageCode]!['minutes']!;
  
  // Voice Schedule
  String get customizeSchedule => _localizedValues[locale.languageCode]!['customizeSchedule']!;
  String get processingYourPlan => _localizedValues[locale.languageCode]!['processingYourPlan']!;
  String get listening => _localizedValues[locale.languageCode]!['listening']!;
  String get clickMicToSpeak => _localizedValues[locale.languageCode]!['clickMicToSpeak']!;
  String get exampleVoiceInput => _localizedValues[locale.languageCode]!['exampleVoiceInput']!;
  String get editSchedule => _localizedValues[locale.languageCode]!['editSchedule']!;
  String get health => _localizedValues[locale.languageCode]!['health']!;
  String get work => _localizedValues[locale.languageCode]!['work']!;
  String get pleaseEnterScheduleTitle => _localizedValues[locale.languageCode]!['pleaseEnterScheduleTitle']!;
  String get endTimeCannotBeEarlier => _localizedValues[locale.languageCode]!['endTimeCannotBeEarlier']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get todayStarredEvents => _localizedValues[locale.languageCode]!['todayStarredEvents']!;
  String get noStarredEventsToday => _localizedValues[locale.languageCode]!['noStarredEventsToday']!;
  
  // Clear Data
  String get clearData => _localizedValues[locale.languageCode]!['clearData']!;
  String get clearDataConfirmTitle => _localizedValues[locale.languageCode]!['clearDataConfirmTitle']!;
  String get clearDataConfirmMessage => _localizedValues[locale.languageCode]!['clearDataConfirmMessage']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get clearDataSuccess => _localizedValues[locale.languageCode]!['clearDataSuccess']!;
  String get clearDataFailed => _localizedValues[locale.languageCode]!['clearDataFailed']!;
  
  // General method to get localized string by key
  String getLocalizedString(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
