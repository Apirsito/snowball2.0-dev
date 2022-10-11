import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:snowball/src/models/chat/user_chats.dart';
import 'package:snowball/src/models/user/user_model.dart';
import 'package:snowball/src/scenes/chats/chat_detail.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.put(ChatController());
  final dbUser = FirebaseFirestore.instance.collection("usuarios");
  final dbChat = FirebaseFirestore.instance.collection("chats");
  RxList<UserModel> users = <UserModel>[].obs;
  var selectUser = UserModel().obs;
  final box = GetStorage();

  String currentUser;
  String iduser;
  var groupChatId = "".obs;

  RxList<UserMessage> _userMessages = RxList<UserMessage>();
  List<UserMessage> get userMessages => _userMessages;

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            userMessages != null &&
            userMessages[index - 1].from == currentUser) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  getListUsers() {
    var uuid = box.read('uuid');
    dbUser.doc(uuid).collection("chats").get().then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((element) {
          dbUser.doc(element["id"]).get().then((user) {
            users.add(UserModel.fromJsonMap(user));
          });
          refresh();
        });
      }
    });
  }

  clearData() {}

  gotoDetail(UserModel item) {
    selectUser.value = item;
    Get.to(() => ChatsUserView(box.read("uuid"), item.id, item));
  }

  void readLocal() {
    if (currentUser.hashCode <= iduser.hashCode) {
      groupChatId.value = '$currentUser-$iduser';
    } else {
      groupChatId.value = '$iduser-$currentUser';
    }
  }

  void getFrienData({String by}) {
    dbUser.doc(by).get().then((value) {
      if (value.exists) {
        selectUser.value = UserModel.fromJsonMap(value);
        iduser = value.id;
        currentUser = box.read('uuid');
        readLocal();
      } else {
        Get.defaultDialog(
            title: "Error",
            content: Text("errorMessage7".tr),
            onConfirm: () => Get.back());
      }
    }).catchError((onError) {
      Get.defaultDialog(
          title: "Error",
          content: Text("errorMessage7".tr),
          confirmTextColor: Colors.white,
          onConfirm: () => Get.back());
    });
  }
}
