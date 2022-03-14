abstract class IDataSearchStruct {
  IDataSearchStruct._();

  /// Текст поиска
  String? get text;

  /// Необходимо ли подсветить найденные данные
  bool get textHighlights;

  /// Номер столбца по которому идёт сортировка (-1 для поиска по рангу)
  int get orderColumn;

  /// Порядок сортировки (по возрастанию)
  bool get orderAsc;
}
