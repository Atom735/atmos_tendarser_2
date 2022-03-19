import 'dart:collection';

import 'package:meta/meta.dart';

@immutable
class DtoRef {
  const DtoRef(
    this.id,
    this.idA,
    this.idB,
  )   : assert(idA > 0, 'invalid idA'),
        assert(idB > 0, 'invalid idB');
  const DtoRef.value(
    this.idA,
    this.idB,
  )   : id = 0,
        assert(idA > 0, 'invalid idA'),
        assert(idB > 0, 'invalid idB');

  final int id;

  final int idA;

  final int idB;

  @override
  String toString() => 'Ref: $id ($idA - $idB)';

  static bool _setEquals(DtoRef a, DtoRef b) {
    if (a.id == b.id && a.id != 0) return true;
    return a.idA == b.idA && a.idB == b.idB;
  }

  static int _setHashCode(DtoRef a) => a.idA ^ a.idB;

  static Set<DtoRef> createSet() => HashSet<DtoRef>(
        equals: _setEquals,
        hashCode: _setHashCode,
      );

  static int getIdA(DtoRef a) => a.idA;
  static int getIdB(DtoRef a) => a.idB;

  static const Map<int, int Function(DtoRef e)> selectors = {
    1: getIdA,
    2: getIdB,
  };
}
