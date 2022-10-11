import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class ToolBarController extends GetxController {
  static ToolBarController get to => Get.put(ToolBarController());
  final rolls = FirebaseFirestore.instance.collectionGroup("rolls");
  final recomment = FirebaseFirestore.instance.collection("recomendaciones");

  final box = GetStorage();
  final _db = FirebaseFirestore.instance.collection("snowball");

  bool isCurrentSnowball(List listasnow) {
    if (listasnow.isNotEmpty) {
      bool isPresent = false;
      listasnow.forEach((item) {
        if (item.data()["user"] == box.read("uuid")) {
          isPresent = true;
        }
      });
      return isPresent;
    } else {
      return false;
    }
  }

  void addRolls(String id) {
    var uuid = box.read("uuid");
    var data = {
      "user": uuid,
      "snowball": id,
      "fecha": DateTime.now().microsecondsSinceEpoch
    };

    _db
        .doc(id)
        .collection("rolls")
        .doc(uuid)
        .set(data)
        .then((value) => agregarRolls(id));
  }

  void agregarRolls(String id) async {
    FirebaseFirestore.instance
        .collectionGroup("rolls")
        .where("snowball", isEqualTo: id)
        .get()
        .then((val) {
      print(val);
      _db.doc(id).update({"rolls": val.docs.length});
    });
  }

  shareImageAndTextBy(String id) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://choky.page.link',
      link: Uri.parse('https://appsnowball.com?snowball=$id'),
      androidParameters: AndroidParameters(
        packageName: 'co.com.choky.snowball',
      ),
      iosParameters: IosParameters(
        bundleId: 'co.com.choky.snowball',
        appStoreId: 'id1489651612',
        minimumVersion: '0',
      ),
    );
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    print(shortUrl);
    print(parameters.link.queryParameters['snowball']);
    try {
      var texts = 'message_shared'.tr;
      await WcFlutterShare.share(
          sharePopupTitle: 'Share',
          text: "$texts $shortUrl",
          mimeType: 'text/plain');
    } catch (e) {
      print('error: $e');
    }
  }
}
