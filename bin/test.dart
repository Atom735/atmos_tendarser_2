import 'package:atmos_tendarser_2/src/messages/msg_db_get_interval_ids.dart';

void main(List<String> args) {
  final ids = MsgDbIntevalsIdsData.e1([1, 2, 3, 4, 5, 6]);
  print(ids.decodedNums);
  final contained = MsgDbIntevalsIdsData.e1([6, 2, 3, 4]);
  print(contained.decodedNums);
  final diff = ids.getDiff(contained);
  print(diff);

  final cc = MsgDbIntevalsIdsData.e2([1, 2, 4, 5], ids);
  print(cc.decodedNums);
}
