import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:snowball/src/models/detail/list_model.dart';
import 'package:snowball/src/models/snowball/snowball.dart';

class DetailListController extends GetxController {
  static DetailListController get to => Get.put(DetailListController());

  final dbRolls = FirebaseFirestore.instance.collectionGroup("rolls");
  final dbSnowball = FirebaseFirestore.instance.collection("snowball");
  RxList<ElementSnowball> snowball = <ElementSnowball>[].obs;
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

  getSnowballs(String type, String tags, {String idUser}) async {
    final uuid = idUser ?? box.read("uuid");
    switch (type) {
      case "rolls":
        dbRolls.where("user", isEqualTo: uuid).get().then((value) {
          if (value.docs.isNotEmpty) {
            value.docs.forEach((roll) {
              dbSnowball.doc(roll["snowball"]).get().then((snowballResponse) {
                completeList(snowballResponse);
              });
            });
            refresh();
          }
        });
        break;
      case "snowball":
        dbSnowball.where("autor", isEqualTo: uuid).get().then((value) {
          if (value.docs.isNotEmpty) {
            value.docs.forEach((element) {
              completeList(element);
            });
          }
        });
        break;
      case "rollsgreat":
        dbSnowball
            .where("rolls", isGreaterThan: 1)
            .orderBy("rolls", descending: true)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            value.docs.forEach((element) {
              completeList(element);
            });
          }
        });
        break;
      case "rollsnogreat":
        dbSnowball
            .where("rolls", isGreaterThan: 0)
            .orderBy("rolls", descending: true)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            value.docs.forEach((element) {
              completeList(element);
            });
          }
        });
        break;
    }
  }

  completeList(DocumentSnapshot response) {
    var snow = Snowball.fromJsonMap(response.data(), response.id);
    var elemnt = ElementSnowball(
        id: snow.id,
        name: snow.nombre,
        ciudad: snow.ciudad,
        image: validateImage(snow),
        tags: getTagsList(snow.etiquetas));
    snowball.add(elemnt);
  }

  validateImage(Snowball element) {
    if (element.adjuntos.isNotEmpty) {
      if (element.adjuntos.first.video != null) {
        return "https://isaca-gwdc.org/wp-content/uploads/2016/12/Video-placeholder.png";
      } else {
        return element.adjuntos.first.image;
      }
    } else {
      return "https://firebasestorage.googleapis.com/v0/b/snowballapp-84bc6.appspot.com/o/images%2Fsnowball_logo.png?alt=media&token=71af8cc7-33bd-471c-ba1c-3fb53a4bba96";
    }
  }

  clearData() {
    snowball.clear();
  }
}
