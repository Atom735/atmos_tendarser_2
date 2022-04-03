import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

abstract class IWritable {
  /// For implement only
  IWritable._();

  BinaryWriter write(BinaryWriter writer);
}
