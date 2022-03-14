import 'package:meta/meta.dart';

import '../common/common_web_constants.dart';
import '../interfaces/i_fetching_params.dart';

@immutable
class FetchingParams implements IFetchingParams {
  const FetchingParams(this.id, this.method, this.url, this.query, this.type);
  FetchingParams.copy(IFetchingParams v)
      : this(v.id, v.method, v.url, v.query, v.type);

  @override
  final int id;

  @override
  final WebClientMethod method;

  @override
  final String url;

  @override
  final String query;

  @override
  final WebContentType type;

  @override
  Uri get uri => IFetchingParams.uriGen(this);

  @override
  bool get isNeedData =>
      IFetchingParams.reVar.hasMatch(url) ||
      IFetchingParams.reVar.hasMatch(query);

  @override
  IFetchingParamsWithData toWithData() => FetchingParamsWithData(this);
}

@immutable
class FetchingParamsWithData implements IFetchingParamsWithData {
  FetchingParamsWithData(IFetchingParams v)
      : paramsBase = v,
        data = IFetchingParams.dataGen(v);

  String _reReplacer(Match m) => data[m[1]!] ?? '\${{${m[1]!}}}';

  @override
  int get id => paramsBase.id;

  @override
  WebClientMethod get method => paramsBase.method;

  @override
  String get url =>
      paramsBase.url.replaceAllMapped(IFetchingParams.reVar, _reReplacer);

  @override
  String get query =>
      paramsBase.query.replaceAllMapped(IFetchingParams.reVar, _reReplacer);

  @override
  WebContentType get type => paramsBase.type;

  @override
  Uri get uri => IFetchingParams.uriGen(this);

  @override
  bool get isNeedData => false;

  @override
  IFetchingParamsWithData toWithData() => this;

  @override
  final IFetchingParams paramsBase;

  @override
  final Map<String, String> data;
}
