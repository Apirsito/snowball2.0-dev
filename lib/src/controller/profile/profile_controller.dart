import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:ots/ots.dart';
import 'package:snowball/src/common/alerts.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/auth/auth_controller.dart';
import 'package:snowball/src/models/profile/profile_model.dart';
import 'package:snowball/src/models/recommend/group_recommend.dart';
import 'package:snowball/src/models/recommend/recommend_model.dart';
import 'package:snowball/src/models/snowball/snowball.dart';
import 'package:snowball/src/scenes/detail/detail_snowball_view.dart';
import 'package:snowball/src/scenes/profile/profile_add_location.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.put(ProfileController());
  final dbUser = FirebaseFirestore.instance.collection("usuarios");
  final dbRolls = FirebaseFirestore.instance.collectionGroup("rolls");
  final dbSnowball = FirebaseFirestore.instance.collection("snowball");
  final dbRecommend = FirebaseFirestore.instance.collection("recomendaciones");
  final box = GetStorage();

  TextEditingController teUsername = TextEditingController();
  TextEditingController teCorreo = TextEditingController();
  TextEditingController tePasss = TextEditingController();
  TextEditingController teRepeatPass = TextEditingController();

  ProfileModel profile = new ProfileModel();
  var loading = true.obs;
  var changePass = false.obs;
  var rolls = 0.obs;
  var snowballs = 0.obs;
  var recommendsValue = 0.obs;
  Rx<Asset> imageLoad = Rx<Asset>();
  var chargeImage = false.obs;

  RxList<String> latesSnowballList = [""].obs;
  RxList<String> latesRollsList = [""].obs;

  RxList<Snowball> listOne = RxList<Snowball>();
  RxList<Snowball> listTwo = RxList<Snowball>();

  RxList<GroupRecommend> recommends = <GroupRecommend>[].obs;
  RxList<GroupRecommend> recommendsAcepted = <GroupRecommend>[].obs;
  RxList<RecommendModel> allRecommends = <RecommendModel>[].obs;
  getProfile() {
    crearData();
    var uuid = box.read("uuid");
    dbUser.doc(uuid).get().then((user) {
      dbUser
          .doc(uuid)
          .collection("chats")
          .where("read", isEqualTo: false)
          .get()
          .then((chats) {
        profile = ProfileModel.fromJsonMap(user, chats.docs.length);
        teUsername.text = profile.user.name;
        teCorreo.text = profile.user.correo;

        dbRolls.where("user", isEqualTo: uuid).get().then((responseRolls) {
          rolls.value = responseRolls.docs.length;
          latesRollsList.clear();
          responseRolls.docs.forEach((element) {
            dbSnowball.doc(element["snowball"]).get().then((value) {
              listTwo.add(Snowball.fromSnapshot(value));
              validateImage(latesRollsList, value);
            });
          });

          dbSnowball
              .where("autor", isEqualTo: uuid)
              .orderBy("fecha", descending: true)
              .get()
              .then((responseSnoballs) {
            snowballs.value = responseSnoballs.docs.length;
            responseSnoballs.docs.forEach((element) {
              listOne.add(Snowball.fromSnapshot(element));
              validateImage(latesSnowballList, element);
            });
            getCurrentRecommends();

            // dbRecommend
            //     .where("snowball_id", isEqualTo: uuid)
            //     .where("aprovado", isEqualTo: true)
            //     .get()
            //     .then((value) {
            //   if (value.docs.isNotEmpty) {
            //     var newMap = groupBy(value.docs, (obj) => obj.data()['snowball_id']);

            //     newMap.forEach((key, value) {
            //       dbSnowball.doc(key).get().then((snowball) {
            //         if (snowball.exists) {
            //           var snowballItem = Snowball.fromSnapshot(snowball);
            //           var recoms = value
            //               .map((element) => RecommendModel(
            //                   id: element.id,
            //                   dateCreation: element["fecha_creacion"].toDate(),
            //                   imagen: element["image"],
            //                   descripcion: element["descripcion"],
            //                   autor: element["autor"],
            //                   snowballId: element["snowball_id"]))
            //               .toList();
            //           recommends.add(GroupRecommend(
            //               id: key,
            //               snowball: snowballItem,
            //               descripcion: "${recoms.length} ${'recommends'.tr}",
            //               recommends: recoms));

            //                 recommendsValue.value++;
            //                  loading.value = false;
            //            refresh();
            //         }
            //       });
            //     });
            //   }
            // });

            // dbRecommend
            //     .where("id", isEqualTo: uuid)
            //     .get()
            //     .then((responseRecommend) {
            //   responseRecommend.docs.forEach((element) {
            //     dbSnowball.doc(element.id).get().then((value) {
            //       if (value.exists) {
            //         recommends.value++;
            //       }
            //     });
            //   });

            //   loading.value = false;
            //   refresh();
            // });
          });
        });
      });
    });
  }

  getCurrentRecommends() {
    var uuid = box.read('uuid');
    getRecommendGrouped(uuid, false, pendientes: true);
    getRecommendGrouped(uuid, true);
    loading.value = false;
    refresh();
  }

  getRecommendGrouped(String id, bool aprovadas, {bool pendientes = false}) {
    dbRecommend
        .where("id", isEqualTo: id)
        .where("aprovado", isEqualTo: aprovadas)
        .where("pending", isEqualTo: pendientes)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        var newMap = groupBy(value.docs, (obj) => obj.data()['snowball_id']);
        newMap.forEach((key, value) {
          dbSnowball.doc(key).get().then((snowball) {
            if (snowball.exists) {
              var snowballItem = Snowball.fromSnapshot(snowball);

              List<RecommendModel> recoms = [];
              for (var i = 0; i < value.length; i++) {
                var element = value[i];
                dbUser.doc(element["autor"]).get().then((user) {
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

  validateImage(RxList<String> lista, element) {
    var snowball = Snowball.fromJsonMap(element.data(), element.id);
    if (snowball.adjuntos.isNotEmpty) {
      if (snowball.adjuntos.first.video != null) {
        lista.add(
            "https://isaca-gwdc.org/wp-content/uploads/2016/12/Video-placeholder.png");
      } else {
        lista.add(snowball.adjuntos.first.image);
      }
    } else {
      lista.add(null);
    }
  }

  crearData() {
    loading.value = true;
    rolls.value = 0;
    snowballs.value = 0;
    recommends.clear();
    recommendsAcepted.clear();
    imageLoad = new Rx<Asset>();
    latesRollsList.clear();
    latesSnowballList = [""].obs;
    listOne.clear();
    listTwo.clear();
  }

  logoutSession() {
    AuthController.to.logout();
  }

  displayDialog() {
    Get.to(ProfileAddLocation());
  }

  Future<void> changeProfileImage() async {
    List<Asset> resultList;
    String error;
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true,
      );
    } on Exception catch (e) {
      error = e.toString();
      print(error);
    }
    if (resultList.isNotEmpty) {
      imageLoad.value = resultList.first;
    }
  }

  validateDataToSave() async {
    if (imageLoad.value != null) {
      showLoader(isModal: true, modalColor: AppConstants.blue);
      // ignore: deprecated_member_use
      ByteData byteData = await imageLoad.value.requestOriginal();
      List<int> imageData = byteData.buffer.asUint8List();
      UploadTask uploadTask;
      var uui = box.read('uuid');
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("profiles")
          .child("${DateTime.now().toIso8601String()}-$uui.jpg");
      uploadTask = ref.putData(imageData);

      return await (await uploadTask).ref.getDownloadURL().then((url) {
        chargeImage.value = false;
        hideLoader();
        saveDataProfile(url);
      });
    } else {
      hideLoader();
      saveDataProfile(null);
    }
  }

  saveDataProfile(String imageToChange) async {
    var uuid = box.read("uuid");
    if (teUsername.isBlank && teCorreo.isBlank) {
      AlertsMessage.showSnackbar('password_validate'.tr);
    } else {
      if (teRepeatPass.isBlank) {
        FirebaseAuth.instance.currentUser.updatePassword(teRepeatPass.text);
      }
      if (profile.user.name != teUsername.text) {
        dbUser
            .where("nombre_usuario", isEqualTo: teUsername.text)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            AlertsMessage.showSnackbar('nickname_validate'.tr);
          } else {
            dbUser.doc(uuid).update({
              "image_profile": imageToChange ?? profile.user.image,
              "nombre_usuario": teUsername.text,
              "date_update": DateTime.now(),
            }).then((value) => Get.back());
          }
        });
      } else {
        dbUser.doc(uuid).update({
          "image_profile": imageToChange ?? profile.user.image,
          "nombre_usuario": teUsername.text,
          "date_update": DateTime.now(),
        }).then((value) => Get.back());
      }
    }
  }

  void gotoDetail(int index, int type) {
    if (type == 1) {
      Get.to(DetailSnowballView(listOne[index].id));
    } else {
      Get.to(DetailSnowballView(listTwo[index].id));
    }
  }
}
