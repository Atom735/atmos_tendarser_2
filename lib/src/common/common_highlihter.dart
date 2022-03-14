import 'package:flutter/widgets.dart';

const highlightTextBegin = '\u{1}';
const highlightTextEnd = '\u{2}';

List<TextSpan> highlightText(String text, TextStyle style) {
  final spans = <TextSpan>[];
  var i0 = 0;
  while (true) {
    var i1 = text.indexOf(highlightTextBegin, i0);
    if (i1 == -1) {
      break;
    }
    spans.add(TextSpan(text: text.substring(i0, i1)));
    i1 += highlightTextBegin.length;
    final i2 = text.indexOf(highlightTextEnd, i1);
    spans.add(TextSpan(text: text.substring(i1, i2), style: style));
    i0 = i2 + highlightTextEnd.length;
  }
  spans.add(TextSpan(text: text.substring(i0)));
  return spans;
}
