import 'package:atmos_database/atmos_database.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

@immutable
class DataCompany implements Comparable<DataCompany> {
  const DataCompany(this.id, this.name, this.logo);
  const DataCompany.v(this.name, this.logo) : id = 0;

  /// Айди записи
  final int id;

  /// Название компании
  final String name;

  /// Ссылка на логотип
  final String logo;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataCompany &&
        other.id == id &&
        other.name == name &&
        other.logo == logo;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ logo.hashCode;

  @override
  int compareTo(DataCompany other) => name.compareTo(other.name);

  @override
  String toString() => 'CompanyData(id: $id, name: $name, logo: $logo)';
}

class TableDataCompany extends DatabaseTable<DataCompany> {
  const TableDataCompany(Database sql) : super(sql, kTableName, kColumns);

  static const kTableName = 'Companies';
  static const kColumns = <DatabaseColumn>[
    kColumnId,
    kColumnName,
    kColumnLogo,
  ];
  static const kColumnId = DatabaseColumnId('companyId');
  static const kColumnName = DatabaseColumnText(
    'companyName',
    unique: true,
    indexed: true,
    fts: true,
  );
  static const kColumnLogo = DatabaseColumnText('companyLogo');

  DatabaseColumnText get vColumnName => kColumnName;

  @override
  List dartDecode(DataCompany value) => [
        value.id,
        value.name,
        value.logo,
      ];

  @override
  DataCompany dartEncode(List value) =>
      DataCompany(value[0], value[1], value[2]);
}
