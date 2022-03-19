import 'dart:collection';

import 'package:meta/meta.dart';

@immutable
class DtoString {
  const DtoString(
    this.id,
    this.value,
  );
  const DtoString.value(
    this.value,
  ) : id = 0;

  final int id;

  final String value;

  @override
  String toString() => 'String: $id ($value)';

  static bool _setEquals(DtoString a, DtoString b) {
    if (a.id == b.id && a.id != 0) return true;
    return a.value == b.value;
  }

  static int _setHashCode(DtoString a) => a.value.hashCode;

  static Set<DtoString> createSet() => HashSet<DtoString>(
        equals: _setEquals,
        hashCode: _setHashCode,
      );

  static String selector(DtoString a) => a.value;
}
