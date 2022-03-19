import 'dart:collection';

import 'package:meta/meta.dart';

@immutable
class DtoCompany {
  const DtoCompany(
    this.id,
    this.name,
    this.logo,
  );

  final int id;

  final String name;

  final String logo;

  @override
  String toString() => 'Company: $id ($name)';

  static bool _setEquals(DtoCompany a, DtoCompany b) {
    if (a.id == b.id && a.id != 0) return true;
    return a.name == b.name;
  }

  static int _setHashCode(DtoCompany a) => a.name.hashCode;

  static Set<DtoCompany> createSet() => HashSet<DtoCompany>(
        equals: _setEquals,
        hashCode: _setHashCode,
      );

  static String selector(DtoCompany a) => a.name;
}
