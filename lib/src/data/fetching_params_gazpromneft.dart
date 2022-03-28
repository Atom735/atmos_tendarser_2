import '../common/common_web_constants.dart';
import '../interfaces/i_fetching_params.dart';
import 'fetching_params.dart';

const IFetchingParams kFetchingParamsGazPromNeft = FetchingParams(
  2,
  WebClientMethod.get,
  'https://zakupki.gazprom-neft.ru/tenderix/index.php',
  'FILTER[STATE]=ALL'
      '&FILTER[SORT]=DATE_START_DESC'
      '&LIMIT=100'
      r'&PAGE=${{page:int}}',
  WebContentType.unknown,
);
