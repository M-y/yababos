import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yababos/generated/l10n.dart';

class L10nHelper {
  static S? _l10nInstance;

  /// Builds widget with localizations
  static Widget build(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      home: child,
    );
  }

  /// Gets Localizations Instance
  static S getLocalizations() {
    if (_l10nInstance != null) return _l10nInstance!;

    S result = new S();
    _l10nInstance = result;
    return result;
  }
}
