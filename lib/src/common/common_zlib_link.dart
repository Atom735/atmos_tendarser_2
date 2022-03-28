import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:atmos_database/atmos_database.dart';
import 'package:meta/meta.dart';

final _dict = Uint8List.fromList(File('dicts/link.bin').readAsBytesSync());

final _decoder = ZLibDecoder(
  dictionary: _dict,
  raw: true,
).fuse(const Utf8Decoder()).cast<Uint8List, String>();
final _encoder = const Utf8Encoder()
    .fuse(ZLibEncoder(
      memLevel: ZLibOption.maxMemLevel,
      level: ZLibOption.maxLevel,
      dictionary: _dict,
      raw: true,
    ))
    .cast<String, Uint8List>();

/// [Codec], который преобразует и сжимает URL - строку в массив байт
@immutable
class ZLibLinkCodec extends Codec<String, Uint8List> {
  @literal
  const ZLibLinkCodec();

  @override
  Converter<Uint8List, String> get decoder => _decoder;

  @override
  Converter<String, Uint8List> get encoder => _encoder;
}

@immutable
class DatabaseColumnLink extends DatabaseColumnBlobBase<String> {
  @literal
  const DatabaseColumnLink([String name = 'link']) : super(name);

  @override
  String dartEncode(Uint8List value) => const ZLibLinkCodec().decode(value);

  @override
  Uint8List dartDecode(String value) => const ZLibLinkCodec().encode(value);
}
