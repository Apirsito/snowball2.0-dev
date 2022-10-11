import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ots/ots.dart';
import 'package:snowball/src/controller/auth/auth_controller.dart';
import 'package:snowball/src/scenes/login/sign_in_view.dart';
import 'package:snowball/src/scenes/splash/splash.dart';
import 'package:snowball/src/service/localize_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await GetStorage.init();
  // Controller Authentication
  Get.put<AuthController>(AuthController());
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OTS(
      showNetworkUpdates: true,
      persistNoInternetNotification: false,
      loader: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
      child: GetMaterialApp(
        locale: LocalizationService.locale,
        fallbackLocale: LocalizationService.fallbackLocale,
        translations: LocalizationService(),
        defaultTransition: Transition.fade,
        opaqueRoute: Get.isOpaqueRouteDefault,
        popGesture: Get.isPopGestureEnable,
        transitionDuration: Get.defaultTransitionDuration,
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        getPages: [
          GetPage(name: '/', page: () => Splash()),
          GetPage(name: '/login', page: () => LoginView()),
        ],
      ),
    );
  }
}
