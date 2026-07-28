import 'package:flutter/material.dart';

/// Convenience accessors for the most frequently used `MediaQuery` and
/// `Theme` lookups, plus a couple of small UI helpers.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => mediaQuery.viewPadding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Rough breakpoint helpers for adaptive layouts.
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  /// Dismisses the on-screen keyboard, if any, by clearing focus.
  void hideKeyboard() => FocusScope.of(this).unfocus();

  /// Shows a simple [SnackBar] with the given [message].
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor),
      );
  }
}
