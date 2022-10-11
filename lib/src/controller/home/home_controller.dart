import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:snowball/src/models/user/user_model.dart';
import 'package:snowball/src/scenes/chats/chat_detail.dart';

class HomeController extends GetxController {
  final _dbUser = FirebaseFirestore.instance.collection("usuarios");
  final placeholder =
      "https://firebasestorage.googleapis.com/v0/b/snowballapp-84bc6.appspot.com/o/images%2Fsnowball_logo.png?alt=media&token=71af8cc7-33bd-471c-ba1c-3fb53a4bba96";

  final box = GetStorage();

  String getTagsList(List<String> list) {
    var str = "";
    var mas = "";
    var count = 0;
    for (int i = 0; i < list.length; i++) {
      if (i <= 3) {
        str = str + list[i] + ", ";
      } else {
        count++;
        mas = "+$count";
      }
    }
    return str + mas;
  }

  Future<void> gotoPerfilUser(String id) async {
    var current = box.read("uuid");
    _dbUser.doc(id).get().then((value) {
      if (value.exists) {
        var user = UserModel.fromJsonMap(value);
        Get.to(() => ChatsUserView(current, id, user));
      }
    });
  }
}
