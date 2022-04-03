import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'theme_color_sheme.dart';

final kThemeTypography =
    Typography.material2018(platform: defaultTargetPlatform);

const kThemePageTransitions = PageTransitionsTheme(builders: {
  TargetPlatform.windows: ZoomPageTransitionsBuilder(),
});

const kThemeDivider = DividerThemeData(
  indent: 0,
  endIndent: 0,
  thickness: 0,
  space: 0,
);

const kThemeScrollbar = ScrollbarThemeData(
  crossAxisMargin: 0,
  interactive: true,
  isAlwaysShown: true,
  mainAxisMargin: 0,
  minThumbLength: 32,
  radius: Radius.zero,
  showTrackOnHover: true,
);

final themeDataDark = ThemeData.from(
  colorScheme: kThemeColorSchemeDark,
  textTheme: kThemeTypography.white,
).copyWith(
  typography: kThemeTypography,
  dividerTheme: kThemeDivider,
  scrollbarTheme: kThemeScrollbar,
  pageTransitionsTheme: kThemePageTransitions,
);

final themeDataLight = ThemeData.from(
  colorScheme: kThemeColorSchemeLight,
  textTheme: kThemeTypography.black,
).copyWith(
  typography: kThemeTypography,
  dividerTheme: kThemeDivider,
  scrollbarTheme: kThemeScrollbar,
  pageTransitionsTheme: kThemePageTransitions,
);
