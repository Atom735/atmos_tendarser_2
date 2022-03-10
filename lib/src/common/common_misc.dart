import 'dart:typed_data';

void kVoidFunc() {}

int searchSublistBytes(
  Uint8List data,
  Uint8List search, [
  int limit = -1,
  int offset = 0,
]) {
  final l = data.length;
  if (limit < 0) {
    limit = l;
  }
  final sl = search.length;
  outer:
  for (var i = 0; i < limit; i++) {
    for (var j = 0; j < sl; j++) {
      if (i + j + offset >= l) return -1;
      if (search[j] != data[i + j + offset]) continue outer;
    }
    return i + offset;
  }
  return -1;
}
