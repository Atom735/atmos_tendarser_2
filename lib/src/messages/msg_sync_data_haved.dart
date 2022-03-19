import 'dart:math' show max;
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../data/dto_database_sync_data.dart';
import '../interfaces/i_msg.dart';

/// Пакет данных показывающий какие данные уже имеются у сторон
@immutable
class MsgSyncDataHaved implements IMsg {
  const MsgSyncDataHaved(this.id, this.companies, this.regions,
      this.regionsRefs, this.props, this.propsRefs, this.tenders);

  factory MsgSyncDataHaved.decode(Uint8List data) {
    final reader = BinaryReader(data);
    final type = reader.readSize();
    if (type != typeId) {
      throw Exception('Untyped msg');
    }
    final id = reader.readSize();
    final companies = reader.readListSize();
    final regions = reader.readListSize();
    final regionsRefs = reader.readListSize();
    final props = reader.readListSize();
    final propsRefs = reader.readListSize();
    final tenders = reader.readListSize();
    return MsgSyncDataHaved(
        id, companies, regions, regionsRefs, props, propsRefs, tenders);
  }

  static const typeId = 5;

  @override
  final int id;
  final List<int> companies;
  final List<int> regions;
  final List<int> regionsRefs;
  final List<int> props;
  final List<int> propsRefs;
  final List<int> tenders;

  bool get isNotEmpty =>
      companies.isNotEmpty ||
      regions.isNotEmpty ||
      regionsRefs.isNotEmpty ||
      props.isNotEmpty ||
      propsRefs.isNotEmpty ||
      tenders.isNotEmpty;

  void removeFrom(MsgSyncDataHaved s) {
    companies.removeWhere(s.companies.contains);
    regions.removeWhere(s.regions.contains);
    regionsRefs.removeWhere(s.regionsRefs.contains);
    props.removeWhere(s.props.contains);
    propsRefs.removeWhere(s.propsRefs.contains);
    tenders.removeWhere(s.tenders.contains);
  }

  @override
  Uint8List get toBytes => (BinaryWriter()
        ..writeSize(typeId)
        ..writeSize(id)
        ..writeListSize(companies)
        ..writeListSize(regions)
        ..writeListSize(regionsRefs)
        ..writeListSize(props)
        ..writeListSize(propsRefs)
        ..writeListSize(tenders))
      .takeBytes();

  DtoDatabaseSyncData get toSyncDataMax => DtoDatabaseSyncData(
        companies.fold(0, max),
        regions.fold(0, max),
        regionsRefs.fold(0, max),
        props.fold(0, max),
        propsRefs.fold(0, max),
        tenders.fold(0, max),
      );

  @override
  String toString() => 'MsgSyncDataHaved($id)'
      '\n companies   = ${companies.length}'
      '\n regions     = ${regions.length}'
      '\n regionsRefs = ${regionsRefs.length}'
      '\n props       = ${props.length}'
      '\n propsRefs   = ${propsRefs.length}'
      '\n tenders     = ${tenders.length}';
}
