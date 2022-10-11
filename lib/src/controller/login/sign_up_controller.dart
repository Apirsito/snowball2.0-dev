import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/alerts.dart';
import 'package:snowball/src/controller/auth/auth_controller.dart';

class SignUpController extends GetxController {
  TextEditingController nickname = TextEditingController();
  TextEditingController emailsing = TextEditingController();
  TextEditingController passwsign = TextEditingController();
  TextEditingController repeatpass = TextEditingController();

  registerUserData() {
    if (passwsign.text != repeatpass.text) {
      AlertsMessage.showSnackbar('nomatchPass'.tr);
    } else if (nickname.text.isNotEmpty &&
        emailsing.text.isNotEmpty &&
        passwsign.text.isNotEmpty &&
        repeatpass.text.isNotEmpty) {
      AuthController.to.singUpUser(nickname.text.trim(), emailsing.text.trim(),
          passwsign.text.trim(), repeatpass.text.trim());
    } else {
      AlertsMessage.showSnackbar('some_fields'.tr);
    }
  }

  void validateUserNick() async {
    FirebaseFirestore.instance
        .collection("usuarios")
        .where("nombre_usuario", isEqualTo: nickname.text)
        .get()
        .then((val) {
      if (val.docs.length > 0) {
        AlertsMessage.showSnackbar('nickname_validate'.tr);
      } else {
        registerUserData();
      }
    });
  }

  aceptermMessage() {
    AlertsMessage.showSnackbar('you_must_accep_term'.tr);
  }
}
