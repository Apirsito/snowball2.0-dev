import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/scenes/home/navigation.dart';

class OnboardingPage extends StatefulWidget {
  final bool help;
  OnboardingPage(this.help);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final GlobalKey<ScaffoldState> _scaffoldinK = new GlobalKey<ScaffoldState>();
  User user;
  final PageController _pageController = PageController(initialPage: 0);
  TextEditingController nickname = TextEditingController();
  int _numberPage = 5;
  int _currenPage = 0;
  String name = "";
  bool isValid = true;
  String stateAvatar;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() async {
    setState(() {
      stateAvatar =
          "https://firebasestorage.googleapis.com/v0/b/snowballapp-84bc6.appspot.com/o/images%2Fsnowball_logo.png?alt=media&token=71af8cc7-33bd-471c-ba1c-3fb53a4bba96";
      _numberPage = widget.help ? 4 : 5;
    });
    user = FirebaseAuth.instance.currentUser;
  }

  Widget pageOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 50, top: 20),
          child: Center(
            child: Image(
              image: AssetImage("assets/location.png"),
              width: 335,
              height: 300,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            'step1'.tr,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        )
      ],
    );
  }

  Widget pageTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Center(
            child: Image(
              image: AssetImage("assets/robo2.png"),
              width: 335,
              height: 300,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: Text(
            'step2'.tr,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget pageTree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Center(
            child: Image(
              image: AssetImage("assets/neibord.png"),
              width: 335,
              height: 300,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: Text(
            'step3'.tr,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget pageFour() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.help
            ? Padding(
                padding: const EdgeInsets.only(top: 10, left: 5),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NavigationApp()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'back'.tr,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Center(
            child: Image(
              image: AssetImage("assets/secure.png"),
              width: 335,
              height: 300,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: Text(
            'step4'.tr,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget pageFinis() {
    return ListView(
      children: <Widget>[
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Text(
              'customice_profile'.tr,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Container(
              height: 200,
              width: 300,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Center(
                child: Container(
                  width: 140,
                  height: 140,
                  margin: EdgeInsets.only(top: 15),
                  child: Stack(
                    children: <Widget>[
                      ClipOval(
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/snowball_logo.png",
                          image: stateAvatar,
                          height: 128,
                          width: 128,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Text(
            'step5'.tr,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  void validateUserNick(String nick, BuildContext context) async {
    FirebaseFirestore.instance
        .collection("usuarios")
        .where("nombre_usuario", isEqualTo: nick)
        .get()
        .then((val) {
      if (val.docs.length > 0) {
        setState(() {
          isValid = false;
        });
      } else {
        setState(() {
          isValid = true;
        });
      }
    });
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numberPage; i++) {
      list.add(i == _currenPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8,
      width: isActive ? 24 : 16,
      decoration: BoxDecoration(
          color: isActive ? Colors.white : AppConstants.blue,
          borderRadius: BorderRadius.all(Radius.circular(12))),
    );
  }

  void _saveOnbording() {
    FirebaseFirestore.instance.collection("usuarios").doc(user.uid).update(
        {"date_update": DateTime.now(), "isValidate": true}).then((respo) {
      Get.to(() => NavigationApp());
    }).catchError((e) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldinK,
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppConstants.darBlue, AppConstants.blue])),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                ),
                Container(
                  height: 600,
                  child: PageView(
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currenPage = page;
                      });
                    },
                    children: widget.help
                        ? [
                            pageFour(),
                            pageTree(),
                            pageTwo(),
                            pageOne(),
                          ]
                        : [
                            pageFour(),
                            pageTree(),
                            pageTwo(),
                            pageOne(),
                            pageFinis()
                          ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                _currenPage != _numberPage - 1
                    ? Expanded(
                        child: Align(
                        alignment: FractionalOffset.bottomRight,
                        child: FlatButton(
                            onPressed: () {
                              _pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'next'.tr,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                )
                              ],
                            )),
                      ))
                    : Text("")
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currenPage == _numberPage - 1 && widget.help
          ? Container(
              height: 100,
              width: double.infinity,
              color: Colors.white,
              child: GestureDetector(
                onTap: () {
                  Get.to(() => NavigationApp());
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text(
                      'close'.tr,
                      style: TextStyle(
                          color: AppConstants.darBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ))
          : _currenPage == _numberPage - 1
              ? Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.white,
                  child: GestureDetector(
                    onTap: () {
                      _saveOnbording();
                    },
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Text(
                          'get_sterted'.tr,
                          style: TextStyle(
                              color: AppConstants.darBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                )
              : Text(""),
    );
  }
}
