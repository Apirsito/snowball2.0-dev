import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/common/drop_down_translate.dart';
import 'package:snowball/src/controller/login/sign_up_controller.dart';
import 'package:snowball/src/scenes/login/sign_in_view.dart';
import 'package:snowball/src/scenes/login/term_conditions.dart';

class SignupView extends StatefulWidget {
  @override
  _SignupWidgetState createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupView> {
  final GlobalKey<ScaffoldState> _scaffoldinKey =
      new GlobalKey<ScaffoldState>();
  final controller = Get.put(SignUpController());

  var userTarmAndCondicion = true;

  bool aceptermin = false;
  bool acepPrivacy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldinKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromRGBO(0, 146, 209, 1),
        elevation: 0,
        actions: [DropDownTranslate()],
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.311, 1.098),
            end: Alignment(0.689, -0.098),
            stops: [0, 1],
            colors: [
              Color.fromARGB(255, 49, 65, 101),
              Color.fromARGB(255, 0, 146, 209),
            ],
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 00.0),
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 100,
                height: 100,
                margin: EdgeInsets.only(top: 0, bottom: 10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(51, 0, 0, 0),
                      offset: Offset(0, 20),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: Image.asset(
                  "assets/snowball_logo.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: 15, bottom: 10),
                child: Text(
                  'sign_up'.tr,
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    fontFamily: "Lato",
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 284,
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  'message_anonimo'.tr,
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16,
                    fontFamily: "Lato",
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              height: 240,
              margin: EdgeInsets.only(left: 20, top: 30, right: 20),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(51, 0, 0, 0),
                    offset: Offset(0, 20),
                    blurRadius: 25,
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 32,
                    margin:
                        EdgeInsets.only(left: 15, top: 10, right: 0, bottom: 0),
                    child: TextField(
                      controller: controller.nickname,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'your_nickname'.tr,
                        contentPadding: EdgeInsets.all(0),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 15,
                        fontFamily: "Lato",
                      ),
                      maxLines: 1,
                      autocorrect: false,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        child: Container(),
                      ),
                    ),
                  ),
                  Container(
                    height: 32,
                    margin: EdgeInsets.only(
                        left: 15, top: 10, right: 18, bottom: 0),
                    child: TextField(
                      controller: controller.emailsing,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'your_email'.tr,
                        contentPadding: EdgeInsets.all(0),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 15,
                        fontFamily: "Lato",
                      ),
                      maxLines: 1,
                      autocorrect: false,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        child: Container(),
                      ),
                    ),
                  ),
                  Container(
                    height: 32,
                    margin: EdgeInsets.only(
                        left: 15, top: 10, right: 18, bottom: 0),
                    child: TextField(
                      controller: controller.passwsign,
                      decoration: InputDecoration(
                        hintText: 'password_char'.tr,
                        contentPadding: EdgeInsets.all(0),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 15,
                        fontFamily: "Lato",
                      ),
                      obscureText: true,
                      maxLines: 1,
                      autocorrect: false,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        child: Container(),
                      ),
                    ),
                  ),
                  Container(
                    height: 32,
                    margin: EdgeInsets.only(
                        left: 15, top: 10, right: 18, bottom: 0),
                    child: TextField(
                      controller: controller.repeatpass,
                      decoration: InputDecoration(
                        hintText: 'repeat_pass'.tr,
                        contentPadding: EdgeInsets.all(0),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 15,
                        fontFamily: "Lato",
                      ),
                      obscureText: true,
                      maxLines: 1,
                      autocorrect: false,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 32,
              margin: EdgeInsets.only(left: 24, top: 20, right: 20),
              child: Row(
                children: [
                  Checkbox(
                    value: aceptermin,
                    checkColor: AppConstants.darBlue,
                    activeColor: Colors.white,
                    onChanged: (bool newValue) {
                      setState(() {
                        aceptermin = newValue;
                      });
                    },
                  ),
                  InkWell(
                    onTap: () => Get.to(TermAndConditions(
                        url: "https://snowballapp-84bc6.web.app/terms.html")),
                    child: Text(
                      'acept_teminos'.tr,
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 13,
                        fontFamily: "Lato",
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 32,
              margin: EdgeInsets.only(left: 24, top: 10, right: 20),
              child: Row(
                children: [
                  Checkbox(
                    value: acepPrivacy,
                    checkColor: AppConstants.darBlue,
                    activeColor: Colors.white,
                    onChanged: (bool newValue) {
                      setState(() {
                        acepPrivacy = newValue;
                      });
                    },
                  ),
                  InkWell(
                    onTap: () => Get.to(TermAndConditions(
                        url: "https://snowballapp-84bc6.web.app/privacy.html")),
                    child: Text(
                      'label_acept_termn'.tr,
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 13,
                        fontFamily: "Lato",
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 20,
            ),
            Container(
              height: 60,
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: FlatButton(
                onPressed: () => aceptermin && acepPrivacy
                    ? controller.validateUserNick()
                    : controller.aceptermMessage(),
                color: aceptermin & acepPrivacy
                    ? Color.fromARGB(255, 255, 255, 255)
                    : Color.fromARGB(50, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
                textColor: Color.fromARGB(255, 49, 65, 101),
                padding: EdgeInsets.all(0),
                child: Text(
                  'sign_up'.tr.toUpperCase(),
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: "Lato",
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              width: 331,
              height: 18,
              margin: EdgeInsets.only(bottom: 40),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 41),
                    child: Text(
                      'already_roll'.tr,
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        fontFamily: "Lato",
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 50,
                    height: 18,
                    margin: EdgeInsets.only(right: 61),
                    child: FlatButton(
                      onPressed: () => Get.to(LoginView()),
                      color: Colors.transparent,
                      textColor: Color.fromARGB(255, 255, 255, 255),
                      padding: EdgeInsets.all(0),
                      child: Text(
                        'log_in'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: "Lato",
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
