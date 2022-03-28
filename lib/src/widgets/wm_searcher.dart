import 'dart:async';

import 'package:flutter/material.dart';

import '../common/common_misc.dart';

mixin WmSearch<T extends StatefulWidget> on State<T> {
  Duration get searchDuration => const Duration(milliseconds: 666);

  bool searchShown = false;
  final searchController = TextEditingController();
  Timer? searchTimer;
  String searchText = '';
  Widget get searchIcon =>
      searchTimer != null ? const Icon(Icons.schedule) : const Icon(Icons.done);

  @mustCallSuper
  void searchHandle() {
    searchTimer?.cancel();
    searchTimer = null;
    searchText = searchController.text;
    setState(kVoidFunc);
  }

  @mustCallSuper
  void searchListner() {
    if (searchTimer == null) {
      searchTimer = Timer(searchDuration, searchHandle);
      setState(kVoidFunc);
    } else {
      searchTimer!.cancel();
      searchTimer = Timer(searchDuration, searchHandle);
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(searchListner);
  }

  @override
  void dispose() {
    searchTimer?.cancel();
    searchController
      ..removeListener(searchListner)
      ..dispose();
    super.dispose();
  }

  Widget get searchTextField => TextField(
        autofocus: true,
        controller: searchController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Строка поиска',
          prefixIcon: searchIcon,
        ),
      );

  Widget get searchFab => FloatingActionButton(
        onPressed: () => setState(() => searchShown = !searchShown),
        tooltip:
            searchShown ? 'Скрыть строку поиска' : 'Показать строку поиска',
        child: searchShown
            ? const Icon(Icons.search_off)
            : const Icon(Icons.search),
      );
}
