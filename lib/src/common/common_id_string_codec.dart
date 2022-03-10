library common.id_string_codec;

import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

part 'common_id_string_codec.data.dart';

/// [Codec], который преобразует айди в строку и наоборот
@immutable
class IdStringCodec extends Codec<int, String> {
  @literal
  const IdStringCodec();

  @override
  Converter<String, int> get decoder => const IdStringDecoder();

  @override
  Converter<int, String> get encoder => const IdStringEncoder();
}

@immutable
class IdStringEncoder extends Converter<int, String> {
  @literal
  const IdStringEncoder();
  @override
  String convert(int input) {
    final buf = Uint8List(32);
    var i = 0;
    while (input > 0) {
      buf[i] = _dictEncode[input % _dictLen];
      input = input ~/ _dictLen;
      i++;
    }
    return String.fromCharCodes(buf, 0, i);
  }
}

@immutable
class IdStringDecoder extends Converter<String, int> {
  @literal
  const IdStringDecoder();
  @override
  int convert(String input) {
    final buf = input.codeUnits;
    var res = 0;
    var mul = 1;
    for (var i = 0; i < buf.length; i++) {
      res += _dictDecode[buf[i]] * mul;
      mul *= _dictLen;
    }
    return res;
  }
}
