import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../database/database_column.dart';

final _dict = Uint8List.fromList(File('dicts/json.bin').readAsBytesSync());

final _decoder = ZLibDecoder(
  dictionary: _dict,
  raw: true,
).fuse(const Utf8Decoder()).cast<Uint8List, String>().fuse(const JsonDecoder());

final _encoder = const JsonEncoder().fuse(const Utf8Encoder()
    .fuse(ZLibEncoder(
      memLevel: ZLibOption.maxMemLevel,
      level: ZLibOption.maxLevel,
      dictionary: _dict,
      raw: true,
    ))
    .cast<String, Uint8List>());

/// [Codec], который преобразует и сжимает JSON объекта в массив байт
@immutable
class ZLibJsonCodec extends Codec<Object?, Uint8List> {
  @literal
  const ZLibJsonCodec();

  @override
  Converter<Uint8List, Object?> get decoder => _decoder;

  @override
  Converter<Object?, Uint8List> get encoder => _encoder;
}

@immutable
class DatabaseColumnJson extends DatabaseColumnBlobBase<Object?> {
  @literal
  const DatabaseColumnJson([this.name = 'json']);

  @override
  final String name;

  @override
  Object? dartDecode(Uint8List value) => const ZLibJsonCodec().decode(value);

  @override
  Uint8List dartEncode(Object? value) => const ZLibJsonCodec().encode(value);
}
