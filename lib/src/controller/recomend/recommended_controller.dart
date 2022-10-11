import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ots/ots.dart';
import 'package:snowball/src/models/recommend/group_recommend.dart';
import 'package:snowball/src/models/recommend/recommend_model.dart';
import 'package:snowball/src/models/snowball/snowball.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:collection/collection.dart';

class RecommendedController extends GetxController {
  static RecommendedController get to => Get.put(RecommendedController());

  final _dbRecommends =
      FirebaseFirestore.instance.collection("recomendaciones");
  final _dbNotification =
      FirebaseFirestore.instance.collection("notifications");
  final _dbUsers = FirebaseFirestore.instance.collection("usuarios");
  final _dbSnowball = FirebaseFirestore.instance.collection("snowball");

  RxList<GroupRecommend> recommends = <GroupRecommend>[].obs;
  RxList<GroupRecommend> recommendsAcepted = <GroupRecommend>[].obs;
  RxList<RecommendModel> allRecommends = <RecommendModel>[].obs;

  Asset imageForUpload;
  final box = GetStorage();
  var seeAll = false.obs;
  final picker = MultiImagePicker();
  var imageUploaded = "".obs;
  var snowballId = "".obs;
  FocusNode focusNode = new FocusNode();
  TextEditingController recommend = TextEditingController();

  // var recommendText = "".obs;

  @override
  void onReady() {
    // REVISAR CON "ever" A CAMBIO DE "bounce"
    // debounce(
    //   recommendText,
    //   handleSaveRecommendation,
    //   time: Duration(seconds: 1),
    // );
  }

  getCurrentRecommends() {
    var uuid = box.read('uuid');
    getRecommendGrouped(uuid, false, pendientes: true);
    getRecommendGrouped(uuid, true);
    getAllRecommend(uuid);
    refresh();
  }

  getRecommends(String id) {
    snowballId.value = id;
    _dbRecommends
        .where("snowball_id", isEqualTo: id)
        .where("aprovado", isEqualTo: true)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        var newMap = groupBy(value.docs, (obj) => obj.data()['snowball_id']);

        newMap.forEach((key, value) {
          _dbSnowball.doc(key).get().then((snowball) {
            if (snowball.exists) {
              var snowballItem = Snowball.fromSnapshot(snowball);
              var recoms = value
                  .map((element) => RecommendModel(
                      id: element.id,
                      dateCreation: element["fecha_creacion"].toDate(),
                      imagen: element["image"],
                      descripcion: element["descripcion"],
                      autor: element["autor"],
                      snowballId: element["snowball_id"]))
                  .toList();
              recommends.add(GroupRecommend(
                  id: key,
                  snowball: snowballItem,
                  descripcion: "${recoms.length} ${'recommends'.tr}",
                  recommends: recoms));
            }
          });
        });
      }
    });
  }

  getRecommendGrouped(String id, bool aprovadas, {bool pendientes = false}) {
    _dbRecommends
        .where("id", isEqualTo: id)
        .where("aprovado", isEqualTo: aprovadas)
        .where("pending", isEqualTo: pendientes)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        var newMap = groupBy(value.docs, (obj) => obj.data()['snowball_id']);
        newMap.forEach((key, value) {
          _dbSnowball.doc(key).get().then((snowball) {
            if (snowball.exists) {
              var snowballItem = Snowball.fromSnapshot(snowball);

              List<RecommendModel> recoms = [];
              for (var i = 0; i < value.length; i++) {
                var element = value[i];
                _dbUsers.doc(element["autor"]).get().then((user) {
                  recoms.add(RecommendModel(
                      id: element.id,
                      dateCreation: element["fecha_creacion"].toDate(),
                      imagenProfile: user['image_profile'],
                      imagen: element.data()["image"] ?? "",
                      descripcion: element["descripcion"],
                      autor: user.id,
                      autorName: user["nombre_usuario"],
                      snowballId: element["snowball_id"]));

                  if (i == value.length - 1) {
                    if (aprovadas) {
                      recommendsAcepted.add(GroupRecommend(
                          id: key,
                          snowball: snowballItem,
                          descripcion: "${recoms.length} ${'recommends'.tr}",
                          recommends: recoms,
                          snowballId: element["snowball_id"]));
                    } else {
                      recommends.add(GroupRecommend(
                          id: key,
                          snowball: snowballItem,
                          descripcion: "${recoms.length} ${'recommends'.tr}",
                          recommends: recoms,
                          snowballId: element["snowball_id"]));
                    }
                  }
                });
              }
            }
          });
        });
      }
    });
  }

  getRecommendbySnow(String id) {
    allRecommends.clear();
    snowballId.value = id;
    _dbRecommends
        .orderBy("fecha_creacion", descending: true)
        .where("snowball_id", isEqualTo: id)
        .where("pending", isEqualTo: false)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((element) {
          _dbUsers.doc(element["autor"]).get().then((user) {
            var recomend = RecommendModel(
                id: element.id,
                dateCreation: element["fecha_creacion"].toDate(),
                imagenProfile: user['image_profile'],
                imagen: element.data()["image"] ?? "",
                descripcion: element["descripcion"],
                autor: user.id,
                autorName: user["nombre_usuario"],
                snowballId: element["snowball_id"]);
            _dbSnowball.doc(recomend.snowballId).get().then((snowball) {
              if (snowball.exists) {
                recomend.snowball = Snowball.fromSnapshot(snowball);
                allRecommends.add(recomend);
              }
            });
          });
        });
      }
    });
  }

  getAllRecommend(String id) {
    _dbRecommends
        .where("id", isEqualTo: id)
        .where("pending", isEqualTo: false)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((element) {
          _dbUsers.doc(element["autor"]).get().then((user) {
            var recomend = RecommendModel(
                id: element.id,
                dateCreation: element["fecha_creacion"].toDate(),
                imagenProfile: user['image_profile'],
                imagen: element.data()["image"] ?? "",
                descripcion: element["descripcion"],
                autor: user.id,
                autorName: user["nombre_usuario"],
                snowballId: element["snowball_id"]);
            _dbSnowball.doc(recomend.snowballId).get().then((snowball) {
              if (snowball.exists) {
                recomend.snowball = Snowball.fromSnapshot(snowball);
                allRecommends.add(recomend);
              }
            });
          });
        });
      }
    });
  }

  clearData() {
    recommends.clear();
    allRecommends.clear();
    recommendsAcepted.clear();
  }

  aproveRecomends() {
    recommends.forEach((element) {
      FirebaseFirestore.instance
          .collection("recomendaciones")
          .doc(element.id)
          .update({"aprovado": true, "pending": false});
    });
    clearData();
    getCurrentRecommends();
  }

  ignoreRecomends() {
    Get.defaultDialog(
        title: "Information",
        radius: 10,
        textConfirm: "acept".tr.toUpperCase(),
        textCancel: "cancel".tr.toUpperCase(),
        confirmTextColor: Colors.white,
        onConfirm: () {
          if (seeAll.value) {
            allRecommends.forEach((element) {
              deleteFronFirebase(element);
            });
          }
        },
        onCancel: () => print("cancel"),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("eliminate_recoments".tr),
        ));
  }

  deleteFronFirebase(RecommendModel item) async {
    _dbRecommends.doc(item.id).delete().then((respose) {
      if (seeAll.value) {
        Get.back();
        allRecommends.remove(item);
        refresh();
      } else {
        Get.back();
        recommends.remove(item);
        refresh();
      }
    });
  }

  acepRecommend(RecommendModel item) {
    showLoader();
    clearData();
    _dbRecommends
        .doc(item.id)
        .update({"aprovado": true, "pending": false}).then((value) {
      hideLoader();
      getCurrentRecommends();
    });
  }

  void deleteItem(RecommendModel item) {
    Get.defaultDialog(
        title: "Information",
        radius: 10,
        textConfirm: "acept".tr.toUpperCase(),
        textCancel: "cancel".tr.toUpperCase(),
        confirmTextColor: Colors.white,
        onConfirm: () => deleteFronFirebase(item),
        onCancel: () => print("cancel"),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("eliminate_recoment".tr),
        ));
  }

  String randomString(int strlen) {
    var chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for (var i = 0; i < strlen; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result;
  }

  void saveRecomendation() {
    if ((recommend.text != null && recommend.text.trim().isNotEmpty) ||
        (imageUploaded.value != "")) {
      handleSaveRecommendation();
      // recommendText.value = recommend.text;
    }
  }

  handleSaveRecommendation() async {
    final rdocs = randomString(20);
    final uuid = box.read('uuid');
    final referemce = _dbRecommends.doc(rdocs);

    _dbSnowball.doc(snowballId.value).get().then((snowball) {
      if (snowball.exists) {
        final snowballModel = Snowball.fromSnapshot(snowball);
        FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(referemce, {
            "aprovado": false,
            "pending": true,
            "autor": uuid,
            "id": snowballModel.autor,
            "image": imageUploaded.value,
            "descripcion": recommend.text.trim(),
            "fecha_creacion": DateTime.now(),
            "snowball_id": snowballModel.id
          });
        }).then((value) {
          imageUploaded.value = "";
          FocusScope.of(Get.context).unfocus();
          _dbNotification.add({
            "id": snowballModel.autor,
            "read": false,
            "title": "New Recomendation",
            "type": 2,
            "fecha": DateTime.now()
          }).then((value) {
            Get.defaultDialog(
                title: 'informations'.tr,
                content: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text("thanks_your_recommend".tr),
                ),
                confirmTextColor: Colors.white,
                onConfirm: () {
                  recommend.clear();
                  Get.back();
                });
          });
        });
      }
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (resultList.isNotEmpty) {
      Get.bottomSheet(
        Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
        isDismissible: true,
      );
      final DateTime now = DateTime.now();
      final int millSeconds = now.millisecondsSinceEpoch;
      final String month = now.month.toString();
      final String date = now.day.toString();
      final String storageId = (millSeconds.toString() + month + date);
      final String today = ('$month-$date');

      ByteData byteData = await resultList.first.getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("recommends")
          .child(today)
          .child("$storageId");
      final uploadTask = await ref.putData(imageData);
      try {
        final url = await uploadTask.ref.getDownloadURL();
        imageUploaded.value = url;
        imageForUpload = resultList.first;
        Get.back();
      } catch (e) {
        print(e);
        Get.back();
      }
    } else {
      print(error);
    }
  }
}
