import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String correo;
  DateTime dateCreation;
  DateTime dateLastLogin;
  DateTime dateUpdate;
  String estate;
  String name;
  String image;

  UserModel();

  UserModel.fromJsonMap(DocumentSnapshot map)
      : id = map.id,
        correo = map["correo"] != null ? map["correo"] : "",
        dateCreation = map["date_creation"] != null
            ? map["date_creation"].toDate()
            : DateTime.now(),
        dateLastLogin = map["date_last_login"] != null
            ? map["date_last_login"].toDate()
            : DateTime.now(),
        dateUpdate = map["date_update"] != null
            ? map["date_update"].toDate()
            : DateTime.now(),
        estate = map["estado"],
        name = map["nombre_usuario"],
        image = map.data()["image_profile"] != null
            ? map["image_profile"]
            : "https://firebasestorage.googleapis.com/v0/b/snowballapp-84bc6.appspot.com/o/images%2Fsnowball_logo.png?alt=media&token=71af8cc7-33bd-471c-ba1c-3fb53a4bba96";
}
