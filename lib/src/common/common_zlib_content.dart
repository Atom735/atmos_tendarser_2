import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:atmos_database/atmos_database.dart';
import 'package:meta/meta.dart';

final _dict = Uint8List.fromList(File('dicts/content.bin').readAsBytesSync());

final _decoder = ZLibDecoder(
  dictionary: _dict,
  raw: true,
).cast<Uint8List, Uint8List>();

final _encoder = ZLibEncoder(
  memLevel: ZLibOption.maxMemLevel,
  level: ZLibOption.maxLevel,
  dictionary: _dict,
  raw: true,
).cast<Uint8List, Uint8List>();

/// [Codec], который преобразует и сжимает байты данных документа в массив байт
@immutable
class ZLibContentCodec extends Codec<Uint8List, Uint8List> {
  @literal
  const ZLibContentCodec();

  @override
  Converter<Uint8List, Uint8List> get decoder => _decoder;

  @override
  Converter<Uint8List, Uint8List> get encoder => _encoder;
}

@immutable
class DatabaseColumnContent extends DatabaseColumnBlobBase<Uint8List> {
  @literal
  const DatabaseColumnContent([String name = 'content']) : super(name);

  @override
  Uint8List dartEncode(Uint8List value) =>
      const ZLibContentCodec().decode(value);

  @override
  Uint8List dartDecode(Uint8List value) =>
      const ZLibContentCodec().encode(value);
}
