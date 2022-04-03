import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

import '../interfaces/i_writable.dart';

enum DataIntervalIdsType {
  /// Список айди пристусвующих на стороне
  contained,

  /// Список айди пристусвующих на стороне
  /// парами типа offset-length, где оффсет опорный rowid,
  /// а length длина последовательных айдишек
  containedI,

  /// Список айди отсутсвующих на стороне
  unknowed,

  /// Список айди отсутсвующих на стороне
  /// парами типа offset-length, где оффсет опорный rowid,
  /// а length длина последовательных айдишек
  unknowedI,
}

/// Числа отображающие список айдишек
class DataIntervalIds implements IWritable {
  DataIntervalIds(this.type, this.nums);

  /// Чтение данных с ридера
  factory DataIntervalIds.read(BinaryReader reader) {
    final type = DataIntervalIdsType.values[reader.readSize()];
    final nums = reader.readListSize();
    return DataIntervalIds(type, nums);
  }

  /// Подготовка чисел из имеющихся данных айдишек
  factory DataIntervalIds.e1(List<int> ids, [bool sort = true]) {
    if (sort) {
      ids = ids.toList()..sort();
    }
    final idsb = encode(ids);
    final w1 = (BinaryWriter()..writeListSize(ids)).length;
    final w2 = (BinaryWriter()..writeListSize(idsb)).length;
    if (w1 > w2) {
      return DataIntervalIds(DataIntervalIdsType.containedI, idsb);
    }
    return DataIntervalIds(DataIntervalIdsType.contained, ids);
  }

  /// Подготовка чисел из [ids] имеющихся у клиента и [c] имеющихся у сервера
  factory DataIntervalIds.e2(List<int> ids, DataIntervalIds c) {
    final contained = DataIntervalIds.e1(ids);
    final diff = DataIntervalIds.e1(c.getDiff(contained));
    final w1 = (BinaryWriter()..writeListSize(contained.nums)).length;
    final w2 = (BinaryWriter()..writeListSize(diff.nums)).length;
    if (w1 > w2) {
      if (diff.type == DataIntervalIdsType.containedI) {
        return DataIntervalIds(DataIntervalIdsType.unknowedI, diff.nums);
      }
      return DataIntervalIds(DataIntervalIdsType.unknowed, diff.nums);
    }
    return contained;
  }

  final DataIntervalIdsType type;
  final List<int> nums;

  /// Упаковывает список айди в интервальное представление (id,length)
  ///
  /// Желательно предвартильно отсортировать список в порядке возврастания
  static List<int> encode(List<int> ids) {
    if (ids.isEmpty) return ids;
    final o = <int>[ids.first];
    var i0 = 0;
    for (var i = 1; i < ids.length; i++) {
      if (ids[i] != ids[i - 1] + 1) {
        o
          ..add(i - i0)
          ..add(ids[i]);
        i0 = i;
      }
    }
    o.add(ids.length - i0);
    return o;
  }

  List<int> decodedNums([int base = 0]) {
    final o = <int>[];
    switch (type) {
      case DataIntervalIdsType.contained:
      case DataIntervalIdsType.unknowed:
        return nums.map((e) => e + base).toList();
      case DataIntervalIdsType.containedI:
      case DataIntervalIdsType.unknowedI:
        for (var i = 0; i < nums.length ~/ 2; i++) {
          final offset = nums[i * 2 + 0] + base;
          final length = nums[i * 2 + 1];
          o.addAll(Iterable.generate(length, (j) => j + offset));
        }
        return o;
    }
  }

  @override
  BinaryWriter write(BinaryWriter writer) => writer
    ..writeSize(type.index)
    ..writeListSize(nums);

  List<int> getDiff(DataIntervalIds r) {
    final d = r.decodedNums();
    switch (r.type) {
      case DataIntervalIdsType.contained:
      case DataIntervalIdsType.containedI:
        return decodedNums()..removeWhere(d.contains);
      case DataIntervalIdsType.unknowed:
      case DataIntervalIdsType.unknowedI:
        return d;
    }
  }
}
