import 'package:meta/meta.dart';

/// Пакет данных сообщающий какие последние данные имеются у обеих сторон
@immutable
class DtoDatabaseSyncData {
  const DtoDatabaseSyncData(this.companies, this.regions, this.regionsRefs,
      this.props, this.propsRefs, this.tenders);

  final int companies;
  final int regions;
  final int regionsRefs;
  final int props;
  final int propsRefs;
  final int tenders;

  @override
  String toString() => 'DtoDatabaseSyncData:'
      '\n companies   = $companies'
      '\n regions     = $regions'
      '\n regionsRefs = $regionsRefs'
      '\n props       = $props'
      '\n propsRefs   = $propsRefs'
      '\n tenders     = $tenders';
}
