import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

import '../../interfaces/i_writable.dart';
import '../data_interval_ids.dart';

class DataIntervalTendersEtpGpb implements IWritable {
  DataIntervalTendersEtpGpb(this.tenders, this.companies, this.regions,
      this.props, this.regionsRefs, this.propsRefs);

  factory DataIntervalTendersEtpGpb.read(BinaryReader reader) {
    final tenders = DataIntervalIds.read(reader);
    final companies = DataIntervalIds.read(reader);
    final regions = DataIntervalIds.read(reader);
    final props = DataIntervalIds.read(reader);
    final regionsRefs = DataIntervalIds.read(reader);
    final propsRefs = DataIntervalIds.read(reader);
    return DataIntervalTendersEtpGpb(
      tenders,
      companies,
      regions,
      props,
      regionsRefs,
      propsRefs,
    );
  }

  final DataIntervalIds tenders;
  final DataIntervalIds companies;
  final DataIntervalIds regions;
  final DataIntervalIds props;
  final DataIntervalIds regionsRefs;
  final DataIntervalIds propsRefs;

  @override
  BinaryWriter write(BinaryWriter writer) {
    tenders.write(writer);
    companies.write(writer);
    regions.write(writer);
    props.write(writer);
    regionsRefs.write(writer);
    propsRefs.write(writer);
    return writer;
  }
}
