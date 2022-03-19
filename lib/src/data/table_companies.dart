import 'package:meta/meta.dart';

import '../database/database_column.dart';
import '../database/database_table.dart';
import 'dto_company.dart';

@immutable
class TableCompanies extends DatabaseTable<DtoCompany> {
  @literal
  const TableCompanies();

  @override
  String get name => 'Companies';

  @override
  DatabaseColumn get columnSync => const DatabaseColumnId();

  @override
  List<DatabaseColumn> get columns => const [
        DatabaseColumnId('companyId'),
        DatabaseColumnString('name', fts: true, unique: true, indexed: true),
        DatabaseColumnString('logo'),
      ];

  @override
  DtoCompany dartDecode(List value) => DtoCompany(
        value[0],
        value[1],
        value[2],
      );

  @override
  List dartEncode(DtoCompany value) => [
        value.id,
        value.name,
        value.logo,
      ];
}
