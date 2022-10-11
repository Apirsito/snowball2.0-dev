import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:ots/ots.dart';
import 'package:snowball/src/common/alerts.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/models/maps/location_point_model.dart';
import 'package:snowball/src/models/snowball/adjunto.dart';
import 'package:snowball/src/models/snowball/snowball.dart';
import 'package:snowball/src/scenes/common/custom_location.dart';
import 'package:snowball/src/scenes/home/navigation.dart';

class AddController extends GetxController {
  PageController pageController = PageController(initialPage: 0);
  final dbSnowball = FirebaseFirestore.instance.collection("snowball");
  final dbRecommend = FirebaseFirestore.instance.collection("recomendaciones");
  TextEditingController teName = TextEditingController();
  TextEditingController teDescription = TextEditingController();
  TextEditingController teLocation = TextEditingController();

  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  RxList<Adjuntos> resources = RxList<Adjuntos>();
  RxList<String> itemTags = RxList.empty();
  var isEditable = false.obs;

  Geoflutterfire geo = Geoflutterfire();
  Snowball snow = new Snowball();
  Rx<Position> position = Rx<Position>();

  var page = 0.obs;
  LocationPointModel userPoint = new LocationPointModel();
  int get total => resources.length;
  final box = GetStorage();
  RxBool loading = false.obs;
  RxInt currentResource = 0.obs;
  RxInt totalResource = 0.obs;
  RxInt resourcesForUpload = 0.obs;

  @override
  onReady() {
    Geolocator.getCurrentPosition().then((value) => position.value = value);
    debounce(currentResource, validateUploadData);
    super.onReady();
  }

  Future<void> loadImages() async {
    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (resultList.isNotEmpty) {
      resources.addAll(resultList
          .map((e) => Adjuntos(id: randomId(), asset: e, isDelete: true))
          .toList());
    } else {
      printError(info: error);
    }
  }

  Future<void> loadVideos() async {
    ImagePicker _picker = ImagePicker();
    PickedFile _video;
    String error;

    try {
      _video = await _picker.getVideo(source: ImageSource.gallery);
    } on Exception catch (e) {
      error = e.toString();
    }

    if (_video != null) {
      resources.add(
          Adjuntos(id: randomId(), files: File(_video.path), isDelete: true));
    } else {
      printError(info: error);
    }
  }

  String randomId() {
    final DateTime now = DateTime.now();
    final int millSeconds = now.millisecondsSinceEpoch;
    final String storageId = millSeconds.toString();
    var bytes1 = utf8.encode(storageId); // data being hashed
    var digestId = sha256.convert(bytes1);
    return digestId.toString();
  }

  deleteImagenes() {
    resources.removeAt(page.value);
    pageController.jumpToPage(0);
    refresh();
  }

  @override
  void onClose() {
    itemTags.clear();
    resources.clear();
    loading(false);
    super.onClose();
  }

  void getDetail(String id) {
    snow.id = id;
    dbSnowball.doc(id).get().then((value) {
      if (value.exists) {
        snow = Snowball.fromSnapshot(value);
        teName.text = snow.nombre;
        teDescription.text = snow.descripcion;
        teLocation.text = "${snow.pais},${snow.ciudad}";
        isEditable.value = true;
        itemTags.assignAll(snow.etiquetas.map((e) => e).toList());
        dbSnowball.doc(id).collection("adjuntos").get().then((adjuntos) {
          if (adjuntos.docs.isNotEmpty) {
            adjuntos.docs.forEach((element) {
              resources.add(Adjuntos(
                  id: element.id,
                  image: element["image"],
                  video: element["video"],
                  isDelete: false));
            });
            refresh();
            print(resources.length);
          }
        });
      }
    });
  }

  void createSnowball() {
    loading(true);
    var uuid = box.read("uuid");
    if (teName.text.isEmpty ||
        teDescription.text.isBlank ||
        teLocation.text.isBlank) {
      loading(false);
      AlertsMessage.showSnackbar("some_fields".tr);
      return;
    } else {
      snow.adjuntos = [];
      snow.autor = uuid;
      snow.descripcion = teDescription.text;
      snow.estado = "A";
      snow.etiquetas = itemTags.isEmpty ? [] : itemTags.toList();
      snow.fecha = DateTime.now();
      snow.nombre = teName.text;
      snow.position = userPoint.point;
      snow.ciudad = userPoint.ciudad;
      snow.pais = userPoint.pais;

      dbSnowball.add(snow.toJson()).then((value) async {
        for (int j = 0; j < resources.length; j++) {
          if (resources[j].files != null) {
            await uploadFile(resources[j], value.id, j, true);
            currentResource++;
          } else if (resources[j].asset != null) {
            await uploadFile(resources[j], value.id, j, false);
            currentResource++;
          } else {
            currentResource++;
          }
        }
        if (resources.isEmpty) {
          loading(false);
          Get.back();
        }
      }).catchError((error) {
        loading(false);
        AlertsMessage.showSnackbar("I think some data is missing");
      });
    }
  }

  void updateSnowball() {
    loading(true);
    var uuid = box.read("uuid");
    if (teName.text.isEmpty &&
        teDescription.text.isEmpty &&
        teLocation.text.isEmpty) {
      loading(false);
      AlertsMessage.showSnackbar("some_fields".tr);
      return;
    } else {
      final resourcesUpload = resources.where((e) => e.isDelete).toList();
      resourcesForUpload(resourcesUpload.length);
      snow.autor = uuid;
      snow.descripcion = teDescription.text;
      snow.etiquetas = itemTags.value.isEmpty ? [] : itemTags.toList();
      snow.fecha = DateTime.now();
      snow.nombre = teName.text;
      dbSnowball.doc(snow.id).update(snow.toJson()).then((value) async {
        for (int j = 0; j < resourcesUpload.length; j++) {
          if (resourcesUpload[j].files != null) {
            await uploadFile(resourcesUpload[j], snow.id, j, true);
            currentResource++;
          } else if (resourcesUpload[j].asset != null) {
            await uploadFile(resourcesUpload[j], snow.id, j, false);
            currentResource++;
          } else {
            currentResource++;
          }
        }

        if (resourcesUpload.isEmpty) {
          loading(false);
          Get.back();
        }
      });
    }
  }

  void deleteSnowball() {
    Get.defaultDialog(
        title: "informations".tr,
        content: Text("remove_snowball".tr),
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        textCancel: "cancel".tr,
        onConfirm: () {
          showLoader(isModal: true, modalColor: AppConstants.blue);
          dbRecommend
              .where("snowball_id", isEqualTo: snow.id)
              .get()
              .then((value) {
            value.docs.forEach((element) {
              dbRecommend.doc(element.id).delete();
            });

            dbSnowball.doc(snow.id).collection("rolls").get().then((value) {
              value.docs.forEach((element) {
                dbSnowball
                    .doc(snow.id)
                    .collection("rolls")
                    .doc(element.id)
                    .delete();
              });
              dbSnowball
                  .doc(snow.id)
                  .collection("adjuntos")
                  .get()
                  .then((value) {
                value.docs.forEach((element) {
                  dbSnowball
                      .doc(snow.id)
                      .collection("adjuntos")
                      .doc(element.id)
                      .delete();
                });

                dbSnowball
                    .doc(snow.id)
                    .delete()
                    .then((value) => Get.offAll(NavigationApp()));

                Get.offAll(NavigationApp());
                hideLoader();
              });
            });
          });
        });
  }

  Future<void> uploadFile(
      Adjuntos resource, String id, int index, bool isVideo) async {
    final DateTime now = DateTime.now();
    final int millSeconds = now.millisecondsSinceEpoch;
    final String month = now.month.toString();
    final String date = now.day.toString();
    final String storageId = (millSeconds.toString() + id);
    final String today = ('$month-$date');

    UploadTask uploadTask;

    if (!isVideo) {
      // ignore: deprecated_member_use
      ByteData byteData = await resource.asset.requestOriginal();
      List<int> imageData = byteData.buffer.asUint8List();

      Reference ref = FirebaseStorage.instance
          .ref()
          .child("images")
          .child(today)
          .child("$storageId.jpg");
      uploadTask = ref.putData(imageData);
    } else {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("videos")
          .child(today)
          .child("$storageId");
      uploadTask = ref.putFile(resource.files);
    }

    return await (await uploadTask).ref.getDownloadURL().then((url) {
      final Adjuntos add = new Adjuntos(
          id: resource.id,
          index: index,
          video: isVideo ? url : null,
          image: isVideo ? null : url);

      FirebaseFirestore.instance
          .collection("snowball")
          .doc(id)
          .collection("adjuntos")
          .add(add.toJson())
          .then((val) {
        if (index == 0) {
          FirebaseFirestore.instance.collection("snowball").doc(id).update({
            "adjuntos": [add.toJson()],
          });
        }
      });
    });
  }

  void senToCustomLocation() async {
    LocationPointModel result = await Get.to(() => CustomLocation());
    if (result != null) {
      userPoint = result;
      teLocation.text = result.address;
    } else {}
  }

  void validateUploadData(int current) {
    totalResource.value = resources.where((e) => e.isDelete).toList().length;
    if (current == totalResource.value || current > totalResource.value) {
      Get.back();
    }
  }

  removeTags(int index) {
    itemTags.removeAt(index);
  }
}
