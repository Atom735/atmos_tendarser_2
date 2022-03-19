import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../data/dto_company.dart';
import '../data/dto_ref.dart';
import '../data/dto_string.dart';
import '../data/dto_tender_data.dart';
import '../data/table_companies.dart';
import '../data/table_regions.dart';
import '../data/table_tender_data.dart';
import '../data/table_tender_props.dart';
import '../interfaces/i_msg.dart';

/// Пакет данных показывающий какие данные уже имеются у сторон
@immutable
class MsgSyncDataFrame implements IMsg {
  const MsgSyncDataFrame(this.id, this.companies, this.regions,
      this.regionsRefs, this.props, this.propsRefs, this.tenders);

  factory MsgSyncDataFrame.decode(Uint8List data) {
    final reader = BinaryReader(data);
    final type = reader.readSize();
    if (type != typeId) {
      throw Exception('Untyped msg');
    }
    final id = reader.readSize();
    final companies = tableCompanies.msgDartReadList(reader);
    final regions = tableRegions.msgDartReadList(reader);
    final regionsRefs = tableRegionsRefs.msgDartReadList(reader);
    final props = tableProps.msgDartReadList(reader);
    final propsRefs = tablePropsRefs.msgDartReadList(reader);
    final tenders = tableTenders.msgDartReadList(reader);
    return MsgSyncDataFrame(
        id, companies, regions, regionsRefs, props, propsRefs, tenders);
  }

  static const typeId = 7;

  static const tableCompanies = TableCompanies();
  static const tableRegions = TableRegions();
  static const tableRegionsRefs = TableRegionsRefs();
  static const tableProps = TableProps();
  static const tablePropsRefs = TablePropsRefs();
  static const tableTenders = TableTenderData();

  @override
  final int id;
  final List<DtoCompany> companies;
  final List<DtoString> regions;
  final List<DtoString> props;
  final List<DtoTenderData> tenders;
  final List<DtoRef> regionsRefs;
  final List<DtoRef> propsRefs;

  @override
  Uint8List get toBytes {
    final writer = BinaryWriter()
      ..writeSize(typeId)
      ..writeSize(id);
    tableCompanies.msgDartWriteList(companies, writer);
    tableRegions.msgDartWriteList(regions, writer);
    tableRegionsRefs.msgDartWriteList(regionsRefs, writer);
    tableProps.msgDartWriteList(props, writer);
    tablePropsRefs.msgDartWriteList(propsRefs, writer);
    tableTenders.msgDartWriteList(tenders, writer);
    return writer.takeBytes();
  }

  @override
  String toString() => 'MsgSyncDataFrame($id)'
      '\n companies   = ${companies.length}'
      '\n regions     = ${regions.length}'
      '\n regionsRefs = ${regionsRefs.length}'
      '\n props       = ${props.length}'
      '\n propsRefs   = ${propsRefs.length}'
      '\n tenders     = ${tenders.length}';
}
