// A sealed Result type for functional error handling in Dart.
// Usage: Result<T, E> where T is success type, E is error type.

sealed class Result<T, E> {
  const Result();

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  Success<T, E>? get asSuccess =>
      this is Success<T, E> ? this as Success<T, E> : null;
  Failure<T, E>? get asFailure =>
      this is Failure<T, E> ? this as Failure<T, E> : null;

  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) {
    if (this is Success<T, E>) {
      return success((this as Success<T, E>).value);
    } else if (this is Failure<T, E>) {
      return failure((this as Failure<T, E>).error);
    } else {
      throw StateError("Invalid Result state");
    }
  }
}

class Success<T, E> extends Result<T, E> {
  const Success(this.value);
  final T value;
}

class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);
  final E error;
}
