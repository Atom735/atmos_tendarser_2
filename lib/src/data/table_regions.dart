import 'package:meta/meta.dart';

import '../database/database_column.dart';
import '../database/database_column_ref.dart';
import '../database/database_table.dart';
import 'dto_ref.dart';
import 'dto_string.dart';
import 'table_tender_data.dart';

@immutable
class TableRegions extends DatabaseTable<DtoString> {
  @literal
  const TableRegions();

  @override
  String get name => 'Regions';

  @override
  DatabaseColumn get columnSync => const DatabaseColumnId();

  @override
  List<DatabaseColumn> get columns => const [
        DatabaseColumnId('regionId'),
        DatabaseColumnString('name', fts: true, unique: true, indexed: true),
      ];

  @override
  DtoString dartDecode(List value) => DtoString(
        value[0],
        value[1],
      );

  @override
  List dartEncode(DtoString value) => [
        value.id,
        value.value,
      ];
}

@immutable
class TableRegionsRefs extends DatabaseTable<DtoRef> {
  @literal
  const TableRegionsRefs();

  @override
  String get name => 'RegionsRefs';

  @override
  DatabaseColumn get columnSync => const DatabaseColumnId();

  @override
  List<DatabaseColumn> get columns => const [
        DatabaseColumnId(),
        DatabaseColumnRef('tenderIdRef', TableTenderData()),
        DatabaseColumnRef('regionIdRef', TableRegions()),
      ];

  @override
  DtoRef dartDecode(List value) => DtoRef(
        value[0],
        value[1],
        value[2],
      );

  @override
  List dartEncode(DtoRef value) => [
        value.id,
        value.idA,
        value.idB,
      ];
}
