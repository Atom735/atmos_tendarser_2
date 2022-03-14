import 'package:meta/meta.dart';

@immutable
abstract class DataProviderEvent {
  const DataProviderEvent(this.ids);
  const factory DataProviderEvent.add(List<int> ids) = DataProviderEventAdd;
  const factory DataProviderEvent.delete(List<int> ids) =
      DataProviderEventDelete;
  const factory DataProviderEvent.update(List<int> ids) =
      DataProviderEventUpdate;

  final List<int> ids;

  @override
  int get hashCode => runtimeType.hashCode ^ ids.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataProviderEvent &&
        runtimeType == other.runtimeType &&
        ids == other.ids;
  }

  T? when<T>({
    T Function(DataProviderEventAdd)? add,
    T Function(DataProviderEventDelete)? delete,
    T Function(DataProviderEventUpdate)? update,
  });
}

@immutable
class DataProviderEventAdd extends DataProviderEvent {
  const DataProviderEventAdd(List<int> ids) : super(ids);

  @override
  T? when<T>({
    T Function(DataProviderEventAdd p1)? add,
    T Function(DataProviderEventDelete p1)? delete,
    T Function(DataProviderEventUpdate p1)? update,
  }) =>
      add?.call(this);
}

@immutable
class DataProviderEventDelete extends DataProviderEvent {
  const DataProviderEventDelete(List<int> ids) : super(ids);

  @override
  T? when<T>({
    T Function(DataProviderEventAdd p1)? add,
    T Function(DataProviderEventDelete p1)? delete,
    T Function(DataProviderEventUpdate p1)? update,
  }) =>
      delete?.call(this);
}

@immutable
class DataProviderEventUpdate extends DataProviderEvent {
  const DataProviderEventUpdate(List<int> ids) : super(ids);

  @override
  T? when<T>({
    T Function(DataProviderEventAdd p1)? add,
    T Function(DataProviderEventDelete p1)? delete,
    T Function(DataProviderEventUpdate p1)? update,
  }) =>
      update?.call(this);
}
