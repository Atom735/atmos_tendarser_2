// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../data/data_interval_ids.dart';
import '../data/updater_data.dart';
import '../interfaces/i_msg.dart';

/// Запрашивает список обновленных записей, начиная с какого то момента
@immutable
class MsgUpdaterGetRequest implements IMsg {
  const MsgUpdaterGetRequest(this.id, this.timestamp);

  factory MsgUpdaterGetRequest.read(BinaryReader reader) {
    final type = reader.readSize();
    assert(type == typeId, 'Not equals typeId');
    final id = reader.readSize();
    final timestamp = reader.readSize();
    return MsgUpdaterGetRequest(id, timestamp);
  }

  static const typeId = 6;

  @override
  final int id;
  final int timestamp;

  @override
  BinaryWriter write(BinaryWriter writer) => writer
    ..writeSize(typeId)
    ..writeSize(id)
    ..writeSize(timestamp);

  @override
  String toString() =>
      '''MsgUpdaterGetRequest(id: $id, timestamp: $timestamp)''';
}

/// Возвращает список данных апдейтеров
@immutable
class MsgUpdaterResponse implements IMsg {
  const MsgUpdaterResponse(this.id, this.data);

  factory MsgUpdaterResponse.read(BinaryReader reader) {
    final type = reader.readSize();
    assert(type == typeId, 'Not equals typeId');
    final id = reader.readSize();
    final data = reader.readList(UpdaterData.listReader);
    return MsgUpdaterResponse(id, data);
  }

  static const typeId = 7;

  @override
  final int id;
  final List<UpdaterData> data;

  @override
  BinaryWriter write(BinaryWriter writer) => writer
    ..writeSize(typeId)
    ..writeSize(id)
    ..writeList(data, UpdaterData.listWriter);

  @override
  String toString() => '''MsgUpdaterResponse(id: $id, data: $data)''';
}

/// Запрос на получение интервала данных
@immutable
class MsgUpdaterGetInterval implements IMsg {
  const MsgUpdaterGetInterval(
    this.id,
    this.offset,
    this.length,
    this.sort,
    this.asc,
    this.noCache,
  );

  factory MsgUpdaterGetInterval.read(BinaryReader reader) {
    final type = reader.readSize();
    assert(type == typeId, 'Not equals typeId');
    final id = reader.readSize();
    final offset = reader.readSize();
    final length = reader.readSize();
    final sort_ = reader.readSize();
    final sort = UpdaterDataSortType.values[sort_ >> 2];
    final asc = sort_ & 0x1 == 1;
    final web = sort_ & 0x2 == 2;
    return MsgUpdaterGetInterval(
      id,
      offset,
      length,
      sort,
      asc,
      web,
    );
  }

  static const typeId = 8;

  @override
  final int id;
  final int offset;
  final int length;
  final UpdaterDataSortType sort;
  final bool asc;

  /// Получить все данные сразу, так как у клиента вообще нет никаких данных
  final bool noCache;

  @override
  BinaryWriter write(BinaryWriter writer) => writer
    ..writeSize(typeId)
    ..writeSize(id)
    ..writeSize(offset)
    ..writeSize(length)
    ..writeSize((sort.index << 2) | (asc ? 1 : 0) | (noCache ? 2 : 0));

  @override
  String toString() =>
      '''MsgUpdaterGetInterval(id: $id, offset: $offset, length: $length, sort: $sort, asc: $asc, noCache: $noCache)''';
}

/// Запрос на получение интервала данных
@immutable
class MsgUpdaterInterval implements IMsg {
  const MsgUpdaterInterval(
    this.id,
    this.base,
    this.ids,
  );

  factory MsgUpdaterInterval.read(BinaryReader reader) {
    final type = reader.readSize();
    assert(type == typeId, 'Not equals typeId');
    final id = reader.readSize();
    final base = reader.readSize();
    final ids = DataIntervalIds.read(reader);
    return MsgUpdaterInterval(
      id,
      base,
      ids,
    );
  }

  static const typeId = 9;

  @override
  final int id;
  final int base;
  final DataIntervalIds ids;

  @override
  BinaryWriter write(BinaryWriter writer) {
    writer
      ..writeSize(typeId)
      ..writeSize(id)
      ..writeSize(base);
    ids.write(writer);
    return writer;
  }

  @override
  String toString() => 'MsgUpdaterInterval(id: $id, ids: $ids)';
}

@immutable
class MsgUpdaterLengthRequest implements IMsg {
  const MsgUpdaterLengthRequest(this.id);

  factory MsgUpdaterLengthRequest.read(BinaryReader reader) {
    final type = reader.readSize();
    assert(type == typeId, 'Not equals typeId');
    final id = reader.readSize();
    return MsgUpdaterLengthRequest(id);
  }

  static const typeId = 10;

  @override
  final int id;

  @override
  BinaryWriter write(BinaryWriter writer) => writer
    ..writeSize(typeId)
    ..writeSize(id);

  @override
  String toString() => 'MsgUpdaterLengthRequest(id: $id)';
}

@immutable
class MsgUpdaterLengthResponse implements IMsg {
  const MsgUpdaterLengthResponse(this.id, this.length);

  factory MsgUpdaterLengthResponse.read(BinaryReader reader) {
    final type = reader.readSize();
    assert(type == typeId, 'Not equals typeId');
    final id = reader.readSize();
    final length = reader.readSize();
    return MsgUpdaterLengthResponse(id, length);
  }

  static const typeId = 11;

  @override
  final int id;
  final int length;

  @override
  BinaryWriter write(BinaryWriter writer) => writer
    ..writeSize(typeId)
    ..writeSize(id)
    ..writeSize(length);

  @override
  String toString() => 'MsgUpdaterLengthResponse(id: $id, length: $length)';
}
