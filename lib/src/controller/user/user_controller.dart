import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:snowball/src/models/snowball/snowball.dart';
import 'package:snowball/src/models/user/user_data_model.dart';
import 'package:snowball/src/models/user/user_model.dart';
import 'package:snowball/src/scenes/chats/chat_detail.dart';
import 'package:snowball/src/scenes/common/modals.dart';
import 'package:snowball/src/scenes/detail/detail_snowball_view.dart';

class UserController extends GetxController {
  static UserController get to => Get.put(UserController());
  final dbUser = FirebaseFirestore.instance.collection("usuarios");
  final dbRolls = FirebaseFirestore.instance.collectionGroup("rolls");
  final dbSnowball = FirebaseFirestore.instance.collection("snowball");
  final dbRecommend = FirebaseFirestore.instance.collection("recomendaciones");

  var loading = true.obs;
  RxList<String> latesSnowballList = [""].obs;
  RxList<Snowball> listOne = RxList<Snowball>();
  UserDataModel userData = new UserDataModel();
  final box = GetStorage();

  getDataUser(String id) {
    var uuid = box.read('uuid');
    var recommends = 0;
    var block = false;

    crearData();

    dbUser.doc(id).get().then((user) {
      dbRolls.where("user", isEqualTo: id).get().then((rolls) {
        dbRecommend.where("id", isEqualTo: id).get().then((responseRecommend) {
          responseRecommend.docs.forEach((element) {
            dbSnowball.doc(element.id).get().then((value) {
              if (value.exists) {
                recommends++;
              }
            });
          });

          dbUser
              .doc(uuid)
              .collection("blocks")
              .where("user_id", isEqualTo: id)
              .get()
              .then((value) {
            if (value.docs.isNotEmpty) {
              block = true;
            }
          });

          dbSnowball
              .where("autor", isEqualTo: id)
              .orderBy("fecha", descending: true)
              .get()
              .then((responseSnoballs) {
            responseSnoballs.docs.forEach((element) {
              listOne.add(Snowball.fromSnapshot(element));
              validateImage(latesSnowballList, element);
            });

            userData = UserDataModel.fromJsonMap(
              user, listOne.value, latesSnowballList.value, block, rolls.docs.length, recommends
            );
            loading.value = false;
            refresh();
          });
        });
      });
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
    }
  }

  crearData() {
    listOne.clear();
    latesSnowballList.clear();
  }

  senToMessageChat(String id) {
    var current = box.read("uuid");
    dbUser.doc(id).get().then((value) {
      if (value.exists) {
        var user = UserModel.fromJsonMap(value);
        Get.to(ChatsUserView(current, id, user));
      }
    });
  }

  openDenuncias(String id, BuildContext context) {
    ModalsView.whiIdDenuncePublish(context, id, parent: false);
  }

  void gotoDetail(int index, int type) {
    if (type == 1) {
      Get.to(DetailSnowballView(listOne[index].id));
    }
  }

  blockthisUser() {
    var id = userData.user.id;
    var uuid = box.read('uuid');
    dbUser.doc(uuid).collection("blocks").doc(id).set({
      "user_id": id,
      "nombre_usuario": userData.user.name,
      "fecha": DateTime.now()
    }).then((val) {
      userData.userBlock = true;
      refresh();
    });
  }

  unBlockUser() {
    var id = userData.user.id;
    var uuid = box.read('uuid');
    loading.value = true;
    dbUser.doc(uuid).collection("blocks").doc(id).delete().then((val) {
      userData.userBlock = false;
      getDataUser(id);
      refresh();
    });
  }
}
