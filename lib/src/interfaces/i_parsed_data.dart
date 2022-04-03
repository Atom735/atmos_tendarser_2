import '../common/common_stop_watch_ticks.dart';
import 'i_fetched_data.dart';

abstract class IParsedData<T> {
  /// For implement only
  IParsedData._();

  /// Полученные данные свзяанные с этими разобранными данными
  IFetchedData get fetched;

  /// Время разбора сырых байт (Преобразование байт в DOM или в JSON)
  StopWatchTicks get tDeserialization;

  /// Время преобразования сырой структуры (DOM или JSON) в конкретные данные
  StopWatchTicks get tParsing;

  /// Номер разобранной страницы данных, или оффсет разобранного кол-ва данных
  int get iCurrent;

  /// Максимальная страница, или максимальное кол-во данных
  int get iMax;

  /// Список разобранных даннных
  List<T> get items;
}
