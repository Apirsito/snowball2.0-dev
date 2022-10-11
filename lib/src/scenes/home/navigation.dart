import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/scenes/home/home_view.dart';
import 'package:snowball/src/scenes/login/term_conditions.dart';
import 'package:snowball/src/scenes/maps/maps_location_view.dart';
import 'package:snowball/src/scenes/notification/notification_view.dart';
import 'package:snowball/src/scenes/profile/profile_view.dart';
import 'package:snowball/src/scenes/search/search_view.dart';

class NavigationApp extends StatefulWidget {
  int indexIn;
  NavigationApp({this.indexIn});
  @override
  _NavigationdAppState createState() => _NavigationdAppState();
}

class _NavigationdAppState extends State<NavigationApp> {
  int _currentIndex = 2;
  final box = GetStorage();

  @override
  void initState() {
    this.initDynamicLinks();
    super.initState();
  }

  // ignore: missing_return
  Widget returnCallPage(int index) {
    widget.indexIn = null;
    switch (index) {
      case 0:
        return MapsLocationView();
      case 1:
        return SearchPage();
      case 2:
        return HomeView();
      case 3:
        return NotificationView();
      case 4:
        return ProfileView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dashboard",
      theme: ThemeData(
        primaryColor: AppConstants.teal,
      ),
      home: Scaffold(
        appBar: PreferredSize(
          child: Container(
            padding:
                new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: new Padding(
              padding: const EdgeInsets.only(left: 30.0, top: 0.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _currentIndex == 3
                      ? Text('title_notifi'.tr,
                          style: TextStyle(color: Colors.white, fontSize: 19))
                      : Image.asset("assets/logo_snowball.png", height: 20),
                  IconButton(
                    icon: Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Get.to(TermAndConditions(
                        url: "https://appsnowball.com/faqs.html")),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppConstants.darBlue,
                  Color.fromRGBO(82, 173, 187, 1)
                ]),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[500],
                    blurRadius: 20.0,
                    spreadRadius: 1.0,
                  )
                ]),
          ),
          preferredSize: Size(Get.width, 150.0),
        ),
        body: WillPopScope(
          onWillPop: onBakPress,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.lightBlueAccent),
              ),
            ),
            child: returnCallPage(widget.indexIn ?? _currentIndex),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: AppConstants.blue,
            currentIndex: widget.indexIn ?? _currentIndex,
            onTap: (value) {
              setState(() => _currentIndex = value);
            },
            items: [
              BottomNavigationBarItem(
                  icon: Image.asset(
                    "assets/icon_maps.png",
                    width: 30,
                  ),
                  activeIcon: Image.asset(
                    "assets/icon_maps_a.png",
                    width: 30,
                  ),
                  title: Text("")),
              BottomNavigationBarItem(
                  icon: Image.asset(
                    "assets/icon_searh.png",
                    width: 30,
                  ),
                  activeIcon: Image.asset(
                    "assets/icon_searh_a.png",
                    width: 30,
                  ),
                  title: Text("")),
              BottomNavigationBarItem(
                  icon: Image.asset(
                    "assets/icon_home.png",
                    width: 45,
                  ),
                  title: Text("")),
              BottomNavigationBarItem(
                  icon: Stack(
                    children: <Widget>[
                      Image.asset(
                        "assets/icon_notifi.png",
                        width: 30,
                      ),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("notifications")
                            .where("id", isEqualTo: box.read('uuid'))
                            .where("read", isEqualTo: false)
                            .snapshots(),
                        builder: (context, snow) {
                          if (!snow.hasData) {
                            return SizedBox();
                          } else {
                            return snow.data.docs.length > 0
                                ? Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 10,
                                        minHeight: 10,
                                      ),
                                      child: Text(
                                        '',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : SizedBox();
                          }
                        },
                      ),
                    ],
                  ),
                  activeIcon: Image.asset(
                    "assets/icon_notifi_a.png",
                    width: 30,
                  ),
                  title: Text("")),
              BottomNavigationBarItem(
                  icon: Image.asset(
                    "assets/icon_perfil.png",
                    width: 30,
                  ),
                  activeIcon: Image.asset(
                    "assets/icon_perfil_a.png",
                    width: 30,
                  ),
                  title: Text("")),
            ]),
      ),
    );
  }

  Future<bool> onBakPress() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('popop_exit'.tr),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("Ok")),
                FlatButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('cancel'.tr)),
              ],
            ));
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      if (deepLink != null) {
        // final id = deepLink.queryParameters['snowball'];
        // Get.to(DetailView(id));
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      final id = deepLink.queryParameters['snowball'];
      if (id != "") {
        // Get.to(DetailView(id));
      } else {
        Get.snackbar("No found", "Snowball not available");
      }
    }
  }
}
