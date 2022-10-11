import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ots/ots.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/auth/auth_controller.dart';

class LoginController extends GetxController {
  TextEditingController loginEmail = new TextEditingController();
  TextEditingController loginPassword = new TextEditingController();

  void loginUserFirebase() {
    if (_isValid()) {
      showLoader(isModal: true, modalColor: AppConstants.blue);
      AuthController.to
          .loginUser(loginEmail.text.trim(), loginPassword.text.trim());
    }
  }

  void loginGoogle() {
    AuthController.to.handleSignIn();
  }

  bool _isValid() {
    if (loginEmail.text.isEmpty || loginEmail.text == "") {
      Get.snackbar("Error", 'recognize_email'.tr,
          colorText: Colors.white, backgroundColor: AppConstants.blue);
      return false;
    }

    if (loginPassword.text.isEmpty || loginPassword.text == "") {
      Get.snackbar("Error", 'wrong_pass'.tr,
          colorText: Colors.white, backgroundColor: AppConstants.blue);
      return false;
    }
    return true;
  }
}
