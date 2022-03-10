import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'common_db_column.dart';

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
class DbColumnContent extends CommonDbColumnBlob<Uint8List> {
  @literal
  const DbColumnContent([this.name = 'content']);

  @override
  final String name;

  @override
  Uint8List decode(Uint8List value) => const ZLibContentCodec().decode(value);

  @override
  Uint8List encode(Uint8List value) => const ZLibContentCodec().encode(value);
}
