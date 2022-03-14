abstract class IDataInterval<T> {
  IDataInterval._();
  int get offset;
  int get length;

  // /// Удаляет элемент по индексу
  // void remove(int index);

  /// Опертаор наличия индекса в этом чанке
  bool operator &(int index);

  /// Опертаор получения данных по индексу из этого чанка
  T operator [](int index);

  // /// Перезапись данных по индексу в этом чанке
  // void operator []=(int index, T value);
}

abstract class IDataIntervals<T> {
  IDataIntervals._();

  /// Стрим обновления этих интервалов
  Stream<void> get updates;

  /// Зкарытие этого интервала и освобождение ресурсов
  void close();

  /// Возвращает пустой такой же экземпляр
  IDataIntervals<T> get emptyCopy;

  /// Добавляет интервал данных
  void add(IDataInterval<T> interval);

  /// Добавляет фейковый интервал данных
  void addFuture(int offset, int length);

  /// Опертаор наличия запланированного индекса в этом интервале
  bool operator |(int index);

  /// Опертаор получения данных по индексу
  T? operator [](int index);
}
