import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import '../interfaces/i_data_interval.dart';

/// Интервал данных используется для отображения в списках
@immutable
class DataInterval<T> implements IDataInterval<T> {
  const DataInterval(this.offset, this._data);

  final List<T> _data;
  @override
  final int offset;
  @override
  int get length => _data.length;

  @override
  bool operator &(int index) => index >= offset && index < offset + length;

  @override
  T operator [](int index) => _data[index - offset];

  @override
  String toString() => '$offset:${_data.length}';
}

@immutable
class DataIntervalFictive<T> implements IDataInterval<T> {
  const DataIntervalFictive(this.offset, this.length);

  @override
  final int offset;
  @override
  final int length;

  @override
  bool operator &(int index) => index >= offset && index < offset + length;

  @override
  T operator [](int index) => throw UnimplementedError();

  @override
  String toString() => 'Ficitve $offset:$length';
}

@immutable
class DataIntervals<T> implements IDataIntervals<T> {
  DataIntervals();

  /// Карта интервалов, где ключ - offset
  final intervals = SplayTreeSet<IDataInterval<T>>(_intervalComparator);

  static int _intervalComparator<T>(
      IDataInterval<T> key1, IDataInterval<T> key2) {
    if (key1 & key2.offset) return 0;
    return key1.offset - key2.offset;
  }

  /// Карта интервалов, где ключ - offset
  final intervalsFuture =
      SplayTreeSet<MapEntry<int, int>>(_intervalFutureComparator);

  static int _intervalFutureComparator(
      MapEntry<int, int> key1, MapEntry<int, int> key2) {
    if (key2.key >= key1.key && key2.key < key1.key + key1.value) return 0;
    return key1.key - key2.key;
  }

  IDataInterval<T>? intervalSearch(int index) =>
      intervals.lookup(DataIntervalFictive<T>(index, 0));

  final _controller = StreamController<void>.broadcast(sync: true);

  @override
  Stream<void> get updates => _controller.stream;

  @override
  void close() => _controller.close();

  @override
  IDataIntervals<T> get emptyCopy => DataIntervals<T>();

  @override
  void add(IDataInterval<T> interval, [bool notify = true]) {
    intervals.add(interval);
    if (!_controller.isClosed && notify) {
      _controller.add(null);
    }
  }

  @override
  void addFuture(int offset, int length) =>
      intervalsFuture.add(MapEntry(offset, length));

  @override
  T? operator [](int index) => intervalSearch(index)?[index];

  @override
  bool operator |(int index) =>
      intervalsFuture.lookup(MapEntry(index, 0)) != null;
}
