import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/app_constants.dart';

class AlertsMessage {
  static showSnackbar(String message) {
    Get.snackbar("Error", message,
        colorText: Colors.white,
        backgroundColor: AppConstants.blue,
        borderRadius: 5,
        snackPosition: SnackPosition.BOTTOM);
  }
}
