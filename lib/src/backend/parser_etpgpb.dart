import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../common/common_date_time.dart';
import '../common/common_misc.dart';
import '../common/common_stop_watch_ticks.dart';
import '../common/common_web_constants.dart';
import '../data/parsed_data.dart';
import '../data/tender_data_etpgpb.dart';
import '../interfaces/i_fetched_data.dart';
import '../interfaces/i_fetching_params.dart';
import '../interfaces/i_parsed_data.dart';
import '../interfaces/i_parser.dart';

@immutable
class ParserEtpGpb implements IParser<TenderDataEtpGpb> {
  @literal
  const ParserEtpGpb();

  @override
  bool canParse(IFetchedData fetched) {
    if (fetched.type != WebContentType.html) return false;
    final bytes = fetched.bytes;
    if (bytes == null) {
      throw ArgumentError('No bytes');
    }
    final offset = searchSublistBytes(bytes, _data0, 4000);
    if (offset == -1) return false;
    return true;
  }

  static final kDateFormat = DateFormat('dd.MM.yyyy');

  static final _reMinutes = RegExp(r'(\d\d)\.(\d\d)\.(\d\d\d\d)'
      r'\s+(?:г\.,\s+)?(\d\d)\:(\d\d)'
      r'\s*(?:\(\s*(\w+)?([+-])(\d\d)\:(\d\d)\))');
  static MyDateTime _parseEndTime(String txt) {
    if (txt.isEmpty) return MyDateTime.unknownNow;
    final m = _reMinutes.matchAsPrefix(txt);
    if (m == null) return MyDateTime.unknownNow;
    var offset = Duration.zero;
    if (m[7] != null) {
      offset = Duration(hours: int.parse(m[8]!), minutes: int.parse(m[9]!));
      if (m[7]! == '-') {
        offset = -offset;
      }
      if (m[6] != null) {
        switch (m[6]!) {
          case 'GMT':
            break;
          case 'MSK':
            offset += const Duration(hours: 3);
            break;
          default:
            throw Exception();
        }
      }
    } else {
      offset += const Duration(hours: 3);
    }

    return MyDateTime(
      DateTime.utc(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!),
              int.parse(m[4]!), int.parse(m[5]!))
          .subtract(offset),
      MyDateTimeQuality.minute,
    );
  }

  @override
  IParsedData<TenderDataEtpGpb> parse(IFetchedData fetched) {
    assert(fetched.bytes != null, 'No bytes');
    assert(fetched.params is IFetchingParamsWithData, 'No data in params');
    final sw = Stopwatch()..start();
    final now = DateTime.now().toUtc();
    final bytes = fetched.bytes!;
    final params = fetched.params as IFetchingParamsWithData;
    final offsetEmptyBlock = searchSublistBytes(bytes, _dataEmpty, 150000);
    if (offsetEmptyBlock != -1) {
      return ParsedData(fetched, StopWatchTicks.fromSw(sw), StopWatchTicks.zero,
          1, 1, const []);
    }
    final offsetProcBlock = searchSublistBytes(bytes, _dataFragment0, 150000);
    if (offsetProcBlock == -1) throw Exception();
    final offsetPagiBlock =
        searchSublistBytes(bytes, _dataFragment1, -1, offsetProcBlock);
    if (offsetPagiBlock == -1) throw Exception();
    final fragmentNodes = HtmlParser(
      Uint8List.sublistView(bytes, offsetProcBlock, offsetPagiBlock),
      encoding: 'utf-8',
    ).parseFragment().nodes;
    final tDeserialization = StopWatchTicks.fromSw(sw);
    sw.reset();

    final fragmentProcedures = fragmentNodes.first;
    final fragmentPagination = fragmentNodes.last;
    var currentPage = -1;
    var maxPage = 0;
    final tenders = <TenderDataEtpGpb>[];

    final dPublis = MyDateTime(
      kDateFormat.parse(params.data['date:date(dd.MM.yyyy)']!, true),
      MyDateTimeQuality.day,
    );
    final urlBase = fetched.params.uri;
    for (final el in fragmentProcedures.nodes
        .whereType<Element>()
        .where(_nodeIsDivProcedure)) {
      final v = _EtpGpbProcedureVisitor()..visitChildren(el);
      tenders.add(TenderDataEtpGpb(
        v.id,
        now,
        urlBase.resolve(v.link).toString(),
        v.number,
        v.description,
        v.sum,
        dPublis,
        _parseEndTime(v.dateStart),
        _parseEndTime(v.dateEnd),
        _parseEndTime(v.dateAuction),
        v.companyName,
        v.companyLogo,
        v.auctionType,
        v.lots,
        v.regions,
        v.auctionSections,
        v.props,
      ));
    }
    if (fragmentPagination.nodes.isNotEmpty) {
      for (final el in fragmentPagination.nodes
          .firstWhere(_nodeIsDivPagination)
          .nodes
          .firstWhere(_nodeIsNavPagination)
          .nodes
          .whereType<Element>()) {
        final className = el.attributes['class'];
        if (className == 'pagination__item--current') {
          currentPage = int.parse(el.text);
          maxPage = max(maxPage, currentPage);
        } else if (className == 'pagination__item') {
          maxPage = max(maxPage, int.parse(el.text));
        }
      }
    } else {
      maxPage = 1;
      currentPage = 1;
    }
    final tParsing = StopWatchTicks.fromSw(sw);
    return ParsedData(
      fetched,
      tDeserialization,
      tParsing,
      currentPage,
      maxPage,
      tenders,
    );
  }

  static final _data0 = const Utf8Encoder().convert(
      // ignore: lines_longer_than_80_chars
      '<meta property="og:site_name" content="Электронная торговая площадка ГПБ">');
  static final _dataFragment0 = const Utf8Encoder().convert(
      // ignore: lines_longer_than_80_chars
      '<div class="proceduresList hidden proceduresList--big proceduresList--with-block-links" data-selector="proceduresList">');
  static final _dataFragment1 = const Utf8Encoder().convert(
      // ignore: lines_longer_than_80_chars
      '</section></form>');

  static final _dataEmpty = const Utf8Encoder().convert(
      '<div class="emptyResultsBlock"><p class="emptyResultsBlock__p">');

  static bool _nodeIsDivProcedure(Node e) =>
      e is Element &&
      e.localName == 'div' &&
      e.attributes['class'] == 'procedure';

  static bool _nodeIsDivPagination(Node e) =>
      e is Element &&
      e.localName == 'div' &&
      e.attributes['class'] == 'pagination';

  static bool _nodeIsNavPagination(Node e) =>
      e is Element &&
      e.localName == 'nav' &&
      e.attributes['role'] == 'navigation';
}

class _EtpGpbProcedureVisitor extends TreeVisitor {
  String link = '';
  String number = '';
  String companyName = '';
  String companyLogo = '';
  String title = '';
  String description = '';
  int id = 0;

  /// Секции торгов
  Set<String> auctionSections = {};

  /// Тип торгов
  String auctionType = '';

  /// Параметры
  Set<String> props = {};

  /// Цена
  int sum = 0;

  /// Количество лотов
  int lots = 0;

  /// Название региона
  Set<String> regions = {};

  int regionsCount = 0;

  /// Приём заявок
  String dateStart = '';

  /// Приём заявок
  String dateEnd = '';

  /// Дата аукциона
  String dateAuction = '';

  String lastUnitTitle = '';

  @override
  void visitElement(Element node) {
    final className = node.className;
    switch (className) {
      case 'procedure__flex':
      case 'procedure__infoDescription':
      case 'procedure__infoDescriptionShort':
      case 'procedure__infoAuction':
      case 'procedure__infoProps':
      case 'procedure__data':
      case 'procedure__company':
      case 'procedure__info':
      case 'procedure__details':
      case 'procedure__detailsSumCurrency':
      case 'procedure__detailsLots':
      case 'procedure__detailsRegion':
      case 'procedure__detailsReception':
      case 'relatedDetailsDate__tz':
      case 'procedure__detailsDate':
      case 'procedure__allRegionsTitle':
        return visitChildren(node);
      case 'procedure__infoPropsShare':
        return;
      case 'procedure__link procedure__infoTitle':
        if (title.isNotEmpty) throw Exception();
        title = node.text;
        final index = title.lastIndexOf('№');
        number = title.substring(index).trim();
        continue procedure__link;
      procedure__link:
      case 'procedure__link':
        final llink = node.attributes['href']!;
        if (link.isNotEmpty && link != llink) throw Exception();
        link = llink;
        return visitChildren(node);
      case 'procedure__companyName':
        if (companyName.isNotEmpty) throw Exception();
        companyName = node.text;
        return visitChildren(node);
      case 'lazyload procedure__companyLogo':
        if (companyLogo.isNotEmpty) throw Exception();
        companyLogo = node.attributes['src'] ?? node.attributes['data-src']!;
        return visitChildren(node);
      case 'procedure__infoDescriptionFull':
        if (description.isNotEmpty) throw Exception();
        description = node.text;
        return visitChildren(node);
      case 'procedure__infoDescriptionCode':
        if (id != 0) throw Exception();
        id = int.parse(node.text);
        return visitChildren(node);
      case 'procedure__infoAuctionCustomer':
        if (auctionSections.isNotEmpty) throw Exception();
        auctionSections.add(node.text);
        return visitChildren(node);
      case 'procedure__infoAuctionType':
        if (auctionType.isNotEmpty) {
          auctionSections.add(node.text);
        } else {
          auctionType = node.text;
        }
        return visitChildren(node);
      case 'procedure__infoPropsValue':
        props.add(node.text);
        return visitChildren(node);
      case 'procedure__detailsSum':
        if (sum != 0) throw Exception();
        final txt = node.text;
        for (final t in txt.codeUnits) {
          if (t >= 0x30 && t <= 0x39) {
            sum = sum * 10 + (t & 0xf);
            if (t == 0x2E || t == 0x2C) throw Exception();
          }
        }
        return visitChildren(node);
      case 'procedure__detailsSum procedure__detailsSum--unknown':
        final txt = node.text;
        if (txt == 'Цена не указана' || txt == '0 ₽') {
          sum = 0;
        } else {
          throw Exception();
        }
        return visitChildren(node);
      case 'procedure__detailsUnitTitle':
      case 'procedure__detailsUnitTitle procedure__detailsUnitTitle--block':
        lastUnitTitle = node.text;
        return visitChildren(node);
      case 'procedure__detailsUnitValue':
      case 'procedure__detailsUnitValue procedure__detailsUnitValue--block':
        switch (lastUnitTitle) {
          case 'Лоты:':
            if (lots != 0) throw Exception();
            lots = int.parse(node.text);
            return visitChildren(node);
          case 'Регион:':
            if (regions.isNotEmpty) throw Exception();
            regions.add(node.text);
            return visitChildren(node);
          case 'Начало приема заявок:':
            if (dateStart.isNotEmpty) throw Exception();
            dateStart = node.text;
            return visitChildren(node);

          case 'Прием заявок:':
          case 'Прием заявок до:':
            if (dateEnd.isNotEmpty) throw Exception();
            dateEnd = node.text;
            return visitChildren(node);
          case 'Дата аукциона:':
            if (dateAuction.isNotEmpty) throw Exception();
            dateAuction = node.text;
            return visitChildren(node);
          default:
            if (lastUnitTitle.startsWith('Регионы\u{00A0}')) {
              if (regions.isNotEmpty) throw Exception();
              final i = lastUnitTitle.indexOf(':', 8);
              regionsCount = int.parse(lastUnitTitle.substring(8, i));
              return visitChildren(node.nodes.last);
            }
            throw Exception(lastUnitTitle);
        }
      case 'procedure__regionList':
        for (final e in node.nodes.whereType<Element>()) {
          if (regions.length >= regionsCount) throw Exception();
          regions.add(e.nodes.whereType<Text>().first.text.trim());
        }
        return;
      // case 'procedure__region':
      //   if (regions.length >= regionsCount) throw Exception();
      //   regions.add(node.text);
      //   return;
      default:
        throw Exception(node);
    }
  }
}
