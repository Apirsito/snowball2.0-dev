import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/app_constants.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppConstants.blue,
        child: Center(
            child: Hero(
                tag: "logInit",
                child: Image.asset("assets/snowball_logo.png", width: Get.width/4,)
            )
        ),
      ),
    );
  }
}