import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ots/ots.dart';
import 'package:snowball/src/common/alerts.dart';
import 'package:snowball/src/scenes/home/navigation.dart';
import 'package:snowball/src/scenes/login/sign_in_view.dart';
import 'package:snowball/src/scenes/onboarding/onboarding_view.dart';
import 'package:snowball/src/service/localize_service.dart';

class AuthController extends GetxController {
  static AuthController to = Get.find();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseMessaging _fcm = FirebaseMessaging();

  Rx<User> firebaseUser = Rx<User>();

  final box = GetStorage();

  Future<User> get getUser async => _auth.currentUser;
  Stream<User> get user => _auth.authStateChanges();
  Future<String> get tokenFcm => _fcm.getToken();

  @override
  void onReady() async {
    debounce(firebaseUser, handleAuthChanged,
        time: Duration(seconds: 2)); // Evita que se llame muchas veces
    firebaseUser.value = await getUser;
    firebaseUser.bindStream(user);
    super.onReady();
  }

  void handleAuthChanged(User _firebaseUser) async {
    if (_firebaseUser == null) {
      Get.offAll(LoginView());
    } else {
      saveUserInFiretore(_firebaseUser, "token");
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly'],
  );

  Future<User> handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  void saveUserInFiretore(User user, String token) {
    FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user.uid)
        .get()
        .then((val) {
      if (val.exists) {
        FirebaseFirestore.instance.collection("usuarios").doc(user.uid).update({
          "correo": user.email != null ? user.email : "anonimous",
          "estado": "A",
          "id": user.uid,
          "date_creation": user.metadata.creationTime,
          "date_last_login": DateTime.now(),
          "token": token
        }).then((value) {
          box.write("userID", user.email);
          box.write("uuid", user.uid);

          loginValidate(user.uid);
        }).catchError((e) {
          print(e);
        });
      } else {
        FirebaseFirestore.instance.collection("usuarios").doc(user.uid).set({
          "nombre_usuario": user.displayName,
          "correo": user.email != null ? user.email : "anonimous",
          "estado": "A",
          "id": user.uid,
          "date_creation": user.metadata.creationTime,
          "date_last_login": DateTime.now(),
          "token": token
        }).then((value) {
          box.write("userID", user.email);
          box.write("uuid", user.uid);

          // Goto Validation
          loginValidate(user.uid);
        }).catchError((e) {
          print(e);
        });
      }
    });
  }

  void loginValidate(String id) {
    FirebaseFirestore.instance
        .collection("usuarios")
        .doc(id)
        .get()
        .then((value) {
      var data = value.data();
      if (data["locale"] != null) {
        int locale = data["locale"];
        Get.updateLocale(LocalizationService.locales[locale]);
        box.write("locale", locale);
      }

      if (data["isValidate"] != null && data["isValidate"]) {
        hideLoader();
        Get.offAll(NavigationApp());
      } else {
        Get.offAll(OnboardingPage(false));
      }
    }).catchError((onError) {
      logout();
    });
  }

  void loginUser(email, pass) {
    _auth
        .signInWithEmailAndPassword(email: email, password: pass)
        .then((response) {
      tokenFcm.then((token) => saveUserInFiretore(response.user, token));
    }).catchError((onError) {
      hideLoader();
      AlertsMessage.showSnackbar('wrong_pass'.tr);
    });
  }

  void singUpUser(nickname, email, password, repeatpass) {
    _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((response) {
      var user = response.user;
      tokenFcm.then((token) => saveUserInFiretore(user, token));
    }).catchError((e) {
      var errorMessage = "";
      switch (e.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = 'errorMessage1'.tr;
          break;
        case "ERROR_EMAIL_ALREADY_IN_USE":
          errorMessage = 'errorMessage2'.tr;
          break;
        case "ERROR_WRONG_PASSWORD":
          errorMessage = 'wrong_pass'.tr;
          break;
        case "ERROR_USER_NOT_FOUND":
          errorMessage = 'errorMessage3'.tr;
          break;
        case "ERROR_USER_DISABLED":
          errorMessage = 'errorMessage4'.tr;
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage = 'errorMessage5'.tr;
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = 'errorMessage6'.tr;
          break;
        default:
          errorMessage = 'errorMessage7'.tr;
      }
      AlertsMessage.showSnackbar(errorMessage);
    });
  }

  logout() {
    _auth.signOut().then((value) => Get.offAll(LoginView()));
  }
}
