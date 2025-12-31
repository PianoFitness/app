import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/result.dart";

void main() {
  group("Result", () {
    test("Success returns correct value", () {
      final result = Success<int, String>(42);
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.asSuccess?.value, 42);
      expect(result.asFailure, isNull);
    });

    test("Failure returns correct error", () {
      final result = Failure<int, String>("error");
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.asSuccess, isNull);
      expect(result.asFailure?.error, "error");
    });

    test("when returns correct branch", () {
      final success = Success<int, String>(7);
      final failure = Failure<int, String>("fail");
      expect(success.when(success: (v) => v * 2, failure: (e) => -1), 14);
      expect(failure.when(success: (v) => v * 2, failure: (e) => -1), -1);
    });
  });
}
