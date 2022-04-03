import 'i_fetched_data.dart';
import 'i_fetching_params.dart';

/// Интерфейс веб клиента.
abstract class IWebClient {
  /// For implement only
  IWebClient._();

  Future<void> dispose();

  /// Создаёт новую задачу и помещается её в очередь на исполнение.
  IWebClientTask createTask(IFetchingParams params);
}

/// Выполняемая задача веб клиента.
abstract class IWebClientTask {
  /// For implement only
  IWebClientTask._();

  /// Веб клиент порадивший данную задачу.
  IWebClient get webClient;

  /// Параметры запроса.
  IFetchingParams get params;

  /// Фьюча которая завершится по получению данных
  Future<IFetchedData> get done;

  /// Состояние таски
  WebClientTaskStatus get status;

  /// Стрим состояний таски (настоящее значение в [status])
  Stream<WebClientTaskStatus> get statusUpdates;

  /// Отмена таски
  void cancel();
}

enum WebClientTaskStatus {
  initializing,
  connecting,
  sending,
  waiting,
  downloading,
  done,
  error,
  canceld,
  deleted,
}
