import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Fira Sans',
      // primarySwatch: Color(0xFF157380),
      primaryColor: FineTheme.palettes.primary200,
      scaffoldBackgroundColor: Color(0xFFF5F5F5),
      toggleableActiveColor: FineTheme.palettes.primary200,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: TextTheme(
          headline1: FineTheme.typograhpy.h1,
          headline2: FineTheme.typograhpy.h2,
          // headline3: kTitleTextStyle,
          // headline4: kSubtitleTextStyle,
          // headline5: kDescriptionTextStyle,
          // headline6: kSubdescriptionTextStyle,
          subtitle1: FineTheme.typograhpy.subtitle1,
          subtitle2: FineTheme.typograhpy.h2),
    );
  }
}

// TODO: Setup design system (constants)
// TODO: Map to theme data