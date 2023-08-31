import 'package:flutter/foundation.dart';

bool isSmartPhoneDevice() {
  return (defaultTargetPlatform == TargetPlatform.iOS) ||
      (defaultTargetPlatform == TargetPlatform.android);
}
