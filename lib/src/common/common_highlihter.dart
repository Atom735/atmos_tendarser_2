import 'package:atmos_database/atmos_database.dart';
import 'package:flutter/widgets.dart';

List<TextSpan> highlightText(String text, TextStyle style) {
  final ss = highlightSeparateText(text);
  final spans = <TextSpan>[];
  for (var i = 0; i < ss.length; i++) {
    if (i.isOdd) {
      spans.add(TextSpan(text: ss[i]));
    } else {
      spans.add(TextSpan(text: ss[i], style: style));
    }
  }
  return spans;
}
