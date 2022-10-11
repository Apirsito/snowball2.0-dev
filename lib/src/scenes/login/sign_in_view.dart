import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/common/drop_down_translate.dart';
import 'package:snowball/src/controller/login/login_controller.dart';
import 'package:snowball/src/scenes/login/forgot_view.dart';
import 'package:snowball/src/scenes/login/sign_up_view.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage("assets/fondo_login.png"), // <-- BACKGROUND IMAGE
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          body: Center(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 50.0),
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: Container(width: 107, child: DropDownTranslate())),
                Padding(
                  padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
                  child: Hero(
                    tag: 'hero',
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 48.0,
                      child: Image.asset('assets/snowball_logo.png'),
                    ),
                  ),
                ),
                SizedBox(height: 48.0),

                // Email
                Material(
                  elevation: 4,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: controller.loginEmail,
                    autofocus: false,
                    decoration: InputDecoration(
                        hintText: 'email'.tr,
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide:
                                BorderSide(color: Colors.white, width: 3.0))),
                  ),
                ),
                SizedBox(height: 0.5),
                Material(
                  elevation: 4,
                  child: TextFormField(
                    autofocus: false,
                    obscureText: true,
                    controller: controller.loginPassword,
                    decoration: InputDecoration(
                        hintText: 'pass'.tr,
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide:
                                BorderSide(color: Colors.white, width: 3.0))),
                  ),
                ),
                SizedBox(height: 60.0),

                // Login Buton
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side:
                            BorderSide(color: AppConstants.darBlue, width: 1)),
                    onPressed: () => controller.loginUserFirebase(),
                    padding: EdgeInsets.all(15),
                    color: Colors.white,
                    child: Text('login'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(40, 70, 117, 1),
                        )),
                  ),
                ),
                // Recuperar contraseña
                FlatButton(
                  child: Text('forgot_pass'.tr,
                      style: TextStyle(color: Colors.black54)),
                  onPressed: () {
                    Get.to(ForgotView());
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      LineDegrade(),
                      Padding(
                        padding: EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Text(
                          'or'.tr,
                          style: TextStyle(
                              color: Color.fromRGBO(40, 70, 117, 1),
                              fontSize: 16.0,
                              fontFamily: "WorkSansMedium"),
                        ),
                      ),
                      LineDegrade(),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: Colors.teal, width: 2)),
                    onPressed: () {
                      Get.to(SignupView());
                    },
                    elevation: 0,
                    padding: EdgeInsets.all(15),
                    color: Color.fromRGBO(0, 146, 209, 1),
                    child: Text('create_acount'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: GestureDetector(
                        onTap: () => controller.loginGoogle(),
                        child: Container(
                          padding: EdgeInsets.all(15.0),
                          child: Image.asset(
                            "assets/icon_google.png",
                            width: 60,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container LineDegrade() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              Color.fromRGBO(0, 146, 209, 1),
              Color.fromRGBO(40, 70, 117, 1)
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      width: 100.0,
      height: 1.0,
    );
  }
}
