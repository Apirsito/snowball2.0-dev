import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:snowball/src/models/notification/notification_model.dart';
import 'package:snowball/src/models/user/user_model.dart';
import 'package:snowball/src/scenes/chats/chat_detail.dart';
import 'package:snowball/src/scenes/detail/detail_snowball_view.dart';
import 'package:snowball/src/scenes/recomend/recomend_view.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.put(NotificationController());

  final dbNotification = FirebaseFirestore.instance.collection("notifications");
  final dbUser = FirebaseFirestore.instance.collection("usuarios");
  final dbSnow = FirebaseFirestore.instance.collection("snowball");
  RxList<Notification> notifications = RxList<Notification>();
  final box = GetStorage();

  getNotifications() {
    var uuid = box.read("uuid");
    dbNotification
        .where("id", isEqualTo: uuid)
        .orderBy("fecha", descending: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        notifications = new RxList<Notification>.empty();
        dbUser.doc(element["id"]).get().then((e) {
          if (e.exists) {
            var notification = Notification.fromJson(element);
            notification.autor = e.data()["nombre_usuario"];
            notification.autorId = e.id;
            notifications.add(notification);
          }
        });
        refresh();
      });
    });
  }

  clearData() {}

  senDataDetail(int type, Notification document) {
    switch (type) {
      case 1:
        readNotifications(document.id).then((value) {
          dbUser.doc(document.autorId).get().then((val) async {
            UserModel usuario = UserModel.fromJsonMap(val);
            await Get.to( () => ChatsUserView(box.read("uuid"), document.autorId, usuario));
            clearData();
            getNotifications();
          });
        });
        break;
      case 2:
        readNotifications(document.id).then((_) async {
          await Get.to( () => RecomendView());
          clearData();
          getNotifications();
        });
        break;
      case 3:
        readNotifications(document.id).then((_) async {
          if (document.snowballId != null && document.snowballId.isNotEmpty) {
            await Get.to(() => DetailSnowballView(document.snowballId));
            clearData();
            getNotifications();
          }
        });
        break;
    }
  }

  readNotifications(String id) async {
    return dbNotification.doc(id).update({
      "read": true,
    });
  }

  getTypeNotification(int type, String param) {
    if (param == "icons") {
      switch (type) {
        case 1:
          return FontAwesomeIcons.envelope;
        case 2:
          return FontAwesomeIcons.check;
        case 3:
          return FontAwesomeIcons.comments;
      }
    }
    if (param == "title") {
      switch (type) {
        case 1:
          return 'new_mesagges'.tr;
        case 2:
          return 'new_recommendation'.tr;
        case 3:
          return 'new_comment'.tr;
      }
    }
    if (param == "subtitle") {
      switch (type) {
        case 1:
          return "Chat";
        case 2:
          return 'recommendation'.tr;
        case 3:
          return 'comment'.tr;
      }
    }
  }

  send(TypeNotify type, String nameUser, String token) {
    var user = nameUser.replaceAll("\t", "");
    var body = "";
    switch (type) {
      case TypeNotify.message:
        body = "$user" + "notiMessage".tr;
        break;
      case TypeNotify.recommend:
        body = "$user" + "notiRecommen".tr;
        break;
      case TypeNotify.post:
        body = "$user" + "notiPost".tr;
        break;
      case TypeNotify.reply:
        body = "$user" + "notiRepl".tr;
        break;
    }
    sendAndRetrieveMessage(body, token);
  }

  sendAndRetrieveMessage(String body, token) async {
    // var client = http.Client();
    // try {
    //   var respon = await client.post(
    //     'https://fcm.googleapis.com/fcm/send',
    //     headers: <String, String>{
    //       'Content-Type': 'application/json',
    //       'Authorization': 'key=$serverToken',
    //     },
    //     body: jsonEncode(
    //       <String, dynamic>{
    //         'notification': <String, dynamic>{
    //           'body': 'Snowball',
    //           'title': '$body'
    //         },
    //         'priority': 'high',
    //         'data': <String, dynamic>{
    //           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    //           'id': '1',
    //           'status': 'done'
    //         },
    //         'to': token,
    //       },
    //     ),
    //   );

    //   print(respon.body);
    // } catch(e) {
    //   print( "Error enviando push ");
    // } finally {
    //   client.close();
    // }
  }

  void sendPush(String autor, String current, String snowball) {
    dbNotification.add({
      "id": current,
      "read": false,
      "title": "New Comment",
      "type": 3,
      "snowball_id": snowball,
      "fecha": DateTime.now()
    }).then((value) {
      dbSnow.doc(snowball).get().then((snow) {
        var userTo = snow["autor"];
        dbUser.doc(userTo).get().then((user) {
          send(TypeNotify.post, "Somebody", user["token"]);
        });
      });
    });
  }
}

enum TypeNotify { message, recommend, post, reply }
