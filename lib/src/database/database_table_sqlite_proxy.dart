import 'database_table.dart';
import 'database_table_proxy_mixin.dart';
import 'database_table_sqlite_mixin.dart';
import 'database_table_sync_sqlite_mixin.dart';

class DatabaseTableSqliteProxy<T> extends DatabaseTable<T>
    with
        DatabaseTableProxyMixin<T>,
        DatabaseTableSqliteMixin<T>,
        DatabaseTableSyncSqliteMixin<T> {
  DatabaseTableSqliteProxy(this.origin);

  @override
  final DatabaseTable<T> origin;
}
