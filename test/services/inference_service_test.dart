import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_coach_app/services/inference_service.dart';

void main() {
  late InferenceService inferenceService;

  setUp(() {
    inferenceService = InferenceService();
  });

  tearDown(() async {
    await inferenceService.dispose();
  });

  group('InferenceService', () {
    test('predict throws error if not initialized', () async {
      expect(
        () => inferenceService.predict('Hello'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('must be initialized'))),
      );
    });

    test('initializeModel sets initialized state and predict works', () async {
      await inferenceService.initializeModel();
      final response = await inferenceService.predict('Hello');
      expect(response, contains('Mock response for: "Hello"'));
    });

    test('dispose resets initialized state', () async {
      await inferenceService.initializeModel();
      await inferenceService.dispose();
      expect(
        () => inferenceService.predict('Hello'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('must be initialized'))),
      );
    });
  });
}