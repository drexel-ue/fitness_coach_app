/// Extension for null-safe firstWhere operations on iterables.
extension IterableExtensions<T> on Iterable<T> {
  /// Returns the first element that satisfies the test function, or null if no such element exists.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}