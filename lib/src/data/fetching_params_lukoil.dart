import '../common/common_web_constants.dart';
import '../interfaces/i_fetching_params.dart';
import 'fetching_params.dart';

const IFetchingParams kFetchingParamsLukOil = FetchingParams(
  3,
  WebClientMethod.post,
  'https://lukoil.ru/api/tenders/GetTenders',
  r'Take=${{take:int}}&Tab=${{tab:[1,4]}}&Skip=${{skip:int}}',
  WebContentType.url,
);
