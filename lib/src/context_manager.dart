import 'package:flutter/material.dart';

class ContextManager {
  static final GlobalKey rootWrapperKey = GlobalKey();

  // 3. The public getter to fetch the context anywhere
  static BuildContext get context {
    final BuildContext? currentContext = rootWrapperKey.currentContext;

    if (currentContext == null) {
      throw FlutterError(
        'MyPackage error: Context is null. '
        'Did you forget to add MyPackage.builder to your MaterialApp?',
      );
    }

    return currentContext;
  }
}
