/// Extension for string first character uppercase operations.
extension StringFirstCharUpperCase on String {
  /// Returns the string with the first character uppercased.
  String replaceFirstCharUpperCase() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}