import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:life_fit/src/core/services/voice_recognition_service_enhanced.dart';

// Mock classes
class MockSpeechToText extends Mock implements SpeechToText {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  group('VoiceRecognitionService', () {
    late VoiceRecognitionService service;

    setUp(() {
      service = VoiceRecognitionService();
    });

    test('initialization should be false by default', () {
      expect(service.isAvailable, false);
    });

    test('default locale should be zh_CN', () {
      expect(service.currentLocale, 'zh_CN');
    });

    test('default recognition mode should be precise', () {
      expect(service.recognitionMode, RecognitionMode.precise);
    });

    test('setLocale should update current locale', () {
      const newLocale = 'en_US';
      service.setLocale(newLocale);
      expect(service.currentLocale, newLocale);
    });

    test('setRecognitionMode should update recognition mode', () {
      service.setRecognitionMode(RecognitionMode.general);
      expect(service.recognitionMode, RecognitionMode.general);
    });

    test('availableLocales should be empty initially', () {
      expect(service.availableLocales, isEmpty);
    });

    test('soundLevel should be 0.0 initially', () {
      expect(service.soundLevel, 0.0);
    });

    test('isListening should be false initially', () {
      expect(service.isListening, false);
    });

    test('lastWords should be empty initially', () {
      expect(service.lastWords, '');
    });

    test('confidence should be 0.0 initially', () {
      expect(service.confidence, 0.0);
    });

    // Integration tests would require platform-specific setup
    // These are basic unit tests to verify the service structure
  });

  group('RecognitionMode', () {
    test('should have precise and general modes', () {
      expect(RecognitionMode.values.length, 2);
      expect(RecognitionMode.values.contains(RecognitionMode.precise), true);
      expect(RecognitionMode.values.contains(RecognitionMode.general), true);
    });
  });

  group('RecognitionStatus', () {
    test('should have all required statuses', () {
      expect(RecognitionStatus.values.length, 6);
      expect(RecognitionStatus.values.contains(RecognitionStatus.idle), true);
      expect(
        RecognitionStatus.values.contains(RecognitionStatus.initializing),
        true,
      );
      expect(
        RecognitionStatus.values.contains(RecognitionStatus.listening),
        true,
      );
      expect(
        RecognitionStatus.values.contains(RecognitionStatus.processing),
        true,
      );
      expect(
        RecognitionStatus.values.contains(RecognitionStatus.completed),
        true,
      );
      expect(RecognitionStatus.values.contains(RecognitionStatus.error), true);
    });
  });
}
