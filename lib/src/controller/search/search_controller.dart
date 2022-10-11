import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class SearchController extends GetxController {
  static SearchController get to => Get.put(SearchController());

  TextEditingController search = new TextEditingController();
  FocusNode focusSearch = new FocusNode();
  RxList<AlgoliaObjectSnapshot> resultsList = RxList<AlgoliaObjectSnapshot>();
  AlgoliaQuerySnapshot querys = AlgoliaQuerySnapshot();
  String querySearch;
  AlgoliaQuerySnapshot results;
  var searching = false.obs;
  Algolia algolia;

  void searchResults(String data) async {
    if (data.length >= 3) {
      debounce(resultsList, (_) => getDataResult(data),
          time: Duration(seconds: 1));
    }
  }

  getDataResult(String data) async {
    AlgoliaQuery query = algolia.instance.index('Snowball');
    if (data.length >= 3) {
      searching.value = true;
      FocusScope.of(Get.context).requestFocus(focusSearch);

      String valor = search.text.trim();
      query = query.search(valor);

      AlgoliaQuerySnapshot snaps = await query.getObjects();
      resultsList = snaps.hits;

      querySearch = search.text;
      searching.value = false;
      FocusScope.of(Get.context).requestFocus(focusSearch);
    }
  }

  void showAlert() {
    showDialog(
        context: Get.context,
        builder: (context) => AlertDialog(
              title: Text("Error"),
              content: Text("Snowball no found"),
            ));
  }

  clearData() {}
}
