import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'theme_color_sheme.dart';

final themeTypography =
    Typography.material2018(platform: defaultTargetPlatform);

const themePageTransitions = PageTransitionsTheme(builders: {
  TargetPlatform.windows: ZoomPageTransitionsBuilder(),
});

const themeDivider = DividerThemeData(
  indent: 0,
  endIndent: 0,
  thickness: 0,
  space: 0,
);

const themeScrollbar = ScrollbarThemeData(
  crossAxisMargin: 0,
  interactive: true,
  isAlwaysShown: true,
  mainAxisMargin: 0,
  minThumbLength: 32,
  radius: Radius.zero,
  showTrackOnHover: true,
);

final themeDarkFull = ThemeData.from(
  colorScheme: colorSchemeDark,
  textTheme: themeTypography.white,
).copyWith(
  typography: themeTypography,
  dividerTheme: themeDivider,
  scrollbarTheme: themeScrollbar,
  pageTransitionsTheme: themePageTransitions,
);

final themeLightFull = ThemeData.from(
  colorScheme: colorSchemeLight,
  textTheme: themeTypography.black,
).copyWith(
  typography: themeTypography,
  dividerTheme: themeDivider,
  scrollbarTheme: themeScrollbar,
  pageTransitionsTheme: themePageTransitions,
);
