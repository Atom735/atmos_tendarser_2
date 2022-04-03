import 'i_fetched_data.dart';
import 'i_parsed_data.dart';

abstract class IParser<T> {
  /// For implement only
  IParser._();

  bool canParse(IFetchedData fetched);
  IParsedData<T> parse(IFetchedData fetched);
}
