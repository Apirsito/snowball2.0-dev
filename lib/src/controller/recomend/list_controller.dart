import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ots/ots.dart';
import 'package:snowball/src/models/recommend/group_recommend.dart';
import 'package:snowball/src/models/recommend/recommend_model.dart';

class RecommendListController extends GetxController {
  static RecommendListController get to => Get.put(RecommendListController());

  final _dbRecommends =
      FirebaseFirestore.instance.collection("recomendaciones");
  Rx<GroupRecommend> listRecommend = Rx<GroupRecommend>();
  Rx<RecommendModel> itemSelected = Rx<RecommendModel>();

  void getListController(GroupRecommend newValue) {
    listRecommend.value = newValue;
  }

  void getItemSelected(RecommendModel value) {
    itemSelected.value = value;
    refresh();
  }

  clearData() {}

  Future<void> acepRecommend(RecommendModel item, {bool single = false}) async {
    showLoader();
    clearData();
    _dbRecommends.doc(item.id).update({"aprovado": true, "pending": false}).then((value) {
      hideLoader();
      listRecommend.value.recommends.remove(item);
      refresh();
      if (single == true && listRecommend.value.recommends.length == 0) {
        Get.back();
      }
    });
  }

  Future<void> removeRecommend(RecommendModel item, {bool single = false}) async {
    showLoader();
    _dbRecommends.doc(item.id).delete().then((value) {
      listRecommend.value.recommends.remove(item);
      refresh();
      hideLoader();
      if (single == true && listRecommend.value.recommends.length == 0) {
        Get.back();
      }
    });
  }

  void recommendationAprovalConfirmationAlert() {
    Get.defaultDialog(
      title: "Information",
      radius: 10,
      textConfirm: "acept".tr.toUpperCase(),
      textCancel: "cancel".tr.toUpperCase(),
      confirmTextColor: Colors.white,
      onConfirm: () {
        aproveRecomends();
        Get.back();
      },
      onCancel: () => print("cancel"),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("aproval_recoments".tr),
      )
    );
  }

  aproveRecomends() async {
    final recomen = listRecommend.value.recommends;
    for (int i = 0; i < recomen.length; i++) {
      acepRecommend(recomen[i]);
    }
    Get.back();
  }

  deleteRecomends() async {
    final recomen = listRecommend.value.recommends;
    for (int i = 0; i < recomen.length; i++) {
      removeRecommend(recomen[i]);
    }
    Get.back();
  }

  void ignoreRecomends() {
    Get.defaultDialog(
      title: "Information",
      radius: 10,
      textConfirm: "acept".tr.toUpperCase(),
      textCancel: "cancel".tr.toUpperCase(),
      confirmTextColor: Colors.white,
      onConfirm: () {
        deleteRecomends();
        Get.back();
      },
      onCancel: () => print("cancel"),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("eliminate_recoments".tr),
      )
    );
  }

  void ignoreRecomend(RecommendModel item) {
    Get.defaultDialog(
      title: "Information",
      radius: 10,
      textConfirm: "acept".tr.toUpperCase(),
      textCancel: "cancel".tr.toUpperCase(),
      confirmTextColor: Colors.white,
      onConfirm: () {
        removeRecommend(item, single: true);
        Get.back();
      },
      onCancel: () => print("cancel"),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("eliminate_recoment".tr),
      )
    );
  }
}
