import '../interfaces/i_data_search_struct.dart';

abstract class DataSearchStruct implements IDataSearchStruct {
  @override
  String? text;

  @override
  bool textHighlights = true;

  @override
  int orderColumn = -1;

  @override
  bool orderAsc = true;
}
