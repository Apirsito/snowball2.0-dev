import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/app_constants.dart';

class ForgotView extends StatefulWidget {
  @override
  _ForgotPageState createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotView> {
  TextEditingController emailvalidator = TextEditingController();
  bool isSendEmail = false;

  @override
  Widget build(BuildContext context) {
    void _sendEmailValid() {
      FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailvalidator.text)
          .then((val) {
        setState(() {
          isSendEmail = true;
        });
      });
    }

    void _backToLogin() {
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromRGBO(0, 146, 209, 1),
        elevation: 0,
        title: Text(
          'forgot_pass'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        height: Get.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppConstants.blue, AppConstants.darBlue])),
        child: ListView(
          padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 20.0),
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Container(
                height: 410,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10, top: 30),
                  child: Column(
                    children: <Widget>[
                      isSendEmail == true
                          ? Padding(
                              padding: EdgeInsets.only(top: 50.0, bottom: 10),
                              child: Center(
                                child: Image(
                                  image: AssetImage("assets/sms.png"),
                                  width: 180,
                                  height: 110,
                                ),
                              ))
                          : Center(
                              child: Image(
                                image: AssetImage("assets/reset.png"),
                                width: 200,
                                height: 150,
                              ),
                            ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10, left: 30, right: 30),
                        child: Text(
                          isSendEmail == true
                              ? 'check_message'.tr
                              : 'recieve_message'.tr,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                      isSendEmail
                          ? SizedBox()
                          : Padding(
                              padding:
                                  EdgeInsets.only(top: 20, right: 30, left: 30),
                              child: TextField(
                                  controller: emailvalidator,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      labelText: 'email'.tr,
                                      contentPadding: EdgeInsets.only(
                                          top: 10,
                                          left: 10,
                                          right: 0,
                                          bottom: 10),
                                      labelStyle: TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black26, width: 0.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black26, width: 0.0),
                                      ))),
                            ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: () =>
                              !isSendEmail ? _sendEmailValid() : _backToLogin(),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 100),
                          color: Color.fromRGBO(0, 146, 209, 1),
                          child: Text(
                              isSendEmail
                                  ? 'back'.tr.toUpperCase()
                                  : 'continuelabel'.tr.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
