/// Common string utilities used across the app.
extension StringExtensions on String {
  /// Whether the string is empty once surrounding whitespace is removed.
  bool get isBlank => trim().isEmpty;

  /// Whether the string contains non-whitespace characters.
  bool get isNotBlank => !isBlank;

  /// Returns `null` if the string is blank, otherwise the string itself.
  String? get orNullIfBlank => isBlank ? null : this;

  /// Capitalizes only the first letter, leaving the rest untouched.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// A conservative RFC 5322-ish check, good enough for client-side validation.
  bool get isValidEmail =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(trim());

  /// Requires at least 8 characters with one letter and one digit.
  bool get isValidPassword =>
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(this);

  /// Basic E.164-ish phone validation (7-15 digits, optional leading `+`).
  bool get isValidPhoneNumber => RegExp(r'^\+?[0-9]{7,15}$').hasMatch(trim());

  /// Truncates to [maxLength] characters, appending [suffix] if truncated.
  String truncate(int maxLength, {String suffix = '…'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$suffix';

  /// Removes all whitespace characters from the string.
  String get removeAllWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Parses the string as an `int`, returning `null` on failure.
  int? get toIntOrNull => int.tryParse(this);

  /// Parses the string as a `double`, returning `null` on failure.
  double? get toDoubleOrNull => double.tryParse(this);
}
