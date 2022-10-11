import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:snowball/src/controller/notification/notification_controller.dart';
import 'package:snowball/src/models/coments/coments_model.dart';
import 'package:snowball/src/models/snowball/adjunto.dart';
import 'package:snowball/src/models/snowball/snowball.dart';
import 'package:snowball/src/models/user/user_model.dart';
import 'package:snowball/src/scenes/add/add_view.dart';
import 'package:snowball/src/scenes/chats/chat_detail.dart';

class DetailSnowballController extends GetxController {
  static DetailSnowballController get to => Get.put(DetailSnowballController());

  final _dbSnowball = FirebaseFirestore.instance.collection("snowball");
  final _dbUser = FirebaseFirestore.instance.collection("usuarios");
  final _dbComment = FirebaseFirestore.instance.collection("comentarios");
  PageController pageController = PageController(initialPage: 0);
  RxList<Adjuntos> resources = RxList<Adjuntos>();
  RxList<CommentModel> listComent = RxList<CommentModel>();
  Rx<Snowball> snowball = Rx<Snowball>();
  Rx<UserModel> autor = Rx<UserModel>();
  var commentId = "".obs;
  var mySnowball = false.obs;
  var box = GetStorage();
  var page = 0.obs;
  var loading = true.obs;
  Uint8List markerIcon;

  TextEditingController comments = TextEditingController();
  FocusNode focusNode = FocusNode();

  var chars = "abcdefghijklmnopqrstuvwxyz0123456789";

  String randomString(int strlen) {
    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for (var i = 0; i < strlen; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result;
  }

  @override
  void onInit() {
    getIcons();
    pageController = PageController(initialPage: 0);
    super.onInit();
  }

  getIcons() async {
    markerIcon = await getBytesFromAsset('assets/snowball_logo.png', 80);
  }

  getDetail(String id) {
    var uuid = box.read("uuid");
    _dbSnowball.doc(id).get().then((value) {
      if (value.exists) {
        snowball.value = Snowball.fromSnapshot(value);
        _dbUser.doc(snowball.value.autor).get().then((user) {
          autor.value = UserModel.fromJsonMap(user);
          mySnowball.value = uuid == autor.value.id;
          loading(false);
          _dbSnowball.doc(id).collection("adjuntos").get().then((value) {
            if (value.docs.isNotEmpty) {
              var list = <Adjuntos>[];
              value.docs.forEach((element) {
                var adjunto = Adjuntos.fromJson(element.data());
                list.add(adjunto);
              });
              resources.addAll(list);
            } else {
              resources.add(Adjuntos());
            }
          });
        });
      }
    });
  }

  clearData() {
    resources.clear();
  }

  changePage(int value) {
    page.value = value;
  }

  sendOtherComment() {
    if (comments.text.isNotEmpty && comments.text.trim().isNotEmpty) {
      var rdocs = randomString(20);
      var uuid = box.read("uuid");

      List<String> localComment = snowball.value.comentarios != null
          ? snowball.value.comentarios.toList()
          : [];

      DocumentReference referemce = commentId.value == ""
          ? _dbComment.doc(rdocs)
          : _dbComment
              .doc(commentId.value)
              .collection("comentarios")
              .doc(rdocs);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(referemce, {
          "autor": uuid,
          "descripcion": comments.text.trim(),
          "fecha_creacion": DateTime.now(),
          "snowball_id": snowball.value.id
        });
      }).then((value) {
        localComment.add(referemce.id);
        comments.text = "";
        commentId.value = "";
        focusNode.unfocus();

        _dbSnowball
            .doc(snowball.value.id)
            .update({"comentarios": localComment}).then((value) {
          getDetail(snowball.value.id);
          NotificationController.to.sendPush(
            snowball.value.autor, 
            uuid, 
            snowball.value.id,
          );
        });
      });
    }
  }

  void requestForcus() {
    FocusScope.of(Get.context).requestFocus(focusNode);
  }

  gotoEdit() async {
    await Get.to(() => AddView(id: snowball.value.id));
    clearData();
    getDetail(snowball.value.id);
  }

  gotoPerfilUser(String id) {
    var current = box.read("uuid");
    _dbUser.doc(id).get().then((value) {
      if (value.exists) {
        var user = UserModel.fromJsonMap(value);
        Get.to(ChatsUserView(current, id, user));
      }
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))
        .buffer
        .asUint8List();
  }
}
