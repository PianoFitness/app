import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/validation_error.dart";

void main() {
  group("ValidationError", () {
    test("toString with field", () {
      final error = ValidationError("Invalid value", field: "key");
      expect(error.toString(), "ValidationError(key: Invalid value)");
    });

    test("toString without field", () {
      final error = ValidationError("Missing value");
      expect(error.toString(), "ValidationError(Missing value)");
    });
  });
}
