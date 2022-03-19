import 'dart:async';

import '../data/data_provider_events.dart';
import 'i_data_interval.dart';
import 'i_data_search_struct.dart';

/// Интерфейс провайдера данных
/// - [T] - тип принимаемых данных
/// - [O] - тип возвращаемых данных
/// - [S] - тип данных используемых для поиска
abstract class IDataProvider<T, O extends T, S extends IDataSearchStruct> {
  IDataProvider._();

  /// Возвращает дату последней записи
  FutureOr<DateTime> getLastTimestamp();

  /// Возвращает уникальный айди рва
  FutureOr<int> getNewId();

  /// Получить данные по айди
  FutureOr<O?> getById(int id);

  /// Получить список данных по списку айди
  FutureOr<List<O>> getByIds(List<int> ids, {bool not = false});

  /// Получить интервал данных (например для синхронизации)
  IDataInterval<O> getIntervalSync(int offset, int length, DateTime timestamp);

  /// Получить интервал данных (например для отображения в списке)
  FutureOr<IDataInterval<O>> getInterval(int offset, int length, [S? search]);

  /// Вставляет данные (возвращает айди вставленой записи)
  FutureOr<int> add(T value);

  /// Вставляет список данных
  /// (возвращает айди вставленых записей)
  FutureOr<List<int>> addAll(List<T> values);

  /// Обновляет данные (возвращает айди обновлённой записи)
  FutureOr<int> update(T value);

  /// Обновляет список данных
  /// (возвращает айди Обновлённых записей)
  FutureOr<List<int>> updateAll(List<T> values);

  /// Удаляет данные по айди (возвращает флаг, были ли данные удалены)
  FutureOr<bool> deleteById(int id);

  /// Удаляет список данных по списку айди
  /// (возвращает количетсво удаленных данных)
  FutureOr<int> deleteByIds(List<int> ids);

  /// Возвращает кол-во данных на том конце
  FutureOr<int> length([S? search]);

  /// Возвращает кол-во данных на том конце
  int lengthSync(DateTime timestamp);

  /// Стрим обновлений данного провайдера
  Stream<DataProviderEvent> get updates;

  /// Название провайдера
  String get name;

  /// Инициализая провайдера
  Future<void> init();

  /// Закрытие провайдера
  Future<void> dispose();
}

/// Интерфейс синхронного провайдера данных (например для работы с бд или кешом)
/// - [T] - тип принимаемых данных
/// - [O] - тип возвращаемых данных
/// - [S] - тип данных используемых для поиска
abstract class IDataProviderSync<T, O extends T, S extends IDataSearchStruct>
    implements IDataProvider<T, O, S> {
  @override
  DateTime getLastTimestamp();
  @override
  int getNewId();
  @override
  O? getById(int id);
  @override
  List<O> getByIds(List<int> ids, {bool not = false});
  @override
  IDataInterval<O> getInterval(int offset, int length, [S? search]);
  @override
  int add(T value);
  @override
  List<int> addAll(List<T> values);
  @override
  int update(T value);
  @override
  List<int> updateAll(List<T> values);
  @override
  bool deleteById(int id);
  @override
  int deleteByIds(List<int> ids);
  @override
  int length([S? search]);
}

/// Интерфейс асинхронного провайдера данных (например для работы через сеть)
abstract class IDataProviderAsync<T, O extends T, S extends IDataSearchStruct>
    implements IDataProvider<T, O, S> {
  @override
  Future<DateTime> getLastTimestamp();
  @override
  Future<int> getNewId();
  @override
  Future<O?> getById(int id);
  @override
  Future<List<O>> getByIds(List<int> ids, {bool not = false});
  @override
  Future<IDataInterval<O>> getInterval(int offset, int length, [S? search]);
  @override
  Future<int> add(T value);
  @override
  Future<List<int>> addAll(List<T> values);
  @override
  Future<int> update(T value);
  @override
  Future<List<int>> updateAll(List<T> values);
  @override
  Future<bool> deleteById(int id);
  @override
  Future<int> deleteByIds(List<int> ids);
  @override
  Future<int> length([S? search]);
}
