import '../common/common_web_constants.dart';
import '../data/fetching_params.dart';
import '../interfaces/i_fetching_params.dart';

const IFetchingParams kFetchingParamsEtpGpb = FetchingParams(
  1,
  WebClientMethod.get,
  r'https://etpgpb.ru/procedures/page/${{page:int}}/',
  'procedure[category]=all'
      r'&procedure[published_from]=${{date:date(dd.MM.yyyy)}}'
      r'&procedure[published_to]=${{date:date(dd.MM.yyyy)}}',
  WebContentType.unknown,
);
