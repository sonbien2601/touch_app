import 'package:flutter/cupertino.dart';

final class AppTheme {
  static CupertinoThemeData cupertinoTheme() {
    return const CupertinoThemeData(
      primaryColor: CupertinoColors.systemPink,
      scaffoldBackgroundColor: CupertinoColors.systemBackground,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        navLargeTitleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
