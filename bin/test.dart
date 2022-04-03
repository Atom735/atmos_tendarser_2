import 'package:atmos_tendarser_2/src/messages/msg_db_get_interval_ids.dart';

void main(List<String> args) {
  final ids = DataIntervalIds.e1([1, 2, 3, 4, 5, 6]);
  print(ids.decodedNums);
  final contained = DataIntervalIds.e1([6, 2, 3, 4]);
  print(contained.decodedNums);
  final diff = ids.getDiff(contained);
  print(diff);

  final cc = DataIntervalIds.e2([1, 2, 4, 5], ids);
  print(cc.decodedNums);
}
